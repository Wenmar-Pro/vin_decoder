# frozen_string_literal: true

module VinDecoder
  class Vehicle
    attr_reader :raw_data

    def initialize(data)
      @raw_data = data || {}
    end

    def make
      raw_data['Make']
    end

    def model
      raw_data['Model']
    end

    def year
      raw_data['ModelYear']
    end

    def engine_cylinders
      raw_data['EngineCylinders']
    end

    def engine
      raw_data['EngineConfiguration']
    end

    def fuel_type
      raw_data['FuelTypePrimary']
    end

    def trim
      raw_data['Trim']
    end

    def [](key)
      raw_data[key.to_s]
    end

    def valid?
      raw_data['ErrorCode'] == '0'
    end

    def to_h
      raw_data.dup
    end

    def method_missing(method_name, *args, &block)
      return super unless args.empty?

      key = lookup_key(method_name)
      return super unless key

      raw_data[key]
    end

    def respond_to_missing?(method_name, include_private = false)
      lookup_key(method_name) || super
    end

    private

    def lookup_key(method_name)
      return if method_name.nil?

      normalized_key_cache[method_name] ||= begin
        normalized = method_name.to_s
        raw_data.keys.find { |key| normalize_key(key) == normalized }
      end
    end

    def normalized_key_cache
      @normalized_key_cache ||= {}
    end

    def normalize_key(key)
      key.to_s
         .gsub(/[^a-zA-Z0-9]+/, '_')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .downcase
    end
  end
end
