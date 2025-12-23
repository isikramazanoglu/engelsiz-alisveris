from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# PostgreSQL connection string
# TODO: Move to env variables via Pydantic settings
SQLALCHEMY_DATABASE_URL = "postgresql://postgres:12345@localhost/engelsiz_db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
