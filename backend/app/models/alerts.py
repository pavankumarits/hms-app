from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class ClinicalAlertRule(Base):
    __tablename__ = "clinical_alert_rules"

    id = Column(Integer, primary_key=True, index=True)
    alert_name = Column(String, index=True, nullable=False) # e.g. "Mammogram Screening"
    target_gender = Column(String, default="All") # All, Male, Female
    min_age = Column(Integer, default=0)
    max_age = Column(Integer, default=120)
    condition_keyword = Column(String, nullable=True) # If set, patient must have this condition
    alert_message = Column(Text, nullable=False)
    priority = Column(String, default="Medium") # Low, Medium, High
    reference_guideline = Column(String, nullable=True) # e.g. "WHO", "ADA"
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
