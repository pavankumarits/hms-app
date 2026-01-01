from typing import List, Optional
from pydantic import BaseModel

class RiskInput(BaseModel):
    age: int
    gender: str
    systolic_bp: Optional[int] = None # e.g. 120
    diastolic_bp: Optional[int] = None # e.g. 80
    conditions: List[str] = [] # List of known diagnosis/conditions e.g. ["Diabetes", "Asthma"]
    lifestyle_factors: List[str] = [] # e.g. ["Smoker", "Obesity"]

class RiskFactorContributor(BaseModel):
    factor: str
    points: int
    category: str

class RiskAssessmentOutput(BaseModel):
    total_score: int
    risk_level: str # Low, Medium, High
    contributors: List[RiskFactorContributor]
    recommendation: str
