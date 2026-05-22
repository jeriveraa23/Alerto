import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Droplets, Lock, Mail, User, ShieldQuestion } from 'lucide-react';
import './Login.css';

const SECURITY_QUESTIONS = [
'¿Cuál es el nombre de tu primera mascota?',
'¿En qué ciudad naciste?',
'¿Cuál es el nombre de tu mejor amigo de la infancia?',
'¿Cuál es el nombre de tu escuela primaria?',
'¿Cuál es tu comida favorita?',
];

export const Register = () => {
const [nombre,            setNombre]            = useState('');
const [email,             setEmail]             = useState('');
const [password,          setPassword]          = useState('');
const [securityQuestion,  setSecurityQuestion]  = useState(SECURITY_QUESTIONS[0]);
const [securityAnswer,    setSecurityAnswer]    = useState('');
const [error,             setError]             = useState('');
const [loading,           setLoading]           = useState(false);
const navigate = useNavigate();

const handleRegister = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
    const res = await fetch('/api/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
        nombre,
        email,
        password,
        security_question: securityQuestion,
        security_answer:   securityAnswer,
        }),
    });
    const data = await res.json();
    if (res.ok) {
        navigate('/login');
    } else {
        setError(data.detail || 'Error al registrarse.');
    }
    } catch {
    setError('No se pudo conectar con el servidor.');
    } finally {
    setLoading(false);
    }
};

return (
    <div className="login-container">
    <div className="login-card glass-panel">
        <div className="login-header">
        <div className="logo-circle">
            <Droplets size={32} className="logo-icon-large" />
        </div>
        <h1>Crear Cuenta</h1>
        <p className="text-muted">Completa los datos para registrarte</p>
        </div>

        <form onSubmit={handleRegister} className="login-form">
        <div className="form-group">
            <label className="form-label">Nombre</label>
            <div className="input-wrapper">
            <User className="input-icon" size={18} />
            <input
                type="text"
                className="form-input with-icon"
                placeholder="Tu nombre completo"
                value={nombre}
                onChange={(e) => setNombre(e.target.value)}
                required
            />
            </div>
        </div>

        <div className="form-group">
            <label className="form-label">Correo Electrónico</label>
            <div className="input-wrapper">
            <Mail className="input-icon" size={18} />
            <input
                type="email"
                className="form-input with-icon"
                placeholder="usuario@alerto.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
            />
            </div>
        </div>

        <div className="form-group">
            <label className="form-label">Contraseña</label>
            <div className="input-wrapper">
            <Lock className="input-icon" size={18} />
            <input
                type="password"
                className="form-input with-icon"
                placeholder="Mínimo 6 caracteres"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
            />
            </div>
        </div>

        <div className="form-group">
            <label className="form-label">Pregunta de Seguridad</label>
            <div className="input-wrapper">
            <ShieldQuestion className="input-icon" size={18} />
            <select
                className="form-input with-icon"
                value={securityQuestion}
                onChange={(e) => setSecurityQuestion(e.target.value)}
            >
                {SECURITY_QUESTIONS.map((q) => (
                <option key={q} value={q}>{q}</option>
                ))}
            </select>
            </div>
        </div>

        <div className="form-group">
            <label className="form-label">Respuesta de Seguridad</label>
            <div className="input-wrapper">
            <Lock className="input-icon" size={18} />
            <input
                type="text"
                className="form-input with-icon"
                placeholder="Tu respuesta"
                value={securityAnswer}
                onChange={(e) => setSecurityAnswer(e.target.value)}
                required
            />
            </div>
        </div>

        {error && <p className="auth-error">{error}</p>}

        <button type="submit" className="btn-primary login-btn" disabled={loading}>
            {loading ? 'Registrando...' : 'Crear Cuenta'}
        </button>

        <p className="auth-footer">
            ¿Ya tienes cuenta? <Link to="/login" className="forgot-password">Inicia sesión</Link>
        </p>
        </form>
    </div>
    </div>
);
};