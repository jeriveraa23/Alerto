from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timezone

from risk_engine.loader import run_risk_engine


with DAG(
    dag_id="simulate_pipeline",
    schedule_interval=None,
    start_date=datetime(2025, 1, 1, tzinfo=timezone.utc),
    catchup=False,
    tags=["alerto", "simulate"],
) as dag:

    task_dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=(
            "cd /opt/dbt && "
            "dbt deps --profiles-dir /opt/dbt --project-dir /opt/dbt"
        ),
    )

    task_dbt_silver_run = BashOperator(
        task_id="dbt_run_silver",
        bash_command=(
            "cd /opt/dbt && "
            "dbt run --select silver --profiles-dir /opt/dbt --project-dir /opt/dbt"
        ),
    )

    task_dbt_gold_run = BashOperator(
        task_id="dbt_run_gold",
        bash_command=(
            "cd /opt/dbt && "
            "dbt run --select gold --profiles-dir /opt/dbt --project-dir /opt/dbt"
        ),
    )

    task_risk_engine = PythonOperator(
        task_id="run_risk_engine",
        python_callable=run_risk_engine,
    )

    task_dbt_deps >> task_dbt_silver_run >> task_dbt_gold_run >> task_risk_engine