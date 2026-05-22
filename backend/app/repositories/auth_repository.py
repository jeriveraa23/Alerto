from sqlalchemy import text
from sqlalchemy.orm import Session


class AuthRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_user_by_email(self, email: str):
        result = self.db.execute(
            text("SELECT * FROM users WHERE email = :email"),
            {"email": email}
        )
        return result.mappings().first()

    def create_user(self, nombre: str, email: str, password_hash: str,
                    security_question: str, security_answer: str):
        self.db.execute(
            text("""
                INSERT INTO users (nombre, email, password_hash, security_question, security_answer)
                VALUES (:nombre, :email, :password_hash, :security_question, :security_answer)
            """),
            {
                "nombre":            nombre,
                "email":             email,
                "password_hash":     password_hash,
                "security_question": security_question,
                "security_answer":   security_answer,
            }
        )
        self.db.commit()

    def update_password(self, email: str, password_hash: str):
        self.db.execute(
            text("UPDATE users SET password_hash = :password_hash WHERE email = :email"),
            {"password_hash": password_hash, "email": email}
        )
        self.db.commit()