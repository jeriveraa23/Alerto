from fastapi import FastAPI
from app.controllers.risk_controller import router as risk_router
from app.controllers.precipitation_controller import router as precipitation_router

app = FastAPI(title="Alerto API")

app.include_router(risk_router)
app.include_router(precipitation_router)
