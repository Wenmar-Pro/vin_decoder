# VinDecoder

vin_decoder is a lightweight Ruby client for the NHTSA vPIC API. It decodes 17-character VINs and exposes a tidy domain object so you can access make, model, year, powertrain data, and more without sifting through raw JSON.

## Installation

Add the gem to your project (when published):

```ruby
gem 'vin_decoder'
```

Or install directly from source:

```bash
git clone https://github.com/Wenmar-Pro/vin_decoder.git
cd vin_decoder
bundle install
```

## Configuration

Use the top-level `VinDecoder.configure` block to customize the base URL (handy for mocking) or request timeout. Defaults target the official NHTSA API with a 10-second timeout.

```ruby
VinDecoder.configure do |config|
  config.base_url = 'https://vpic.nhtsa.dot.gov/api/vehicles'
  config.timeout = 5
end
```

## Usage

```ruby
client = VinDecoder::Client.new
vehicle = client.decode('1HGCM82633A004352')

if vehicle.valid?
  puts [vehicle.year, vehicle.make, vehicle.model].compact.join(' ')
  puts "Engine: #{vehicle.engine} (#{vehicle.engine_cylinders} cylinders)"
  puts "Fuel: #{vehicle.fuel_type}"
  puts "Fuel type (raw accessor): #{vehicle['FuelTypePrimary']}"
  puts "Lot size (dynamic): #{vehicle.lot_size}"
else
  warn 'VIN could not be decoded'
end
```

The client raises:

- `VinDecoder::NotFoundError` when the API responds with HTTP 404.
- `VinDecoder::ApiError` for any other non-200 HTTP status code.

Each `VinDecoder::Vehicle` exposes the entire response payload:

- Common helper methods (`make`, `model`, `trim`, `engine`, etc.).
- Hash-style access with string or symbol keys (`vehicle['ModelYear']` / `vehicle[:ModelYear]`).
- Dynamic snake_case readers derived from the raw keys (`vehicle.vehicle_descriptor`, `vehicle.fuel_type_secondary`). Missing fields raise `NoMethodError` so mistakes are caught quickly.

## Rails Integration

Add the gem to your Rails app (from RubyGems or a local path while developing).

```ruby
# Gemfile
gem 'vin_decoder', path: '../path/to/vin_decoder'
```

Create an initializer to configure timeouts and base URL:

```ruby
# config/initializers/vin_decoder.rb
VinDecoder.configure do |config|
  config.timeout = ENV.fetch('VIN_DECODER_TIMEOUT', 5).to_i
  config.base_url = ENV.fetch('VIN_DECODER_BASE_URL', 'https://vpic.nhtsa.dot.gov/api/vehicles')
end
```

Wrap the client in a PORO/service for controllers or jobs:

```ruby
# app/services/vin_lookup.rb
class VinLookup
  def initialize(client: VinDecoder::Client.new)
    @client = client
  end

  def call(vin)
    vehicle = @client.decode(vin)
    raise VinDecoder::NotFoundError unless vehicle.valid?

    vehicle
  end
end
```

Example controller usage:

```ruby
class VehiclesController < ApplicationController
  def show
    @vehicle = VinLookup.new.call(params[:vin])
  rescue VinDecoder::NotFoundError
    redirect_to root_path, alert: 'VIN not found'
  end
end
```

You can also enqueue lookups via ActiveJob/Sidekiq and cache results to avoid repeated external calls.

## Testing & VCR Cassettes

Tests run via RSpec and rely on VCR/WebMock for deterministic HTTP interactions.

```bash
bundle exec rspec
```

To refresh the live cassette, delete `spec/fixtures/vcr_cassettes/decode_success.yml` and rerun the specs. VCR will connect to the real API once, capture the response, and reuse it on subsequent runs.

## Publishing Checklist

1. Ensure version in `lib/vin_decoder/version.rb` reflects the release.
2. Update `CHANGELOG` or release notes as needed (add one if not yet created).
3. Build the gem and inspect the package contents:

   ```bash
   gem build vin_decoder.gemspec
   gem install vin_decoder-<version>.gem
   ```

4. Push the artifact to RubyGems:

   ```bash
   gem push vin_decoder-<version>.gem
   ```

5. Tag the release in git and push tags to GitHub for reference.

That’s it—you now have a fully tested VIN decoder client ready for reuse or publication.
