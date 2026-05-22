import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Droplets, Mail, Lock, ShieldQuestion } from 'lucide-react';
import './Login.css';

export const ResetPassword = () => {
const [step,             setStep]             = useState(1);
const [email,            setEmail]            = useState('');
const [question,         setQuestion]         = useState('');
const [answer,           setAnswer]           = useState('');
const [newPassword,      setNewPassword]      = useState('');
const [error,            setError]            = useState('');
const [loading,          setLoading]          = useState(false);
const navigate = useNavigate();

const handleGetQuestion = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
    const res = await fetch(`/api/auth/security-question?email=${encodeURIComponent(email)}`);
    const data = await res.json();
    if (res.ok) {
        setQuestion(data.security_question);
        setStep(2);
    } else {
        setError(data.detail || 'Correo no encontrado.');
    }
    } catch {
    setError('No se pudo conectar con el servidor.');
    } finally {
    setLoading(false);
    }
};

const handleReset = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
    const res = await fetch('/api/auth/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, answer, new_password: newPassword }),
    });
    const data = await res.json();
    if (res.ok) {
        navigate('/login');
    } else {
        setError(data.detail || 'Error al restablecer la contraseña.');
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
        <h1>Restablecer Contraseña</h1>
        <p className="text-muted">
            {step === 1 ? 'Ingresa tu correo para continuar' : 'Responde tu pregunta de seguridad'}
        </p>
        </div>

        {step === 1 && (
        <form onSubmit={handleGetQuestion} className="login-form">
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

            {error && <p className="auth-error">{error}</p>}

            <button type="submit" className="btn-primary login-btn" disabled={loading}>
            {loading ? 'Buscando...' : 'Continuar'}
            </button>

            <p className="auth-footer">
            <Link to="/login" className="forgot-password">Volver al inicio de sesión</Link>
            </p>
        </form>
        )}

        {step === 2 && (
        <form onSubmit={handleReset} className="login-form">
            <div className="form-group">
            <label className="form-label">Pregunta de Seguridad</label>
            <div className="input-wrapper">
                <ShieldQuestion className="input-icon" size={18} />
                <input
                type="text"
                className="form-input with-icon"
                value={question}
                disabled
                />
            </div>
            </div>

            <div className="form-group">
            <label className="form-label">Respuesta</label>
            <div className="input-wrapper">
                <ShieldQuestion className="input-icon" size={18} />
                <input
                type="text"
                className="form-input with-icon"
                placeholder="Tu respuesta"
                value={answer}
                onChange={(e) => setAnswer(e.target.value)}
                required
                />
            </div>
            </div>

            <div className="form-group">
            <label className="form-label">Nueva Contraseña</label>
            <div className="input-wrapper">
                <Lock className="input-icon" size={18} />
                <input
                type="password"
                className="form-input with-icon"
                placeholder="Mínimo 6 caracteres"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                required
                />
            </div>
            </div>

            {error && <p className="auth-error">{error}</p>}

            <button type="submit" className="btn-primary login-btn" disabled={loading}>
            {loading ? 'Actualizando...' : 'Restablecer Contraseña'}
            </button>
        </form>
        )}
    </div>
    </div>
);
};