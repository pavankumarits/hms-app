from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.api import deps
from app.db.session import get_db
from app.models.bill import Bill
from app.schemas.bill import BillCreate, Bill as BillSchema, BillUpdate # Need to create schema
import uuid

router = APIRouter()

@router.get("/", response_model=List[BillSchema])
async def read_bills(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user = Depends(deps.get_current_user),
) -> Any:
    result = await db.execute(select(Bill).offset(skip).limit(limit))
    return result.scalars().all()

@router.post("/", response_model=BillSchema)
async def create_bill(
    *,
    db: AsyncSession = Depends(get_db),
    bill_in: BillCreate,
    current_user = Depends(deps.get_current_user),
) -> Any:
    bill = Bill(
        id=str(uuid.uuid4()),
        visit_id=bill_in.visit_id,
        amount=bill_in.amount,
        status=bill_in.status,
        payment_method=bill_in.payment_method
    )
    db.add(bill)
    await db.commit()
    await db.refresh(bill)
    return bill
