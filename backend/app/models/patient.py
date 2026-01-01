from sqlalchemy import Column, Integer, String, Date, Text, DateTime, UniqueConstraint
from sqlalchemy.sql import func
from app.db.base_class import Base

class Patient(Base):
    __tablename__ = "patients"

    id = Column(String(36), primary_key=True, index=True)
    hospital_id = Column(String(36), nullable=False, index=True)
    patient_uiid = Column(String(20), index=True) # HOSP-YYYY-XXXX
    name = Column(String(100), index=True, nullable=False)
    gender = Column(String(10), nullable=False)
    dob = Column(Date, nullable=False)
    phone = Column(String(15), nullable=True)

    __table_args__ = (
        UniqueConstraint('hospital_id', 'patient_uiid', name='uq_hospital_patient_uiid'),
    )
    address = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    sync_status = Column(String(20), default="synced")
