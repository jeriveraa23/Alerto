from app.repositories.risk_repository import RiskRepository
from sqlalchemy.orm import Session


class RiskService:

    def __init__(self, db: Session):
        self.repository = RiskRepository(db)

    def get_current(self):
        row = self.repository.get_current()
        if not row:
            return None
        return {
            "nivel_riesgo": row["nivel_riesgo"],
            "riesgo_score": row["riesgo_score"],
            "nivel_lluvia": row["nivel_lluvia"],
            "evaluated_at": row["evaluated_at"],
        }

    def get_history(self):
        rows = self.repository.get_history()
        return [
            {
                "evaluated_at": row["evaluated_at"],
                "riesgo_score": row["riesgo_score"],
                "nivel_riesgo": row["nivel_riesgo"],
            }
            for row in rows
        ]