from sqlalchemy import Column, String, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class Hospital(Base):
    __tablename__ = "hospitals"

    id = Column(String(36), primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    setup_key = Column(String(255), nullable=True) # Admin PIN
    created_at = Column(DateTime(timezone=True), server_default=func.now())
