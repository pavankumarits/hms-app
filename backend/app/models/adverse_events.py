from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class DrugSideEffect(Base):
    __tablename__ = "drug_side_effects"

    id = Column(Integer, primary_key=True, index=True)
    drug_name = Column(String, index=True, nullable=False) # e.g. "Lisinopril"
    side_effect = Column(String, index=True, nullable=False) # e.g. "Cough"
    frequency = Column(String, default="Common") # Common, Rare, Unknown
    severity = Column(String, default="Mild") # Mild, Moderate, Severe
    description = Column(String, nullable=True) # e.g. "Dry, persistent cough"
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
