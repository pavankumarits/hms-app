from typing import Optional
from pydantic import BaseModel

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
    id: Optional[int] = None
    username: str

    class Config:
        orm_mode = True

class User(UserInDBBase):
    pass
