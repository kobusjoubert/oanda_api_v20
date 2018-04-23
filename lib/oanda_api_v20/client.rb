module OandaApiV20
  class Client
    include HTTParty

    MAX_REQUESTS_PER_SECOND_ALLOWED = 30

    BASE_URI = {
      live:     'https://api-fxtrade.oanda.com/v3',
      practice: 'https://api-fxpractice.oanda.com/v3'
    }

    attr_accessor :access_token, :proxy_url
    attr_reader   :base_uri, :headers, :connection_pool_size, :debug

    def initialize(options = {})
      options.each do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end

      @mutex                = Mutex.new
      @debug                = options[:debug] || false
      @connection_pool_size = options[:connection_pool_size] || 2
      @last_api_request_at  = Array.new(MAX_REQUESTS_PER_SECOND_ALLOWED)
      @base_uri             = options[:practice] == true ? BASE_URI[:practice] : BASE_URI[:live]

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
          client:         self, # TODO: Do we need to return a duplicate or will self do?
          # base_uri:       base_uri,
          # headers:        headers,
          last_action:    name,
          last_arguments: args
        }

        api_attributes.merge!(account_id: args.first) if name == :account
        api_attributes.merge!(instrument: args.first) if name == :instrument

        api = Api.new(api_attributes)
        # api.dup # TODO: Do we need to return a duplicate?
        api
      else
        super
      end
    end

    def govern_api_request_rate
      return unless last_api_request_at[0]
      halt = 1 - (last_api_request_at[MAX_REQUESTS_PER_SECOND_ALLOWED - 1] - last_api_request_at[0])
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
