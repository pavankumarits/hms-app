from typing import Any
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, Form
from sqlalchemy.ext.asyncio import AsyncSession
from app.api import deps
from app.core.config import settings
from app.db.session import get_db
from app.models.file import File as FileModel
import shutil
import os
import datetime
import uuid

router = APIRouter()

@router.post("/upload/")
async def upload_file(
    file: UploadFile = File(...),
    visit_id: str = Form(None),
    file_type: str = Form("REPORT"),
    db: AsyncSession = Depends(get_db),
    current_user = Depends(deps.get_current_user),
) -> Any:
    # C:\HospitalData\Reports\YYYY\MM\
    now = datetime.datetime.now()
    year = now.strftime("%Y")
    month = now.strftime("%m")
    
    directory = os.path.join(settings.UPLOAD_DIR, year, month)
    os.makedirs(directory, exist_ok=True)
    
    # Generate unique filename
    file_location = os.path.join(directory, f"{uuid.uuid4()}_{file.filename}")
    
    # Save file
    with open(file_location, "wb+") as file_object:
        shutil.copyfileobj(file.file, file_object)
    
    # Create DB Record
    db_file = FileModel(
        id=str(uuid.uuid4()),
        visit_id=visit_id,
        file_type=file_type,
        file_path=file_location
    )
    db.add(db_file)
    await db.commit()
    await db.refresh(db_file)
        
    return {"info": "File uploaded", "id": db_file.id, "path": file_location}
