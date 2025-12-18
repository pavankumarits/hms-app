from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class File(Base):
    __tablename__ = "files"

    id = Column(String(36), primary_key=True, index=True)
    visit_id = Column(String(36), ForeignKey("visits.id"), nullable=True) # Optional link to visit
    file_type = Column(String(50), nullable=False) # REPORT, IMAGE, PRESCRIPTION
    file_path = Column(String(255), nullable=False) # Full path on disk
    upload_date = Column(DateTime(timezone=True), server_default=func.now())

    visit = relationship("Visit")
