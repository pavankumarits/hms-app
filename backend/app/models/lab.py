from sqlalchemy import Column, Integer, String, Text, DateTime, Float
from sqlalchemy.sql import func
from app.db.base_class import Base

class LabProtocol(Base):
    __tablename__ = "lab_protocols"

    id = Column(Integer, primary_key=True, index=True)
    diagnosis_keyword = Column(String, index=True, nullable=False)
    test_name = Column(String, nullable=False)
    priority = Column(String, default="Recommended") # Essential, Recommended, Optional
    reasoning = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
