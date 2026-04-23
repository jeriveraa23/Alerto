CREATE TABLE IF NOT EXISTS bronze_weather_current (
    id                SERIAL PRIMARY KEY,
    fetched_at        TIMESTAMPTZ NOT NULL,
    time              TIMESTAMPTZ NOT NULL,
    precipitation     FLOAT,
    rain              FLOAT,
    showers           FLOAT,
    relative_humidity FLOAT,
    cloudcover        FLOAT,
    windspeed_10m     FLOAT
);

CREATE TABLE IF NOT EXISTS bronze_weather_hourly (
    id                SERIAL PRIMARY KEY,
    fetched_at        TIMESTAMPTZ NOT NULL,
    time              TIMESTAMPTZ UNIQUE NOT NULL,
    precipitation     FLOAT,
    rain              FLOAT,
    showers           FLOAT,
    relative_humidity FLOAT,
    cloudcover        FLOAT,
    windspeed_10m     FLOAT
);

CREATE TABLE IF NOT EXISTS alerts (
      id                SERIAL PRIMARY KEY,
      evaluated_at      TIMESTAMPTZ NOT NULL,
      precip_1h         FLOAT NOT NULL,
      precip_3h         FLOAT NOT NULL,
      intensidad_actual FLOAT NOT NULL,
      humedad_prom_6h   FLOAT NOT NULL,
      nivel_lluvia      FLOAT NOT NULL,
      riesgo_score      FLOAT NOT NULL,
      nivel_riesgo      VARCHAR(10) NOT NULL
  );