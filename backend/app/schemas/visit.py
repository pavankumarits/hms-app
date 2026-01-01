from typing import Optional
from datetime import datetime
from pydantic import BaseModel

class VisitBase(BaseModel):
    complaint: Optional[str] = None
    diagnosis: Optional[str] = None
    treatment: Optional[str] = None
    billing_amount: Optional[float] = 0.0

class VisitCreate(VisitBase):
    patient_id: str
    doctor_id: str

class VisitUpdate(VisitBase):
    pass

class VisitInDBBase(VisitBase):
    id: str
    hospital_id: Optional[str] = None
    patient_id: str
    doctor_id: str
    visit_date: datetime
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

class Visit(VisitInDBBase):
    pass
