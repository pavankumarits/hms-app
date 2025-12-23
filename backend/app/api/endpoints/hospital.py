from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.db.session import get_db
from app.models.hospital import Hospital
from app.models.user import User
from app.core.security import get_password_hash
from pydantic import BaseModel
import uuid

router = APIRouter()

class SetupRequest(BaseModel):
    hospital_name: str
    admin_username: str
    admin_password: str
    admin_pin: str # Used for local app settings protection, but we can store it too if needed

class SetupResponse(BaseModel):
    hospital_id: str
    message: str

@router.post("", response_model=SetupResponse)
async def setup_hospital(
    payload: SetupRequest, 
    db: AsyncSession = Depends(get_db)
):
    """
    Initializes a new Hospital on this server.
    Also creates the first Admin user.
    """
    # Check if a hospital already exists? (Single tenant constraint)
    # If standard is "One Laptop One Hospital", we might want to block creating a second one via API to prevent confusion.
    # But user asked for "support multiple hospitals using the SAME app", implying the APK connects to *different* servers.
    # On THIS server, there should likely only be ONE hospital.
    
    result = await db.execute(select(Hospital))
    existing_hospital = result.scalars().first()
    
    if existing_hospital:
        # If hospital exists, we just return its ID? 
        # Or error? User said "Auto-create hospital record on first connection".
        # If it exists, we assume setup is done.
        return {"hospital_id": existing_hospital.id, "message": "Hospital already registered found."}

    # Create Hospital
    hospital_id = str(uuid.uuid4())
    new_hospital = Hospital(
        id=hospital_id,
        name=payload.hospital_name,
        setup_key=payload.admin_pin 
    )
    db.add(new_hospital)

    # Create Admin User
    admin_user = User(
        id=str(uuid.uuid4()),
        hospital_id=hospital_id,
        username=payload.admin_username,
        hashed_password=get_password_hash(payload.admin_password),
        role="admin"
    )
    db.add(admin_user)

    await db.commit()
    
    return {
        "hospital_id": hospital_id,
        "message": "Hospital registered successfully"
    }
