class OpenWeatherApiConnector
  include HTTParty
  default_options.update(verify: false) #skip ssl verification

  base_uri ENV['OPEN_WEATHER_API_URL']

  def initialize
    @api_key = ENV['OPEN_WEATHER_API_KEY']
  end

  def geocode_location(location)
    MyAppTracer.in_span('api_geocode_location_call') do |span|
      geocoder_results = Rails.cache.fetch([:geocode_lookup, location.gsub(' ','').to_sym], expires_in: 1.day) do
        self.class.get('/geo/1.0/direct', query: {q: location, limit: 1, appid: @api_key})
      end

      return geocoder_results.first
    end
  end

  def get_weather_by_coord(lat, lon)
    MyAppTracer.in_span('api_get_weather_by_coord_call') do |span|
      response = Rails.cache.fetch([:weather_xy_lookup, lat, lon], expires_in: 10.minutes) do
        self.class.get('/data/2.5/weather', query: {lat: lat, lon: lon, appid: @api_key, units: 'metric'})
      end

      return response
    end
  end


end