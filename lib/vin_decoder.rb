# frozen_string_literal: true

require "zeitwerk"
require "faraday"
require "json"

loader = Zeitwerk::Loader.for_gem
loader.setup

module VinDecoder
  class Error < StandardError; end
  class ApiError < Error; end
  class NotFoundError < Error; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
