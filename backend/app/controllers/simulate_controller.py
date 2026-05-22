from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from app.db import get_db
from app.services.simulate_service import SimulateService

router = APIRouter(prefix="/api/simulate", tags=["simulate"])


class SimulateRequest(BaseModel):
    precip_1h: float = Field(..., ge=0, le=50)
    precip_3h: float = Field(..., ge=0, le=90)
    humedad:   float = Field(..., ge=0, le=100)


@router.post("")
def run_simulation(body: SimulateRequest, db: Session = Depends(get_db)):
    if body.precip_3h < body.precip_1h:
        raise HTTPException(
            status_code=422,
            detail="precip_3h debe ser mayor o igual a precip_1h"
        )
    service = SimulateService(db)
    try:
        return service.run(body.precip_1h, body.precip_3h, body.humedad)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))