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