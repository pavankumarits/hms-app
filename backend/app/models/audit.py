from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=True) # Nullable if system action or logout
    action = Column(String(50), nullable=False) # LOGIN, LOGOUT, CREATE_PATIENT, etc.
    resource = Column(String(50), nullable=True) # Table name or module
    details = Column(Text, nullable=True) # JSON or text details
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User")
