import os
import bcrypt
import jwt
from datetime import datetime, timezone, timedelta
from sqlalchemy.orm import Session
from app.repositories.auth_repository import AuthRepository

JWT_SECRET  = os.getenv("JWT_SECRET", "alerto_secret")
JWT_EXPIRES = 24  # horas


class AuthService:

    def __init__(self, db: Session):
        self.repository = AuthRepository(db)

    def register(self, nombre: str, email: str, password: str,
                security_question: str, security_answer: str) -> dict:
        if self.repository.get_user_by_email(email):
            raise ValueError("El correo ya está registrado.")

        password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(12)).decode()
        answer_hash   = bcrypt.hashpw(security_answer.lower().encode(), bcrypt.gensalt(12)).decode()

        self.repository.create_user(nombre, email, password_hash, security_question, answer_hash)
        return {"message": "Usuario registrado exitosamente."}

    def login(self, email: str, password: str) -> dict:
        user = self.repository.get_user_by_email(email)
        if not user:
            raise ValueError("Credenciales inválidas.")

        if not bcrypt.checkpw(password.encode(), user["password_hash"].encode()):
            raise ValueError("Credenciales inválidas.")

        token = jwt.encode(
            {
                "sub":   user["email"],
                "name":  user["nombre"],
                "exp":   datetime.now(timezone.utc) + timedelta(hours=JWT_EXPIRES),
            },
            JWT_SECRET,
            algorithm="HS256",
        )
        return {"access_token": token, "token_type": "bearer"}

    def verify_security_answer(self, email: str, answer: str) -> bool:
        user = self.repository.get_user_by_email(email)
        if not user:
            raise ValueError("Correo no encontrado.")
        return bcrypt.checkpw(answer.lower().encode(), user["security_answer"].encode())

    def reset_password(self, email: str, answer: str, new_password: str) -> dict:
        if not self.verify_security_answer(email, answer):
            raise ValueError("Respuesta de seguridad incorrecta.")

        password_hash = bcrypt.hashpw(new_password.encode(), bcrypt.gensalt(12)).decode()
        self.repository.update_password(email, password_hash)
        return {"message": "Contraseña actualizada exitosamente."}

    def get_security_question(self, email: str) -> str:
        user = self.repository.get_user_by_email(email)
        if not user:
            raise ValueError("Correo no encontrado.")
        return user["security_question"]