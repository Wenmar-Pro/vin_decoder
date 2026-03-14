# frozen_string_literal: true

module VinDecoder
  class Configuration
    attr_accessor :base_url, :timeout

    def initialize
      @base_url = "https://vpic.nhtsa.dot.gov/api/vehicles"
      @timeout = 10
    end
  end
end
