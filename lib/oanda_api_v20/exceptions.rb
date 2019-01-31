module OandaApiV20
  class ApiError < RuntimeError; end

  class RequestError < RuntimeError
    attr_reader :response, :original_exception

    def initialize(message = nil, options = {})
      @original_exception = options[:original_exception]
      @response           = options[:response]
      super(message)
    end
  end
end
