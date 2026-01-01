from fastapi import APIRouter
from pydantic import BaseModel
from app.ml.readmission_model import readmission_predictor

router = APIRouter()

class ReadmissionInput(BaseModel):
    age: int
    visits_last_30_days: int
    chronic_condition_count: int
    days_since_discharge: int

class ReadmissionOutput(BaseModel):
    risk_score: float
    risk_level: str
    recommendation: str

@router.post("/predict-readmission", response_model=ReadmissionOutput)
async def predict_readmission(data: ReadmissionInput):
    """
    Predict probability of machine learning readmission.
    """
    result = readmission_predictor.predict(
        data.age,
        data.visits_last_30_days,
        data.chronic_condition_count,
        data.days_since_discharge
    )
    
    risk_level = result["risk_level"]
    recommendation = "Maintain standard discharge protocol."
    
    if risk_level == "High":
        recommendation = "Enroll in Intensive Care Management (ICM) program. Schedule follow-up in 3 days."
    elif risk_level == "Medium":
        recommendation = "Schedule follow-up call within 7 days. Review medication adherence."
        
    return ReadmissionOutput(
        risk_score=result["readmission_probability"],
        risk_level=risk_level,
        recommendation=recommendation
    )
