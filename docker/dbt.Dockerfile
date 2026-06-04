FROM python:3.11-slim

WORKDIR /dbt

RUN pip install --upgrade pip --timeout 120 --retries 5 \
    && pip install dbt-postgres==1.8.2 --timeout 120 --retries 5

RUN printf '#!/bin/bash\nset -e\necho "Instalando paquetes dbt..."\ndbt deps --project-dir /dbt --profiles-dir /dbt\nexec "$@"\n' > /entrypoint.sh && chmod +x /entrypoint.sh

COPY . .

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]