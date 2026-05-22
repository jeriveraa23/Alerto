import os
import requests
from requests.auth import HTTPBasicAuth

TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID")
TWILIO_AUTH_TOKEN  = os.getenv("TWILIO_AUTH_TOKEN")
TWILIO_FROM        = os.getenv("TWILIO_FROM")
TWILIO_TO          = os.getenv("TWILIO_TO")


def send_sms(message: str):
    url = f"https://api.twilio.com/2010-04-01/Accounts/{TWILIO_ACCOUNT_SID}/Messages.json"

    response = requests.post(
        url,
        data={
            "To":   TWILIO_TO,
            "From": TWILIO_FROM,
            "Body": message,
        },
        auth=HTTPBasicAuth(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN),
        timeout=10,
    )

    if response.status_code not in (200, 201):
        raise Exception(
            f"Error al enviar SMS: {response.status_code} — {response.text}"
        )