class Api::V1::WeathersController < ApplicationController

  def city_lookup
    MyAppTracer.in_span('city_lookup') do |span|
      location = params[:location]
      segments = location.split(',')
      segments.map{|x| x.strip}
      owa = OpenWeatherApi.new
      report = owa.get_weather_for_location(segments.join(','))

      render json: report
    end
  end

end