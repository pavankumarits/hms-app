from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
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
    # Logic to auto-generate HOSP-YYYY-XXXX UIID
    import datetime
    import uuid
    year = datetime.datetime.now().year
    # Simple count for demo (race condition possible in prod without locks/sequences)
    # Better to use a sequence or separate counter table
    result = await db.execute(select(Patient))
    count = len(result.scalars().all()) + 1
    uiid = f"HOSP-{year}-{count:05d}"

    patient = Patient(
        id=str(uuid.uuid4()),
        patient_uiid=uiid,
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
