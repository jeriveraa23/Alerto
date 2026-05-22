from alert_service.message_builder import build_message
from alert_service.sender import send_sms

def send_alert(nivel_riesgo: str):
    message = build_message(nivel_riesgo)
    if message:
        send_sms(message)