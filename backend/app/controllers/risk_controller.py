from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.services.risk_service import RiskService

router = APIRouter(prefix="/api/risk", tags=["risk"])


@router.get("/current")
def get_current_risk(db: Session = Depends(get_db)):
    service = RiskService(db)
    result = service.get_current()
    if not result:
        raise HTTPException(status_code=404, detail="No hay datos de riesgo disponibles")
    return result


@router.get("/history")
def get_risk_history(db: Session = Depends(get_db)):
    service = RiskService(db)
    return service.get_history()