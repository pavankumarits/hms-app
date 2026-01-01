from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.api import deps
from app.db.session import get_db
from app.models.patient import Patient
from app.schemas.patient import PatientCreate, Patient as PatientSchema

router = APIRouter()

@router.get("/", response_model=List[PatientSchema])
async def read_patients(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user = Depends(deps.get_current_user),
) -> Any:
    result = await db.execute(select(Patient).offset(skip).limit(limit))
    return result.scalars().all()

@router.post("/", response_model=PatientSchema)
async def create_patient(
    *,
    db: AsyncSession = Depends(get_db),
    patient_in: PatientCreate,
    current_user = Depends(deps.get_current_user),
) -> Any:
    # Logic to auto-generate or use provided UIID
    import datetime
    import uuid
    import traceback
    from app.models.user import User

    try:
        # FETCH HOSPITAL ID EXPLICITLY (Bypassing ORM Lazy Load Bug)
        result_h = await db.execute(select(User.hospital_id).filter(User.id == current_user.id))
        hospital_id_val = result_h.scalar()
        if not hospital_id_val:
             raise HTTPException(status_code=400, detail="User has no hospital assigned")

        # 1. Use Provided ID (Offline sync) or Generate New
        final_uiid = patient_in.patient_uiid
        
        if not final_uiid:
            # Fallback generation if not provided (e.g. direct API call)
            year = datetime.datetime.now().year
             # Simple count for fallback
            result = await db.execute(select(Patient).filter(Patient.hospital_id == hospital_id_val))
            count = len(result.scalars().all()) + 1
            final_uiid = f"HOSP-{year}-{count:05d}"
    
        # 2. Try Insert with Conflict Resolution (Retry Loop)
        max_retries = 5
        for attempt in range(max_retries):
            try:
                # Check if UUID exists (idempotency for sync re-runs)
                # If ID is provided and exists, update? Or fail? usually ignore/update. 
                # ideally we check by ID first but here we focus on UIID conflict
                
                patient = Patient(
                    id=str(uuid.uuid4()), # Always new UUID for new patient? Or allow ID from client? Client usually sends UUID too but schema doesn't have it in Create.
                    hospital_id=hospital_id_val,
                    patient_uiid=final_uiid,
                    name=patient_in.name,
                    gender=patient_in.gender,
                    dob=patient_in.dob,
                    phone=patient_in.phone,
                    address=patient_in.address
                )
                db.add(patient)
                await db.commit()
                await db.refresh(patient)
                return patient
    
            except IntegrityError as e:
                await db.rollback()
                # Check if it was the UIID constraint
                if "uq_hospital_patient_uiid" in str(e.orig) or "Duplicate entry" in str(e.orig):
                    # Conflict Detected! Auto-Correct.
                    # Parse "P20251227-0001" -> 0001
                    try:
                        parts = final_uiid.split('-')
                        seq_str = parts[-1] # "0001"
                        new_seq = int(seq_str) + 1
                        # Reconstruct "P20251227-0002"
                        prefix = "-".join(parts[:-1])
                        final_uiid = f"{prefix}-{new_seq:04d}"
                        print(f"Conflict resolved. New ID: {final_uiid}")
                        continue # Retry with new ID
                    except ValueError:
                        # Not in expected format, cannot auto-increment
                        raise HTTPException(status_code=400, detail="Duplicate Patient ID and cannot auto-increment format.")
                else:
                    raise e # Real error
        
        raise HTTPException(status_code=500, detail="Failed to generate unique Patient ID after retries.")

    except Exception as e:
        traceback.print_exc()
        raise e
