import React, { useState } from 'react';
import { Card } from '../components/Card';
import { Play } from 'lucide-react';
import './Simulator.css';

const PRESETS = {
verde:    { label: 'Verde',    precip_1h: 0,  precip_3h: 0,  humedad: 30 },
amarillo: { label: 'Amarillo', precip_1h: 10, precip_3h: 20, humedad: 70 },
naranja:  { label: 'Naranja',  precip_1h: 18, precip_3h: 35, humedad: 85 },
rojo:     { label: 'Rojo',     precip_1h: 40, precip_3h: 75, humedad: 95 },
};

export const Simulator = () => {
const [precip1h,      setPrecip1h]      = useState(0);
const [precip3h,      setPrecip3h]      = useState(0);
const [humedad,       setHumedad]       = useState(50);
const [presetActivo,  setPresetActivo]  = useState(null);
const [estado,        setEstado]        = useState(null);
const [mensaje,       setMensaje]       = useState('');

const aplicarPreset = (key) => {
    const p = PRESETS[key];
    setPrecip1h(p.precip_1h);
    setPrecip3h(p.precip_3h);
    setHumedad(p.humedad);
    setPresetActivo(key);
    setEstado(null);
};

const handlePrecip1h = (val) => {
    const v = Math.min(Number(val), 50);
    setPrecip1h(v);
    if (precip3h < v) setPrecip3h(v);
    setPresetActivo(null);
};

const handlePrecip3h = (val) => {
    const v = Math.min(Number(val), 90);
    setPrecip3h(Math.max(v, precip1h));
    setPresetActivo(null);
};

const handleHumedad = (val) => {
    setHumedad(Math.min(Number(val), 100));
    setPresetActivo(null);
};

const ejecutar = async () => {
    setEstado('loading');
    setMensaje('');
    try {
    const res = await fetch('/api/simulate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ precip_1h: precip1h, precip_3h: precip3h, humedad }),
    });
    const data = await res.json();
    if (res.ok) {
        setEstado('ok');
        setMensaje(data.message);
    } else {
        setEstado('error');
        setMensaje(data.detail || 'Error desconocido');
    }
    } catch (err) {
    setEstado('error');
    setMensaje('No se pudo conectar con el servidor.');
    }
};

return (
    <div className="page-container">
    <div className="dashboard-header">
        <div>
        <h1>Simulador</h1>
        <p className="text-muted">
            Ingresa datos crudos de precipitación y humedad para disparar el pipeline completo
        </p>
        </div>
    </div>

    <Card title="Escenarios Predefinidos">
        <div className="preset-buttons">
        {Object.entries(PRESETS).map(([key, p]) => (
            <button
            key={key}
            className={`preset-btn preset-${key} ${presetActivo === key ? 'active' : ''}`}
            onClick={() => aplicarPreset(key)}
            >
            {p.label}
            </button>
        ))}
        </div>
        <p className="text-muted preset-hint">
        Selecciona un escenario para pre-cargar los valores, o ajústalos manualmente.
        </p>
    </Card>

    <Card title="Parámetros de Entrada">
        <div className="sim-fields">

        <div className="sim-field">
            <div className="sim-field-header">
            <label>Precipitación última hora</label>
            <span className="sim-field-value">{precip1h} mm</span>
            </div>
            <input
            type="range" min={0} max={50} step={0.5}
            value={precip1h}
            onChange={(e) => handlePrecip1h(e.target.value)}
            className="sim-slider"
            />
            <div className="sim-range-labels"><span>0 mm</span><span>50 mm</span></div>
        </div>

        <div className="sim-field">
            <div className="sim-field-header">
            <label>Precipitación últimas 3 horas</label>
            <span className="sim-field-value">{precip3h} mm</span>
            </div>
            <input
            type="range" min={0} max={90} step={0.5}
            value={precip3h}
            onChange={(e) => handlePrecip3h(e.target.value)}
            className="sim-slider"
            />
            <div className="sim-range-labels"><span>0 mm</span><span>90 mm</span></div>
        </div>

        <div className="sim-field">
            <div className="sim-field-header">
            <label>Humedad promedio 6 horas</label>
            <span className="sim-field-value">{humedad}%</span>
            </div>
            <input
            type="range" min={0} max={100} step={1}
            value={humedad}
            onChange={(e) => handleHumedad(e.target.value)}
            className="sim-slider"
            />
            <div className="sim-range-labels"><span>0%</span><span>100%</span></div>
        </div>

        </div>

        <button
        className="btn-primary sim-execute-btn"
        onClick={ejecutar}
        disabled={estado === 'loading'}
        >
        <Play size={18} />
        {estado === 'loading' ? 'Ejecutando...' : 'Ejecutar Simulación'}
        </button>
    </Card>

    {estado && (
        <Card title="Estado del Pipeline">
        <div className={`sim-status sim-status-${estado}`}>
            {estado === 'loading' && (
            <p>Insertando datos y disparando el pipeline. Esto puede tomar 2–3 minutos...</p>
            )}
            {estado === 'ok' && (
            <>
                <p>{mensaje}</p>
                <p className="sim-status-hint">
                Revisa la página de <strong>Riesgo</strong> para ver el resultado
                una vez el pipeline termine.
                </p>
            </>
            )}
            {estado === 'error' && <p>{mensaje}</p>}
        </div>
        </Card>
    )}
    </div>
);
};