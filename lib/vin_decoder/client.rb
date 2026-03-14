# frozen_string_literal: true

module VinDecoder
  class Client
    def initialize
      config = VinDecoder.configuration || Configuration.new
      @connection = Faraday.new(url: config.base_url) do |faraday|
        faraday.options.timeout = config.timeout
        faraday.adapter Faraday.default_adapter
      end
    end

    def decode(vin)
      response = @connection.get("DecodeVinValuesExtended/#{vin}", format: 'json')

      handle_response(response)
    end

    private

    def handle_response(response)
      case response.status
      when 200
        payload = JSON.parse(response.body)
        result_hash = payload['Results']&.first || {}
        Vehicle.new(result_hash)
      when 404
        raise NotFoundError, 'VIN not found'
      else
        raise ApiError, "API returned status #{response.status}: #{response.body}"
      end
    end
  end
end
