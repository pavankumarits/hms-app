from fastapi import APIRouter, Depends, HTTPException
from typing import List, Dict, Optional
from pydantic import BaseModel
from app.ml.treatment_effectiveness import treatment_predictor
from app.ml.medical_nlp import medical_nlp
from app.ml.risk_predictor import risk_predictor
from app.ml.readmission_model import readmission_predictor
from app.ml.anomaly_detector import anomaly_detector
from app.ml.triage_classifier import triage_classifier
from app.ml.analytics_engine import analytics_engine

router = APIRouter()

# ... imports ...

class TriageInput(BaseModel):
    symptoms: str
    vitals: Dict[str, float]
    pain_score: int # 0-10
    consciousness: str # Alert, Confused, Unresponsive

class TriageResult(BaseModel):
    triage_level: int
    category: str
    estimated_wait_time: str
    reasoning: str

# ... code ...

@router.post("/predict-triage", response_model=TriageResult)
async def predict_triage(input_data: TriageInput):
    """
    Auto-classify patient urgency (ESI Triage).
    """
    try:
        result = triage_classifier.predict(
            symptoms=input_data.symptoms,
            vitals=input_data.vitals,
            pain_score=input_data.pain_score,
            consciousness=input_data.consciousness
        )
        return TriageResult(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Triage Classification failed: {str(e)}")


# ... imports ...

class AnomalyInput(BaseModel):
    patient_id: Optional[str] = "hypothetical"
    vitals: Dict[str, float]
    labs: Dict[str, float] = {}
    history: List[Dict[str, float]] = []

class AnomalyResult(BaseModel):
    parameter: str
    value: float
    issue: str
    reference: str
    severity: str

class AnomalyResponse(BaseModel):
    is_anomalous: bool
    anomaly_count: int
    anomalies: List[AnomalyResult]
    recommendation: str

# ... code ...

@router.post("/detect-anomalies", response_model=AnomalyResponse)
async def detect_anomalies(input_data: AnomalyInput):
    """
    Detect anomalies in vitals and labs (Statistical & Rules).
    """
    try:
        result = anomaly_detector.detect_anomalies(
            patient_id=input_data.patient_id,
            vitals=input_data.vitals,
            labs=input_data.labs,
            history=input_data.history
        )
        return AnomalyResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Anomaly Detection failed: {str(e)}")

from app.ml.medical_nlp import medical_nlp
from app.ml.risk_predictor import risk_predictor
from app.ml.readmission_model import readmission_predictor

# ... imports ...

class TreatmentInput(BaseModel):
    diagnosis: str
    age: int
    gender: str
    comorbidities: List[str]

class TreatmentPrediction(BaseModel):
    drug_name: str
    predicted_efficacy: str
    side_effect_risk: str
    reasoning: str

# ... code ...

@router.post("/predict-treatment", response_model=List[TreatmentPrediction])
async def predict_treatment(input_data: TreatmentInput):
    """
    Predict treatment effectiveness (Mock ML).
    """
    try:
        profile = {
            "age": input_data.age,
            "gender": input_data.gender,
            "comorbidities": input_data.comorbidities
        }
        results = treatment_predictor.predict(input_data.diagnosis, profile)
        return [TreatmentPrediction(**r) for r in results]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Treatment Prediction failed: {str(e)}")

from app.ml.risk_predictor import risk_predictor

# ... imports ...

class DiagnosisInput(BaseModel):
    symptoms: str
    
class DiagnosisPrediction(BaseModel):
    name: str
    confidence: int
    reasoning: str

# ... code ...

@router.post("/predict-diagnosis-nlp", response_model=List[DiagnosisPrediction])
async def predict_diagnosis_nlp(input_data: DiagnosisInput):
    """
    Predict diagnosis using BioBERT (NLP) from symptoms.
    """
    try:
        results = medical_nlp.predict_diagnosis(input_data.symptoms)
        return [DiagnosisPrediction(**r) for r in results]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"NLP Prediction failed: {str(e)}")

from app.ml.readmission_model import readmission_predictor

# ... existing imports ...

class ReadmissionInput(BaseModel):
    length_of_stay_days: int
    is_acute_admission: bool
    comorbidities: List[str]
    ed_visits_last_6m: int

class ReadmissionOutput(BaseModel):
    lace_score: int
    risk_level: str
    readmission_probability: str
    risk_factors: List[str]
    recommendation: str

# ... existing code ...

@router.post("/predict-readmission", response_model=ReadmissionOutput)
async def predict_readmission(input_data: ReadmissionInput):
    """
    Predict 30-day readmission risk using LACE index.
    """
    try:
        result = readmission_predictor.predict(
            length_of_stay_days=input_data.length_of_stay_days,
            is_acute_admission=input_data.is_acute_admission,
            comorbidities=input_data.comorbidities,
            ed_visits_last_6m=input_data.ed_visits_last_6m
        )
        return ReadmissionOutput(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

from app.api import deps
# In a real app, we'd import models to save prediction to DB
# from app.models.ml import MLRiskPrediction 
# from sqlalchemy.ext.asyncio import AsyncSession

# --- Schemas ---

class VitalsInput(BaseModel):
    systolic_bp: Optional[float] = 120
    diastolic_bp: Optional[float] = 80
    heart_rate: Optional[float] = 72
    spo2: Optional[float] = 98
    resp_rate: Optional[float] = 16
    temp: Optional[float] = 37.0

class LabResultsInput(BaseModel):
    creatinine: Optional[float] = None
    wbc: Optional[float] = None
    hemoglobin: Optional[float] = None
    # Add more as needed

class RiskPredictionInput(BaseModel):
    patient_id: Optional[str] = None # Optional if predicting for a hypothetical patient
    age: int
    gender: str
    vitals: VitalsInput
    comorbidities: List[str] = []
    lab_results: Optional[LabResultsInput] = None
    
class RiskPredictionOutput(BaseModel):
    risk_score: float
    risk_level: str
    risk_factors: List[str]
    recommendation: str

# --- Endpoints ---

@router.post("/predict-risk", response_model=RiskPredictionOutput)
async def predict_risk(input_data: RiskPredictionInput):
    """
    Predict patient deterioration risk using ML logic.
    """
    try:
        # Convert Pydantic models to dicts for the predictor
        vitals_dict = input_data.vitals.dict(exclude_none=True)
        labs_dict = input_data.lab_results.dict(exclude_none=True) if input_data.lab_results else {}
        
        result = risk_predictor.predict(
            age=input_data.age,
            gender=input_data.gender,
            vitals=vitals_dict,
            comorbidities=input_data.comorbidities,
            lab_results=labs_dict
        )
        
        return RiskPredictionOutput(**result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")
