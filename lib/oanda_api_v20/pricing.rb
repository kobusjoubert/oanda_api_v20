# @see http://developer.oanda.com/rest-live-v20/pricing-ep/
module OandaApiV20
  module Pricing
    # GET /v3/accounts/:account_id/pricing
    def pricing(options)
      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pricing", headers: headers, query: options)
    end

    # GET /v3/accounts/:account_id/pricing/stream
    def pricing_stream(options, &block)
      buffer = StringIO.new

      Client.send(http_verb, "#{base_uri}/accounts/#{account_id}/pricing/stream", headers: headers, query: options, stream_body: true) do |fragment|
        begin
          next if fragment.empty?

          buffer << fragment
          next unless fragment.match(/\n\Z/)

          buffer.string.split("\n").each do |message|
            cleaned_message = message.strip
            next if cleaned_message.empty?
            yield JSON.parse(cleaned_message)
          end

          buffer.flush
        rescue => e
          puts "ERROR: #{e.class}: #{e.message} in '#{fragment}'"
        end
      end
    end
  end
end
