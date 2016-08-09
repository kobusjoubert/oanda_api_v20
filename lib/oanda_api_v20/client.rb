module OandaApiV20
  class Client
    include HTTParty

    BASE_URI = {
      live:     'https://api-fxtrade.oanda.com/v3',
      practice: 'https://api-fxpractice.oanda.com/v3'
    }

    attr_accessor :access_token
    attr_reader   :base_uri, :headers

    def initialize(options = {})
      options.each do |key, value|
        self.send("#{key}=", value) if self.respond_to?("#{key}=")
      end

      @base_uri = options[:practice] == true ? BASE_URI[:practice] : BASE_URI[:live]

      @headers = {}
      @headers['Authorization']            = "Bearer #{access_token}"
      @headers['X-Accept-Datetime-Format'] = 'RFC3339'
      @headers['Content-Type']             = 'application/json'
    end

    def method_missing(name, *args, &block)
      case name
      when :show, :create, :update, :cancel, :close
        set_http_verb(name, last_action)
        api = Api.new(api_attributes)

        if api.respond_to?(last_action)
          response = last_arguments.nil? || last_arguments.empty? ? api.send(last_action, &block) : api.send(last_action, *last_arguments, &block)
          api_result = JSON.parse(response.body)
          set_last_transaction_id(api_result)
        end

        api_result
      when *api_methods
        set_last_action_and_arguments(name, args)
        set_account_id(args.first) if name == :account
        self
      end
    end

    private

    attr_accessor :http_verb, :account_id, :last_transaction_id, :last_action, :last_arguments

    def api_methods
      Accounts.instance_methods + Orders.instance_methods + Trades.instance_methods + Positions.instance_methods + Transactions.instance_methods + Pricing.instance_methods
    end

    def set_last_action_and_arguments(action, args)
      set_last_action(action)
      set_last_arguments(args)
    end

    def set_last_action(action)
      self.last_action = action
    end

    def set_last_arguments(args)
      self.last_arguments = args.nil? || args.empty? ? nil : args.flatten
    end

    def set_account_id(id)
      self.account_id = id
    end

    def set_last_transaction_id(api_result)
      self.last_transaction_id = api_result['lastTransactionID'] if api_result['lastTransactionID']
    end

    def set_http_verb(action, last_action)
      case action
      when :show
        self.http_verb = :get
      when :update, :cancel, :close
        [:configuration].include?(last_action) ? self.http_verb = :patch : self.http_verb = :put
      when :create
        self.http_verb = :post
      else
        self.http_verb = nil
      end
    end

    def api_attributes
      {
        http_verb: http_verb,
        base_uri: base_uri,
        headers: headers,
        account_id: account_id,
        last_transaction_id: last_transaction_id
      }
    end
  end
end
