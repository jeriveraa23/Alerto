import React from 'react';
import { NavLink } from 'react-router-dom';
import { Droplets, AlertTriangle, FlaskConical } from 'lucide-react';
import './Sidebar.css';

export const Sidebar = () => {
  const menuItems = [
    { path: '/precipitation', name: 'Precipitación', icon: Droplets },
    { path: '/risk', name: 'Riesgo', icon: AlertTriangle },
    { path: '/simulator',     name: 'Simulador',     icon: FlaskConical  },
  ];

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <div className="logo-container">
          <Droplets className="logo-icon" size={28} />
          <span className="logo-text">Alerto</span>
        </div>
      </div>
      <nav className="sidebar-nav">
        <ul className="nav-list">
          {menuItems.map((item) => (
            <li key={item.path} className="nav-item">
              <NavLink
                to={item.path}
                className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
              >
                <item.icon size={20} className="nav-icon" />
                <span>{item.name}</span>
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>
      <div className="sidebar-footer">
        <div className="system-status">
          <div className="status-indicator online"></div>
          <span>Sistema en línea</span>
        </div>
      </div>
    </aside>
  );
};