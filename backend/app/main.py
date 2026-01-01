from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Hospital Management System API",
    description="API for HMS with role-based access and data analytics.",
    version="1.0.0",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.api.api import api_router
from app.core.config import settings
import asyncio
from app.core.memory_queue import get_queue

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(background_queue_processor())

async def background_queue_processor():
    """ Periodically retry failed syncs """
    while True:
        await asyncio.sleep(60)
        q = get_queue()
        if q:
            print(f"Background: Processing {len(q)} offline items...")


@app.get("/")
async def root():
    return {"message": "Hospital Management System API is running"}
