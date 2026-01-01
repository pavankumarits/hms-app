from pydantic_settings import BaseSettings
from typing import Optional
from pydantic import validator

class Settings(BaseSettings):
    PROJECT_NAME: str = "Hospital Management System"
    TUNNEL_URL: Optional[str] = None # Cloudflare Tunnel URL
    API_V1_STR: str = "/api/v1"
    
    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["*"]
    
    # Text
    SECRET_KEY: str = "YOUR_SECRET_KEY_HERE"  # Change this in production!
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Uploads
    UPLOAD_DIR: str = r"C:\HospitalData\Reports"

    # Database
    # Format: mysql+aiomysql://user:password@host/db_name
    DATABASE_URL: str = "postgresql+asyncpg://user:password@host:port/dbname"

    @validator("DATABASE_URL", pre=True)
    def assemble_db_connection(cls, v: Optional[str]) -> str:
        if isinstance(v, str):
            if v.startswith("postgresql://"):
                v = v.replace("postgresql://", "postgresql+asyncpg://")
            if "sslmode=require" in v:
                v = v.replace("sslmode=require", "ssl=require")
        return v

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
