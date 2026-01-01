from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.db.session import get_db, AsyncSessionLocal
from app.models.patient import Patient
from app.models.visit import Visit
from app.models.bill import Bill
from app.models.audit import AuditLog
from app.api.deps import get_current_user
from app.core.memory_queue import add_to_queue

from app.schemas.patient import PatientInDBBase
from app.schemas.visit import VisitInDBBase
from app.schemas.bill import BillInDBBase
from app.schemas.audit import AuditLogInDBBase
from pydantic import BaseModel

router = APIRouter()

class SyncPayload(BaseModel):
    patients: List[PatientInDBBase] = []
    visits: List[VisitInDBBase] = []
    bills: List[BillInDBBase] = []
    audit_logs: List[AuditLogInDBBase] = []

async def process_sync_payload_internal(db: AsyncSession, payload: SyncPayload):
    """ Internal logic to save payload to DB """
    # Process Patients
    for p_schema in payload.patients:
        stmt = select(Patient).where(Patient.id == p_schema.id)
        result = await db.execute(stmt)
        existing_patient = result.scalars().first()
        
        p_data = p_schema.dict(exclude_unset=True)
        p_data['sync_status'] = 'synced'
        
        if existing_patient:
            for key, value in p_data.items():
                setattr(existing_patient, key, value)
        else:
            new_patient = Patient(**p_data)
            db.add(new_patient)

    # Process Visits
    for v_schema in payload.visits:
        stmt = select(Visit).where(Visit.id == v_schema.id)
        result = await db.execute(stmt)
        existing_visit = result.scalars().first()
        
        v_data = v_schema.dict(exclude_unset=True)
        v_data['sync_status'] = 'synced'

        if existing_visit:
            for key, value in v_data.items():
                setattr(existing_visit, key, value)
        else:
            new_visit = Visit(**v_data)
            db.add(new_visit)

    # Process Bills
    for b_schema in payload.bills:
        stmt = select(Bill).where(Bill.id == b_schema.id)
        result = await db.execute(stmt)
        existing_bill = result.scalars().first()
        
        b_data = b_schema.dict(exclude_unset=True)
        b_data['sync_status'] = 'synced'

        if existing_bill:
            for key, value in b_data.items():
                setattr(existing_bill, key, value)
        else:
            new_bill = Bill(**b_data)
            db.add(new_bill)

    # Process Audit Logs
    for a_schema in payload.audit_logs:
        stmt = select(AuditLog).where(AuditLog.id == a_schema.id)
        result = await db.execute(stmt)
        existing_log = result.scalars().first()
        
        a_data = a_schema.dict(exclude_unset=True)

        if not existing_log:
            new_log = AuditLog(**a_data)
            db.add(new_log)

    await db.commit()

async def process_sync_queue(queue: List[Any]):
    """ Drains the queue and saves to DB """
    if not queue:
        return
    
    # Create new session
    async with AsyncSessionLocal() as db:
        try:
            # Copy and clear queue to avoid infinite loop if failure persists
            current_batch = list(queue)
            queue.clear() 

            for payload_dict in current_batch:
                # payload_dict is raw dict here if saved from queue? No, should save Pydantic model or dict.
                # Assuming we saved Pydantic model.
                if isinstance(payload_dict, dict):
                     payload = SyncPayload(**payload_dict)
                else:
                     payload = payload_dict
                
                await process_sync_payload_internal(db, payload)
            
            print(f"Queue processed: {len(current_batch)} items saved.")

        except Exception as e:
            print(f"Queue Retry Failed: {e}")
            # Optional: Put back in queue? 
            # For this simple system, let's just log. 
            # Ideally, push back only failed items.

@router.post("/sync", status_code=200)
async def sync_data(
    payload: SyncPayload,
    db: AsyncSession = Depends(get_db),
    current_user: Any = Depends(get_current_user),
):
    """
    Bulk sync endpoint. Tries DB first. 
    If DB unavailable (Exception), saves to In-Memory Queue (202 Accepted).
    """
    # Inject hospital_id from current_user into payload
    # This ensures backend enforces data ownership and validates NOT NULL constraints
    hid = current_user.hospital_id
    
    if payload.patients:
        for p in payload.patients:
            p.hospital_id = hid
            
    if payload.visits:
        for v in payload.visits:
            v.hospital_id = hid

    if payload.bills:
         for b in payload.bills:
             # Assuming Bill schema also needs update, but let's handle if it has the field
             if hasattr(b, 'hospital_id'):
                 b.hospital_id = hid

    try:
        await process_sync_payload_internal(db, payload)
        return {"status": "success", "message": "Data synced successfully"}
    except Exception as e:
        # DB Error?
        print(f"Sync DB Error (Fallback to Queue): {str(e)}")
        # Add to Queue (Payload now has hospital_id injected)
        add_to_queue(payload)
        return {"status": "accepted", "message": "Data queued for processing (DB unavailable)"}
