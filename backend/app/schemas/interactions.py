from typing import List, Optional
from pydantic import BaseModel

class AuditInput(BaseModel):
    new_drug: str
    current_meds: List[str]

class InteractionAlert(BaseModel):
    interacting_drug: str
    severity: str
    description: str
    management: Optional[str] = None

class AuditOutput(BaseModel):
    interactions: List[InteractionAlert]
    is_safe: bool
