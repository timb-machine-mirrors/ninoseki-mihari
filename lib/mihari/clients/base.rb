# frozen_string_literal: true

module Mihari
  module Clients
    class Base
      # @return [String]
      attr_reader :base_url

      # @return [Hash]
      attr_reader :headers

      # @return [Integer, nil]
      attr_reader :interval

      # @return [Integer, nil]
      attr_reader :timeout

      #
      # @param [String] base_url
      # @param [Hash] headers
      # @param [Integer, nil] interval
      # @param [Integer, nil] timeout
      #
      def initialize(base_url, headers: {}, interval: nil, timeout: nil)
        @base_url = base_url
        @headers = headers || {}
        @interval = interval
        @timeout = timeout
      end

      private

      def sleep_interval
        sleep(interval) if interval
      end

      #
      # @param [String] path
      #
      # @return [String]
      #
      def url_for(path)
        base_url + path
      end

      #
      # @param [String] path
      # @param [Hash, nil] params
      #
      # @return [::HTTP::Response]
      #
      def get(path, params: nil)
        HTTP.get(url_for(path), headers: headers, timeout: timeout, params: params)
      end

      #
      # @param [String] path
      # @param [Hash, nil] json
      #
      # @return [::HTTP::Response]
      #
      def post(path, json: {})
        HTTP.post(url_for(path), headers: headers, timeout: timeout, json: json)
      end
    end
  end
end
