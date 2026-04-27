from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.services.precipitation_service import PrecipitationService

router = APIRouter(prefix="/api/precipitation", tags=["precipitation"])


@router.get("/current")
def get_current_precipitation(db: Session = Depends(get_db)):
    service = PrecipitationService(db)
    result = service.get_current()
    if not result:
        raise HTTPException(status_code=404, detail="No hay datos de precipitación disponibles")
    return result


@router.get("/history")
def get_precipitation_history(db: Session = Depends(get_db)):
    service = PrecipitationService(db)
    return service.get_history()