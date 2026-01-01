from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class DiseaseProtocol(Base):
    __tablename__ = "disease_protocols"

    id = Column(Integer, primary_key=True, index=True)
    disease_name = Column(String, index=True, nullable=False)
    drug_name = Column(String, nullable=False)
    line_of_treatment = Column(Integer)
    min_age = Column(Integer, default=0)
    max_age = Column(Integer, default=120)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class DrugInteraction(Base):
    __tablename__ = "drug_interactions"

    id = Column(Integer, primary_key=True, index=True)
    drug_a = Column(String, index=True, nullable=False)
    drug_b = Column(String, index=True, nullable=False)
    severity = Column(String)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
