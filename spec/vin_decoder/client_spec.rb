# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VinDecoder::Client do
  let(:client) { described_class.new }
  let(:vin) { '1HGCM82633A004352' }

  describe '#decode' do
    it 'returns a vehicle for a valid VIN', :aggregate_failures do
      vehicle = VCR.use_cassette('decode_success') do
        client.decode(vin)
      end

      expect(vehicle).to be_a(VinDecoder::Vehicle)
      expect(vehicle.valid?).to be(true)
      expect(vehicle.make).to eq('HONDA')
      expect(vehicle.model).to eq('Accord')
      expect(vehicle.trim).to eq('EX-V6')
      expect(vehicle.year).to eq('2003')
      expect(vehicle.engine_cylinders).to eq('6')
      expect(vehicle.engine).to eq('V-Shaped')
      expect(vehicle.fuel_type).to eq('Gasoline')
    end

    it 'raises NotFoundError when the API responds with 404' do
      stub_request(:get, 'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValuesExtended/INVALIDVIN1234567?format=json')
        .to_return(status: 404, body: '{}', headers: {})

      expect { client.decode('INVALIDVIN1234567') }.to raise_error(VinDecoder::NotFoundError)
    end

    it 'raises ApiError for other HTTP errors' do
      stub_request(:get, 'https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValuesExtended/ERRORVIN12345678?format=json')
        .to_return(status: 500, body: 'Internal Server Error', headers: {})

      expect { client.decode('ERRORVIN12345678') }.to raise_error(VinDecoder::ApiError, /500/)
    end
  end

  describe 'configuration overrides' do
    after do
      VinDecoder.configuration = nil
    end

    it 'uses a custom base URL and timeout' do
      VinDecoder.configure do |config|
        config.base_url = 'https://example.com'
        config.timeout = 5
      end

      stub_request(:get, 'https://example.com/DecodeVinValuesExtended/TESTVIN123456789?format=json')
        .to_return(status: 200, body: { Results: [{ 'Make' => 'Test', 'Model' => 'Car', 'ErrorCode' => '0' }] }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      vehicle = described_class.new.decode('TESTVIN123456789')

      expect(vehicle.make).to eq('Test')
      expect(VinDecoder.configuration.timeout).to eq(5)
    end
  end
end
