require 'rails_helper'

RSpec.describe OpenWeatherApi do
  context 'when looking up a city' do
    it 'should return a proper result' do

      geo_result = [{"name"=>"Paris", "lat"=>43.193234, "lon"=>-80.384281, "country"=>"CA", "state"=>"Ontario"}]
      stub_request(:get, "https://api.openweathermap.org/geo/1.0/direct").
      with(
        query: hash_including({'limit' => '1','q' => 'Paris, CA', 'appid' => ENV['OPEN_WEATHER_API_KEY']})
        ).
      to_return(status: 200, body: geo_result.to_json, headers: {content_type: 'application/json'})

      weather_report = {
        "coord"=>{"lon"=>-80.3842, "lat"=>43.1932},
        "weather"=>[{"id"=>804, "main"=>"Clouds", "description"=>"overcast clouds", "icon"=>"04d"}],
        "base"=>"stations",
        "main"=>{
          "temp"=>22.75,
          "feels_like"=>22.26,
          "temp_min"=>21.05,
          "temp_max"=>24.32,
          "pressure"=>1020,
          "humidity"=>45,
          "sea_level"=>1020,
           "grnd_level"=>993},
        "visibility"=>10000,
        "wind"=>{"speed"=>0.74, "deg"=>240, "gust"=>0.98},
        "clouds"=>{"all"=>100},
        "dt"=>1683902091,
        "sys"=>{"type"=>2, "id"=>2002529, "country"=>"CA", "sunrise"=>1683885681, "sunset"=>1683938072},
        "timezone"=>-14400,
        "id"=>6942553,
        "name"=>"Paris",
        "cod"=>200
      }
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather").
      with(
        query: hash_including({'lat' => geo_result[0]['lat'].to_s, 'lon' => geo_result[0]['lon'].to_s, 'appid' => ENV['OPEN_WEATHER_API_KEY'], 'units' => 'metric'})
        ).
      to_return(status: 200, body: weather_report.to_json, headers: {content_type: 'application/json'})

      owa = OpenWeatherApi.new
      result = owa.get_weather_for_location('Paris, CA')
    end
  end
end