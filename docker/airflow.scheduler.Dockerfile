FROM apache/airflow:2.9.0

USER root
COPY entrypoint-scheduler.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER airflow
ENTRYPOINT ["/entrypoint.sh"]