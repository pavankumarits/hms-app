from fastapi import APIRouter
from app.api.endpoints import login, users, patients, visits, files, audit, analytics, billing

api_router = APIRouter()
api_router.include_router(login.router, tags=["login"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(patients.router, prefix="/patients", tags=["patients"])
api_router.include_router(visits.router, prefix="/visits", tags=["visits"])
api_router.include_router(files.router, prefix="/files", tags=["files"])
api_router.include_router(audit.router, prefix="/audit-logs", tags=["audit"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
from app.api.endpoints import sync
api_router.include_router(sync.router, prefix="/sync", tags=["sync"])
api_router.include_router(billing.router, prefix="/billing", tags=["billing"])

from app.api.endpoints import hospital
api_router.include_router(hospital.router, prefix="/setup", tags=["setup"])

from app.api.endpoints import smart_doctor
api_router.include_router(smart_doctor.router, prefix="/smart-doctor", tags=["smart-doctor"])

from app.api.endpoints import lab_recommendations
api_router.include_router(lab_recommendations.router, prefix="/labs", tags=["labs"])

from app.api.endpoints import dosage_calculator
api_router.include_router(dosage_calculator.router, prefix="/dosage", tags=["dosage"])

from app.api.endpoints import risk_scoring
api_router.include_router(risk_scoring.router, prefix="/risk", tags=["risk"])

from app.api.endpoints import clinical_alerts
api_router.include_router(clinical_alerts.router, prefix="/alerts", tags=["alerts"])

from app.api.endpoints import adverse_events
api_router.include_router(adverse_events.router, prefix="/adverse-events", tags=["adverse-events"])

from app.api.endpoints import prescription_audit
api_router.include_router(prescription_audit.router, prefix="/prescription", tags=["prescription"])

from app.api.endpoints import analytics
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])

from app.api.endpoints import ml_predictions
api_router.include_router(ml_predictions.router, prefix="/ml", tags=["ml-predictions"])
