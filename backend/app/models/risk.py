from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class RiskRule(Base):
    __tablename__ = "risk_rules"

    id = Column(Integer, primary_key=True, index=True)
    condition_keyword = Column(String, index=True, nullable=False) # e.g. "Diabetes", "Smoker"
    risk_points = Column(Integer, nullable=False) # e.g. 10
    category = Column(String, default="Chronic") # Chronic, Vitals, Lifestyle, Demographics
    description = Column(String, nullable=True) # e.g. "Increases cardiovascular risk"
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
