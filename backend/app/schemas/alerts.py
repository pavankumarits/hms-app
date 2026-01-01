from typing import List, Optional
from pydantic import BaseModel

class AlertInput(BaseModel):
    age: int
    gender: str
    conditions: List[str] = []

class AlertOutput(BaseModel):
    alert_name: str
    message: str
    priority: str
    reference: Optional[str] = None

class AlertCheckResponse(BaseModel):
    alerts: List[AlertOutput]
    total_alerts: int
