# frozen_string_literal: true

require_relative 'lib/vin_decoder/version'

Gem::Specification.new do |spec|
  spec.name          = 'vin_decoder'
  spec.version       = VinDecoder::VERSION
  spec.authors       = ["Ben D'Angelo"]
  spec.email         = ['ben@bendangelo.me']

  spec.summary       = 'A Ruby client for the NHTSA vPIC VIN decoding API.'
  spec.description   = 'Decodes 17-character VINs to provide vehicle specifications like make, model, and engine type.'
  spec.homepage      = 'https://github.com/Wenmar-Pro/vin_decoder'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']

  # Runtime Dependencies
  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'json', '>= 0'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  # Development Dependencies
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
