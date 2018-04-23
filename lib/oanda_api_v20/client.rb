module OandaApiV20
  class Client
    include HTTParty

    BASE_URI = {
      live:     'https://api-fxtrade.oanda.com/v3',
      practice: 'https://api-fxpractice.oanda.com/v3'
    }

    attr_accessor :access_token, :proxy_url, :max_requests_per_second, :connection_pool_size, :debug
    attr_reader   :base_uri, :headers

    def initialize(options = {})
      options.each do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end

      @mutex                   = Mutex.new
      @debug                   ||= false
      @connection_pool_size    ||= 2
      @max_requests_per_second ||= 100
      @last_api_request_at     = Array.new(max_requests_per_second)
      @base_uri                = options[:practice] == true ? BASE_URI[:practice] : BASE_URI[:live]

      @headers                             = {}
      @headers['Authorization']            = "Bearer #{access_token}"
      @headers['X-Accept-Datetime-Format'] = 'RFC3339'
      @headers['Content-Type']             = 'application/json'

      if proxy_url && uri = URI(proxy_url)
        Client.http_proxy(uri.hostname, uri.port, uri.user, uri.password)
      end

      persistent_connection_adapter_options = {
        name:         'oanda_api_v20',
        keep_alive:   30,
        idle_timeout: 10,
        warn_timeout: 2,
        pool_size:    connection_pool_size
      }

      persistent_connection_adapter_options.merge!(logger: ::Logger.new(STDOUT)) if debug
      Client.persistent_connection_adapter(persistent_connection_adapter_options)
    end

    def method_missing(name, *args, &block)
      case name
      when *Api.api_methods
        api_attributes = {
          client:         self,
          last_action:    name,
          last_arguments: args
        }

        api_attributes.merge!(account_id: args.first) if name == :account
        api_attributes.merge!(instrument: args.first) if name == :instrument

        Api.new(api_attributes)
      else
        super
      end
    end

    def govern_api_request_rate
      return unless last_api_request_at[0]
      halt = 1 - (last_api_request_at[max_requests_per_second - 1] - last_api_request_at[0])
      sleep halt if halt > 0
    end

    def update_last_api_request_at
      @mutex.synchronize do
        last_api_request_at.push(Time.now.utc).shift
      end
    end

    private

    attr_accessor :last_api_request_at
  end
end
