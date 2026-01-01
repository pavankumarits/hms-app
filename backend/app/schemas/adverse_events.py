from typing import List, Optional
from pydantic import BaseModel

class AdverseCheckInput(BaseModel):
    symptoms: List[str]
    current_meds: List[str]

class AdverseMatch(BaseModel):
    drug_name: str
    side_effect: str
    likelihood: str # e.g. "Common"
    description: Optional[str] = None

class AdverseCheckOutput(BaseModel):
    matches: List[AdverseMatch]
    total_matches: int
