# frozen_string_literal: true

module Mihari
  module Analyzers
    #
    # Shodan analyzer
    #
    class Shodan < Base
      # @return [String, nil]
      attr_reader :api_key

      #
      # @param [String] query
      # @param [Hash, nil] options
      # @param [String, nil] api_key
      #
      def initialize(query, options: nil, api_key: nil)
        super(query, options: options)

        @api_key = api_key || Mihari.config.shodan_api_key
      end

      def artifacts
        client.search_with_pagination(
          query,
          pagination_limit: pagination_limit
        ).map(&:artifacts).flatten.uniq(&:data)
      end

      private

      #
      # @return [Clients::Shodan]
      #
      def client
        Clients::Shodan.new(
          api_key: api_key,
          pagination_interval: pagination_interval,
          timeout: timeout
        )
      end
    end
  end
end
