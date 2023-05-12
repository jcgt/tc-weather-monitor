require 'rails_helper'

RSpec.describe OpenWeatherApiConnector do
  context 'when connecting to the OpenWeather API' do
    it 'should send a proper geocode request for a location' do
      stub_request(:get, "https://api.openweathermap.org/geo/1.0/direct").
      with(
        query: hash_including({'limit' => '1','q' => 'Paris, FR', 'appid' => ENV['OPEN_WEATHER_API_KEY']})
        ).
      to_return(status: 200, body: '{}', headers: {content_type: 'application/json'})

      connector = OpenWeatherApiConnector.new

      result = connector.geocode_location('Paris, FR')
    end

    it 'should send a proper weather request for a set of coordinates' do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather").
      with(
        query: hash_including({'lat' => '44.34', 'lon' => '10.99', 'appid' => ENV['OPEN_WEATHER_API_KEY'], 'units' => 'metric'})
        ).
      to_return(status: 200, body: '{}', headers: {content_type: 'application/json'})

      connector = OpenWeatherApiConnector.new

      result = connector.get_weather_by_coord(44.34,10.99)

    end
  end
end