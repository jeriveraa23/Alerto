from sqlalchemy import text
from sqlalchemy.orm import Session


class RiskRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_current(self):
        result = self.db.execute(text("""
            SELECT nivel_riesgo, riesgo_score, nivel_lluvia, evaluated_at
            FROM public.alerts
            ORDER BY evaluated_at DESC
            LIMIT 1
        """))
        return result.mappings().first()

    def get_history(self):
        result = self.db.execute(text("""
            SELECT evaluated_at, riesgo_score, nivel_riesgo
            FROM public.alerts
            ORDER BY evaluated_at DESC
        """))
        return result.mappings().all()