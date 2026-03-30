#!/bin/bash

echo "Esperando a la DB..."
sleep 15

echo "Iniciando scheduler..."
exec airflow scheduler