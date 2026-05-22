def build_message(nivel_riesgo: str) -> str | None:
    if nivel_riesgo == "NARANJA":
        return (
            "⚠️ Alerta moderada: se registran precipitaciones significativas "
            "en tu sector. Mantente atento."
        )
    elif nivel_riesgo == "ROJO":
        return (
            "🚨 Alerta crítica: se registran precipitaciones extremas "
            "en tu sector. Toma precauciones inmediatas."
        )
    return None