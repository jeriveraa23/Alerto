import React from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { Layout } from './components/Layout'
import { Login } from './pages/Login'
import { Precipitation } from './pages/Precipitation'
import { Risk } from './pages/Risk'
import { Simulator } from './pages/Simulator'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<Layout />}>
          <Route path="precipitation" element={<Precipitation />} />
          <Route path="risk" element={<Risk />} />
          <Route path="simulator" element={<Simulator />} />
        </Route>
        <Route path="*" element={<Navigate to="/precipitation" replace />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App