# **Diagrama de Arquitectura**

![Diagrama Arquitectura Alerto](https://github.com/user-attachments/assets/b50f5548-ec58-4e76-a9fa-cbc5567f4dbd)


# **Modelo de Base de Datos**

<img width="6096" height="3148" alt="Modelo de base de datos" src="https://github.com/user-attachments/assets/c31da684-0813-410e-b84b-738a788d70c0" />


# **Ramas y su propósito**

# feature/airflow-pipeline
Acá construimos los DAGs de airflow que será el que se encargue de extraer la información de la API automáticamente cada x tiempo, también se encarga de cargar los datos en PostgreSQL en una de las 3 capas de la arquitectura que tendremos en la parte de la BD. Osea, la automatización del pipeline.

# feature/dbt-models
Acá se hace la transformación de los datos extraído y cargados a postgres, se hace la limpieza y la validación de datos, construcción de las otras dos capas(silver y gold) y el cálculo de métricas como precipitación acumulada

# feature/backend-api
Acá vamos a desarrollar todo el back finalizando con la API que consumirá el front y el sistema de alertas con twilio, esta parte consulta los datos de la capa gold de la BD.

# feature/backend-api
Acá implementamos de lógica de riesgo con la lógica difusa, se evalúan las condiciones de precipitación y se determina el nivel de riesgo, si es bajo, medio o alto.

# feature/risk-engine
Acá se desarrolla el microservicio de alertas integrando con twilio, ósea, el envío de SMS basado en los eventos de riesgos y la construcción y formateo del mensaje

# feature/frontend-ui
Acá desarrollamos la interfaz del front, habíamos dicho que posiblemente con react, acá se visualizan los datos de riesgo y del clima, se consume la API del backend y construcción de dashboard.

# feature/docker-setup
Acá configuramos el docker-compose para contenerizar todo, los Dockerfile para la instalación de dependencias en cada contenedor y comandos básicos de configuración para cada contener, acá integramos todos los módulos.
