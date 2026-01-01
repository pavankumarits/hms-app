from typing import List, Optional
from pydantic import BaseModel

class DiagnosisInput(BaseModel):
    diagnosis: str
    age: int
    gender: Optional[str] = None

class DrugSuggestion(BaseModel):
    drug_name: str
    match_score: int
    line_of_treatment: int
    is_safe: bool = True
    warning: Optional[str] = None

class SafetyCheckInput(BaseModel):
    proposed_drug: str
    current_meds: List[str]

class SafetyCheckResult(BaseModel):
    is_safe: bool
    warnings: List[str]

# --- NEW: Symptom Checker Models ---
class SymptomInput(BaseModel):
    symptoms: str # e.g. "headache, high fever"

class DiagnosisSuggestion(BaseModel):
    name: str
    confidence: int
