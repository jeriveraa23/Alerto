#!/bin/bash

mkdir -p /opt/dbt/logs
chmod -R 777 /opt/dbt/logs

echo "Esperando a Postgres..."
until gosu airflow airflow db check; do
  echo "Postgres no está listo, esperando..."
  sleep 5
done

if [ ! -f "/opt/airflow/airflow.db_initialized" ]; then
  echo "Inicializando DB..."
  gosu airflow airflow db upgrade

  echo "Creando usuario admin..."
  gosu airflow airflow users create \
    --username admin \
    --password admin \
    --firstname admin \
    --lastname admin \
    --role Admin \
    --email admin@mail.com || true

  touch /opt/airflow/airflow.db_initialized
fi

echo "Iniciando webserver..."
exec gosu airflow airflow webserver