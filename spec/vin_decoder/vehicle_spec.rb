# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VinDecoder::Vehicle do
  describe 'attribute readers' do
    subject(:vehicle) do
      described_class.new(
        'Make' => 'Tesla',
        'Model' => 'Model 3',
        'ModelYear' => '2022',
        'Trim' => 'Performance',
        'EngineCylinders' => '0',
        'EngineConfiguration' => 'Electric',
        'FuelTypePrimary' => 'Electric',
        'ErrorCode' => '0'
      )
    end

    it 'returns decoded values' do
      expect(vehicle.make).to eq('Tesla')
      expect(vehicle.model).to eq('Model 3')
      expect(vehicle.year).to eq('2022')
      expect(vehicle.trim).to eq('Performance')
      expect(vehicle.engine_cylinders).to eq('0')
      expect(vehicle.engine).to eq('Electric')
      expect(vehicle.fuel_type).to eq('Electric')
      expect(vehicle).to be_valid
      expect(vehicle['Make']).to eq('Tesla')
      expect(vehicle[:ModelYear]).to eq('2022')
    end
  end

  describe '#valid?' do
    it 'returns false when the API reports an error' do
      vehicle = described_class.new('ErrorCode' => '1')

      expect(vehicle).not_to be_valid
    end

    it 'handles nil data gracefully' do
      vehicle = described_class.new(nil)

      expect(vehicle.raw_data).to eq({})
      expect(vehicle.make).to be_nil
      expect(vehicle).not_to be_valid
    end
  end

  describe 'dynamic accessors' do
    it 'responds to snake_case methods' do
      vehicle = described_class.new('FuelTypePrimary' => 'Gasoline', 'LotSize' => '10 Acres')

      expect(vehicle.fuel_type_primary).to eq('Gasoline')
      expect(vehicle.lot_size).to eq('10 Acres')
    end

    it 'falls back to NoMethodError when key is missing' do
      vehicle = described_class.new({})

      expect(vehicle.respond_to?(:non_existent_field)).to be(false)
      expect { vehicle.non_existent_field }.to raise_error(NoMethodError)
    end
  end
end
