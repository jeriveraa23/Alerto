#!/bin/bash

echo "Esperando a Postgres..."

# Esperar hasta que la DB responda de verdad
until airflow db check; do
  echo "Postgres no está listo, esperando..."
  sleep 5
done

# Inicialización SOLO una vez
if [ ! -f "/opt/airflow/airflow.db_initialized" ]; then
  echo "Inicializando DB..."
  airflow db upgrade

  echo "Creando usuario admin..."
  airflow users create \
    --username admin \
    --password admin \
    --firstname admin \
    --lastname admin \
    --role Admin \
    --email admin@mail.com || true

  touch /opt/airflow/airflow.db_initialized
fi

echo "Iniciando webserver..."
exec airflow webserver