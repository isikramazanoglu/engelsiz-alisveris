from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    PROJECT_NAME: str = "Engelsiz Alışveriş API"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Database
    POSTGRES_SERVER: str
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = []

    class Config:
        case_sensitive = True
        env_file = ".env"
        extra = "ignore"

settings = Settings()
