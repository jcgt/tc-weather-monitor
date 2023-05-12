class Api::V1::WeathersController < ApplicationController

  def city_lookup
    location = params[:location]
    segments = location.split(',')
    segments.map{|x| x.strip}
    owa = OpenWeatherApi.new
    report = owa.get_weather_for_location(segments.join(','))

    render json: format_report(report)
  end


  private

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

end