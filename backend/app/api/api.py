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
