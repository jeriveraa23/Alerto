import os
import bcrypt
from sqlalchemy import create_engine, text

DB_CONN = os.getenv("DATABASE_URL")

def seed_admin():
    engine = create_engine(DB_CONN)
    with engine.begin() as conn:
        existing = conn.execute(
            text("SELECT id FROM users WHERE email = 'admin@alerto.com'")
        ).fetchone()

        if existing:
            print("Admin ya existe, omitiendo seed.")
            return

        password_hash = bcrypt.hashpw(b"alerto123**", bcrypt.gensalt(12)).decode()
        answer_hash   = bcrypt.hashpw(b"admin", bcrypt.gensalt(12)).decode()

        conn.execute(
            text("""
                INSERT INTO users (nombre, email, password_hash, security_question, security_answer)
                VALUES (:nombre, :email, :password_hash, :security_question, :security_answer)
            """),
            {
                "nombre":            "Administrador",
                "email":             "admin@alerto.com",
                "password_hash":     password_hash,
                "security_question": "¿Cuál es el nombre de tu primera mascota?",
                "security_answer":   answer_hash,
            }
        )
        print("Admin creado exitosamente.")


if __name__ == "__main__":
    seed_admin()