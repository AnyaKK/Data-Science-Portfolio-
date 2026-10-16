# OpenWeather five-day forecast exercise in R

This coursework draft is intended to request five-day forecast data for Seoul, Washington, D.C., Paris and Suzhou with the OpenWeather API and `httr`. It prepares fields for weather, visibility, temperature, pressure, humidity, wind, forecast time and season.

## File

- [weather-forecast.R](weather-forecast.R)

## Configuration

Create an OpenWeather API key and provide it through the environment rather than placing it in the script:

```bash
export OPENWEATHER_API_KEY='your-key'
Rscript weather-forecast.R
```

Use the equivalent environment-variable command for your shell.

## Status

This is a learning exercise, not a verified forecast client. The current loop iterates the top-level parsed response instead of the response's forecast list and appends most fields outside the inner loop. Review and test the parsing logic before depending on its dataframe.

