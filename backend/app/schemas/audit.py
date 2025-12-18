from typing import Optional
from datetime import datetime
from pydantic import BaseModel

class AuditLogBase(BaseModel):
    action: str
    resource: Optional[str] = None
    details: Optional[str] = None

class AuditLogCreate(AuditLogBase):
    user_id: Optional[str] = None

class AuditLogInDBBase(AuditLogBase):
    id: str
    user_id: Optional[str]
    timestamp: datetime

    class Config:
        orm_mode = True

class AuditLog(AuditLogInDBBase):
    pass
