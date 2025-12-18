from typing import Any, List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.api import deps
from app.db.session import get_db
from app.models.audit import AuditLog
from app.models.user import User

router = APIRouter()

# Schema for AuditLog (Basic)
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class AuditLogSchema(BaseModel):
    id: str
    user_id: Optional[str]
    action: str
    resource: Optional[str]
    details: Optional[str]
    timestamp: datetime
    
    class Config:
        orm_mode = True

@router.get("/", response_model=List[AuditLogSchema])
async def read_audit_logs(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.get_current_active_superuser),
) -> Any:
    result = await db.execute(select(AuditLog).order_by(AuditLog.timestamp.desc()).offset(skip).limit(limit))
    return result.scalars().all()
