FROM python:3.11-slim

WORKDIR /dbt

RUN pip install dbt-postgres

COPY . .

CMD ["tail", "-f", "/dev/null"]