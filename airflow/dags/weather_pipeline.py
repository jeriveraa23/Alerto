from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timezone

from elt.extract import OpenMeteoCurrentExtractor, OpenMeteoHourlyExtractor
from elt.transform import transform_current, transform_hourly
from elt.load import load_current, load_hourly


def run_current_pipeline():
    extractor = OpenMeteoCurrentExtractor()
    raw       = extractor.extract()
    df        = transform_current(raw)
    load_current(df)


def run_hourly_pipeline():
    extractor = OpenMeteoHourlyExtractor()
    raw       = extractor.extract()
    df        = transform_hourly(raw)
    load_hourly(df)


with DAG(
    dag_id="weather_pipeline",
    schedule_interval="*/15 * * * *",
    start_date=datetime(2025, 1, 1, tzinfo=timezone.utc),
    catchup=False,
    tags=["alerto", "weather"],
) as dag:

    task_current = PythonOperator(
        task_id="extract_transform_load_current",
        python_callable=run_current_pipeline,
    )

    task_hourly = PythonOperator(
        task_id="extract_transform_load_hourly_",
        python_callable=run_hourly_pipeline,
    )

    task_current >> task_hourly