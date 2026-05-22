from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session
from app.db import get_db
from app.services.auth_service import AuthService

router = APIRouter(prefix="/api/auth", tags=["auth"])


class RegisterRequest(BaseModel):
    nombre:            str   = Field(..., min_length=2)
    email:             EmailStr
    password:          str   = Field(..., min_length=6)
    security_question: str
    security_answer:   str


class LoginRequest(BaseModel):
    email:    EmailStr
    password: str


class SecurityQuestionRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    email:        EmailStr
    answer:       str
    new_password: str = Field(..., min_length=6)


@router.post("/register")
def register(body: RegisterRequest, db: Session = Depends(get_db)):
    service = AuthService(db)
    try:
        return service.register(
            body.nombre, body.email, body.password,
            body.security_question, body.security_answer
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/login")
def login(body: LoginRequest, db: Session = Depends(get_db)):
    service = AuthService(db)
    try:
        return service.login(body.email, body.password)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))


@router.get("/security-question")
def get_security_question(email: str, db: Session = Depends(get_db)):
    service = AuthService(db)
    try:
        question = service.get_security_question(email)
        return {"security_question": question}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/reset-password")
def reset_password(body: ResetPasswordRequest, db: Session = Depends(get_db)):
    service = AuthService(db)
    try:
        return service.reset_password(body.email, body.answer, body.new_password)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))