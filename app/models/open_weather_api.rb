class OpenWeatherApi
  attr_accessor :raw_weather_report

  def initialize
    @connection = OpenWeatherApiConnector.new
  end

  def format_report(report)
    formatted_report = {
      location: "#{report['name']}, #{report['sys']['country']}",
      coord: report['coord'],
      weather: {
        main: report['weather'][0]['main'],
        description: report['weather'][0]['description'],
        temperatures_c: {
          temp: report['main']['temp'],
          feels_like: report['main']['feels_like'],
          min: report['main']['temp_min'],
          max: report['main']['temp_max']
        },
        others: {
          pressure_hPa: report['main']['pressure'],
          humidity: report['main']['humidity']
        }
      }
    }
  end

  def get_weather_for_location(location)
    MyAppTracer.in_span('get_weather_for_location') do |span|
      geocoded_location = @connection.geocode_location(location)

      @raw_weather_report = @connection.get_weather_by_coord(geocoded_location['lat'], geocoded_location['lon'])

      return format_report(@raw_weather_report)
    end
  end
end