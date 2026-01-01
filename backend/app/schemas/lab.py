from typing import List, Optional
from pydantic import BaseModel

class LabRecommendationInput(BaseModel):
    diagnosis: str
    age: Optional[int] = None
    gender: Optional[str] = None

class LabRecommendation(BaseModel):
    test_name: str
    priority: str
    reasoning: Optional[str] = None
