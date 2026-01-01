from typing import Optional
from datetime import date, datetime
from pydantic import BaseModel

class PatientBase(BaseModel):
    name: str
    gender: str
    dob: date
    phone: Optional[str] = None
    address: Optional[str] = None

class PatientCreate(PatientBase):
    patient_uiid: Optional[str] = None

class PatientUpdate(PatientBase):
    pass

class PatientInDBBase(PatientBase):
    id: str
    patient_uiid: str
    hospital_id: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        orm_mode = True

class Patient(PatientInDBBase):
    pass
