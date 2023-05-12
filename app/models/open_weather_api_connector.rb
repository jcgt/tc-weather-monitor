class OpenWeatherApiConnector
  include HTTParty
  default_options.update(verify: false) #skip ssl verification

  base_uri ENV['OPEN_WEATHER_API_URL']

  def initialize
    @api_key = ENV['OPEN_WEATHER_API_KEY']
  end

  def geocode_location(location)
    geocoder_results = self.class.get('/geo/1.0/direct',
      query: {q: location, limit: 1, appid: @api_key})

    location = geocoder_results.first

    return location
  end

  def get_weather_by_coord(lat, lon)
    response = self.class.get('/data/2.5/weather',
      query: {lat: lat, lon: lon, appid: @api_key, units: 'metric'})

    return response
  end


end