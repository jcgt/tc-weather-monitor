# README

## Simple Weather API and Monitoring Integration

This is a simple weather API that uses OpenWeatherMap to show a weather summary (returned as a json payload) for a specified city. It uses OpenTelemetry for monitoring that can be configured to output to console or to Jaeger. It also supports basic caching for the API it connects to as a means of increasing throughput and reducing the number of calls to the OpenWeatherMap endpoints.

The application takes a city name and a two letter country code as input. It then takes that combination and uses OpenWeatherMap's geocoding service to get the approximate Lattitide and Longitude coordinates for that city. Those coordinates are then used to fetch the weather report for that location.

This can be used as a quick city weather lookup tool for any external service.

## Installation
The app requires Ruby 3.1.2 and uses Rails 7.0.4. It also requires Postgres 12* to use. You will also need an OpenWeatherMap account (https://openweathermap.org/).

*The DB isn't actually used but the initial Rails scaffold was done with the assumption that a DB was needed and its a pain to disable/remove it after the fact.

To install, just clone the repo:

`git clone git@github.com:jcgt/tc-weather-monitor.git`

 and run bundler within the cloned directory:

 `bundle install`

You will also need to set the following variables in your environment:
```
DB_HOST=your_dbhost
DB_USERNAME=your_username
DB_PASSWORD=your_password

OPEN_WEATHER_API_URL=https://api.openweathermap.org
#different subs might have differnt urls

OPEN_WEATHER_API_KEY=your_api_key

OTEL_TRACES_EXPORTER=console
#comment out this line above to send traces to your local Jaeger server

```
The project uses the dotenv gem so you can create and populate a .env file in your application home directory.

To start the app you will need a database called `tc_weather_monitor_development` on your PG server. Again this will not be used by the app but Rails will look for it on startup due to its configuration. No migrations are needed to be run.

Startup is your usual Rails affair: `bundle exec rails server`

There are RSpec unit tests included. To run them you will need a db named `tc_weather_monitor_test`. As with before, no migrations are needed to be run.

To run the tests just run RSpec: `bundle exec rspec`

The tests use webmock instead of connecting to the OpenWeatherMap API itself. The tests check that the correct request is sent to the API. It also tests for proper operation by returning a mocked result for the tests that require an API response.

To enable caching run: `bundle exec rails dev:cache`

This currently caches the city search Lat/Lon coordinates for 24 hours (or until server reboot). This could actually be set much longer as cities don't usually get up and walk around but the expiry is in case of data corrections.

In addition to caching the city Lat/Lon coordinates, the weather report for the location itself (as defined by the Lat/Lon coordinates) is cached for 10 minutes as this is the update frequency of OpenWeatherMap itself.

**Note:** The free OWM account has a limit of 60 calls per minute.

## Usage
The API only has one endpoint:

`/api/v1/weather/city_lookup`

To perform a lookup simply do a GET to the API endpoint with a `location` url query parameter. The location querystring must contain the city name and the country's ISO-3166 2-letter country code separated by a comma: `Toronto,CA`

`http://localhost:3000/api/v1/weather/city_lookup?location=Toronto,CA`



The response will be a JSON payload containing the name of the matched location, the coordinates, and a weather summary:
```
{"location":"Downtown Toronto, CA","coord":{"lon":-79.3839,"lat":43.6535},"weather":{"main":"Clouds","description":"overcast clouds","temperatures_c":{"temp":20.43,"feels_like":19.52,"min":18.93,"max":23.31},"others":{"pressure_hPa":1021,"humidity":38}}}
```

For locations in the US you can add the 2-letter state code before the country code in order to differentiate similar city names, like Las Vegas, New Mexico:

`http://localhost:3000/api/v1/weather/city_lookup?location=Las Vegas,NM,US`
```
{"location":"Las Vegas, US","coord":{"lon":-105.2239,"lat":35.5939},"weather":{"main":"Clouds","description":"broken clouds","temperatures_c":{"temp":14.65,"feels_like":13.5,"min":13.38,"max":14.85},"others":{"pressure_hPa":1025,"humidity":51}}}
```

For certain cities, the returned location name may refer to a district within the city.

`http://localhost:3000/api/v1/weather/city_lookup?location=Tokyo,JP`
```
{"location":"Marunouchi, JP","coord":{"lon":139.763,"lat":35.679},"weather":{"main":"Clouds","description":"broken clouds","temperatures_c":{"temp":16.19,"feels_like":16.06,"min":14.04,"max":17.7},"others":{"pressure_hPa":1017,"humidity":84}}}
```

## Monitoring
The application uses OpenTelemetry to monitor performance and log errors. There are spans defined for the API calls to OpenWeatherMap to measure response times, at the core business logic, and at the API's own entry endpoint as well. The environment variable `OTEL_TRACES_EXPORTER=console` will output the traces to console. If you have a Jaeger server running on your local, you can comment out that environment variable and it will push the traces to the default Jaeger endpoint.

## Design
The application follows separation of concerns. The API connection logic for connecting to OpenWeatherMap is in its own model, `OpenWeatherApiConnector`, while the business logic itself is in `OpenWeatherApi`. The controller `Api::V1::WeathersController` just facilitates operation by doing some light input cleanup and returning the processed result.

## Recommended Improvements
### Dump The Database "Requirement"
The initial scaffold assumed that the project needed a database but at the end of the day it never really needed one. It would be best to remove the unneeded database connection so as to make the app lighter and the installation easier. Unfortunately, due to Rails' design, its not a quick and trivial task to do.

### Expand Input Possibilities
The initial implementation only followed one of the Geocoder's accepted use cases. We can expand the implementation by using other acceptable location markers like zipcodes and perhaps even accpeting raw Lat/Lon coordinates, bypassing the Geocoder for such requests. We can also expand useability by accepting full country names and their variants by using the Countries gem to facilitate converting country names into their ISO-3166 alpha-2 codes.

### Improve Error Handling
Right now the application assumes the inputs are valid. There needs to be error recovery code in place to handle out of scope inputs and to handle potential errors from the OpenWeatherMap API side.

### Improve Monitoring
Given that I am new to OpenTelemetry and I literally just studied it, I'm sure there are ways to improve my current telemetry implementation.

### Improve The Test Organization
The test mocks/stubs are currently in-line. The test payloads shoud be in their own file.

### Setup An External Cache Server
Since this is just a proof-of-concept the caching mechanism is just the memory store. Ideally in a real production environment this should be an external service like Memcached or Redis to provide wide scaling friendly and server-reboot independent caching.