from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Enum
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import enum

class PaymentStatus(str, enum.Enum):
    PAID = "paid"
    UNPAID = "unpaid"
    PARTIAL = "partial"

class Bill(Base):
    __tablename__ = "bills"

    id = Column(String(36), primary_key=True, index=True)
    visit_id = Column(String(36), ForeignKey("visits.id", ondelete="CASCADE"), nullable=False)
    amount = Column(Float, nullable=False)
    status = Column(String(20), default=PaymentStatus.UNPAID)
    payment_method = Column(String(50), nullable=True)
    
    generated_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    visit = relationship("Visit", backref="bill")
