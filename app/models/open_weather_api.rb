class OpenWeatherApi
  def initialize
    @connection = OpenWeatherApiConnector.new
  end

  def get_weather_for_location(location)
    geocoded_location = @connection.geocode_location(location)

    weather = @connection.get_weather_by_coord(geocoded_location['lat'], geocoded_location['lon'])

    return weather
  end
end