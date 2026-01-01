from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class DrugInteraction(Base):
    __tablename__ = "drug_interactions"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, index=True)
    drug_a = Column(String, index=True, nullable=False) # e.g. "Warfarin"
    drug_b = Column(String, index=True, nullable=False) # e.g. "Aspirin"
    severity = Column(String, default="Major") # Major, Moderate, Minor
    description = Column(Text, nullable=False) # e.g. "Increased risk of bleeding"
    management = Column(String, nullable=True) # e.g. "Monitor INR closely"
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
