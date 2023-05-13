require 'opentelemetry/sdk'
require 'opentelemetry-exporter-otlp'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry/semantic_conventions'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'tc-weather-monitor'
  c.use_all() # enables all instrumentation!
end

MyAppTracer = OpenTelemetry.tracer_provider.tracer('tcwm-tracer')