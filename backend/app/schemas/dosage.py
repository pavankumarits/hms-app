from typing import Optional
from pydantic import BaseModel

class DosageInput(BaseModel):
    drug_name: str
    age_years: float
    weight_kg: float
    form: Optional[str] = "Syrup" # Syrup, Tablet

class DosageRecommendation(BaseModel):
    drug_name: str
    calculated_dose_mg: float
    calculated_dose_ml: Optional[float] = None
    frequency: str
    max_daily_dose_mg: Optional[float] = None
    instructions: Optional[str] = None
    warning: Optional[str] = None
