from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.api import deps
from app.db.session import get_db
from app.models.visit import Visit
from app.schemas.visit import VisitCreate, Visit as VisitSchema

router = APIRouter()

@router.get("/", response_model=List[VisitSchema])
async def read_visits(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user = Depends(deps.get_current_user),
) -> Any:
    result = await db.execute(select(Visit).offset(skip).limit(limit))
    return result.scalars().all()

@router.post("/", response_model=VisitSchema)
async def create_visit(
    *,
    db: AsyncSession = Depends(get_db),
    visit_in: VisitCreate,
    current_user = Depends(deps.get_current_user),
) -> Any:
    import uuid
    visit = Visit(
        id=str(uuid.uuid4()),
        patient_id=visit_in.patient_id,
        doctor_id=visit_in.doctor_id,
        complaint=visit_in.complaint,
        diagnosis=visit_in.diagnosis,
        treatment=visit_in.treatment,
        billing_amount=visit_in.billing_amount
    )
    db.add(visit)
    await db.commit()
    await db.refresh(visit)
    return visit
