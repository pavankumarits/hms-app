from sqlalchemy import Column, Integer, String, Text, DateTime, Float
from sqlalchemy.sql import func
from app.db.base_class import Base

class DosageProtocol(Base):
    __tablename__ = "dosage_protocols"

    id = Column(Integer, primary_key=True, index=True)
    drug_name = Column(String, index=True, nullable=False)
    min_age_months = Column(Integer, default=0)
    max_age_months = Column(Integer, default=1200) # 100 years
    min_weight_kg = Column(Float, default=0.0)
    max_weight_kg = Column(Float, default=200.0)
    
    dosage_per_kg_mg = Column(Float, nullable=False) # e.g. 15mg/kg
    max_daily_dose_mg = Column(Float, nullable=True) # e.g. 4000mg
    frequency_hours = Column(Integer, nullable=True) # e.g. 6 (every 6 hours)
    form = Column(String, default="Syrup") # Syrup, Tablet, Injection
    concentration_mg_per_ml = Column(Float, nullable=True) # e.g. 120mg/5ml -> 24.0
    
    instructions = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
