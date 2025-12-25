from typing import Optional
from pydantic import BaseModel, ConfigDict

class UserBase(BaseModel):
    username: Optional[str] = None
    role: Optional[str] = "staff"
    is_active: Optional[bool] = True

class UserCreate(UserBase):
    username: str
    password: str
    role: str

class UserUpdate(UserBase):
    password: Optional[str] = None

class UserInDBBase(UserBase):
    id: Optional[str] = None # ID is a UUID string, not int
    username: str

    model_config = ConfigDict(from_attributes=True)

class User(UserInDBBase):
    pass
