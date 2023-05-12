require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'tc-weather-monitor'
  c.use_all() # enables all instrumentation!
end