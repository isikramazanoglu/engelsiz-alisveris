from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
import time

from app.core.config import settings
from app.api.v1.api import api_router

# Logging Setup
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    description="Görme engelli bireyler için sesli asistan ve alışveriş API servisi."
)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    formatted_process_time = "{0:.2f}".format(process_time)
    logger.info(f"path={request.url.path} method={request.method} status={response.status_code} duration={formatted_process_time}ms")
    return response

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global error occurred: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"message": "Internal Server Error"},
    )


app.include_router(api_router, prefix=settings.API_V1_STR)


# Güvenlik: CORS Ayarları
# Mobil uygulamanın API ile konuşabilmesi için gereklidir.
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

@app.get("/")
async def root():
    """
    Kök dizin - Sağlık kontrolü için basit bir mesaj döner.
    """
    return {
        "message": "Engelsiz Alışveriş API Çalışıyor",
        "docs_url": "/docs",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    """
    Load Balancer veya Kubernetes için sağlık kontrol noktası.
    """
    return {"status": "healthy"}
