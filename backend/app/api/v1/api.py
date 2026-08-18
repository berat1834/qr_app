from fastapi import APIRouter
from app.api.v1.endpoints import qr_process, security

api_router = APIRouter()

# Projede var olan endpointleri ana router'a (yönlendiriciye) ekliyoruz
api_router.include_router(qr_process.router, tags=["AI Vision"])
api_router.include_router(security.router, tags=["Cybersecurity"])