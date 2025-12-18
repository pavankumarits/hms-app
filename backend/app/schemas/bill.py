from typing import Optional
from datetime import datetime
from pydantic import BaseModel

class BillBase(BaseModel):
    amount: float
    status: str = "unpaid"
    payment_method: Optional[str] = None

class BillCreate(BillBase):
    visit_id: str

class BillUpdate(BillBase):
    pass

class BillInDBBase(BillBase):
    id: str
    visit_id: str
    generated_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True

class Bill(BillInDBBase):
    pass
