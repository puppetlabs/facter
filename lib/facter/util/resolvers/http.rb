# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      module Http
        @log = Facter::Log.new(self)

        class << self
          CONNECTION_TIMEOUT = 0.6
          SESSION_TIMEOUT = 5

          # Makes a GET HTTP request and returns its response.
          #
          # @param url [String] the address to which the request will be made.
          # @param headers [Hash] the headers you need to add to your request.
          #   Defaults to an empty hash.
          # @param timeouts [Hash] Values for the session and connection
          #   timeouts.
          # @param proxy [Boolean] Whether to use proxy settings when calling
          #   Net::HTTP.new. Defaults to true.
          # @returns [String] the response body if the response code is 200.
          #   If the response code is not 200, an empty string is returned.
          # @example
          #   get_request('https://example.com', { "Accept": 'application/json' }, { session: 2.4, connection: 5 })
          def get_request(url, headers = {}, timeouts = {}, proxy = true)
            make_request(url, headers, timeouts, 'GET', proxy)
          end

          # Makes a PUT HTTP request and returns its response
          # @param (see #get_request)
          # @return (see #get_request)
          def put_request(url, headers = {}, timeouts = {}, proxy = true)
            make_request(url, headers, timeouts, 'PUT', proxy)
          end

          private

          def make_request(url, headers, timeouts, request_type, proxy)
            require 'net/http'

            uri = URI.parse(url)
            http = http_obj(uri, timeouts, proxy)
            request = request_obj(headers, uri, request_type)

            # The Windows implementation of sockets does not respect net/http
            # timeouts, so check if the target is reachable in a different way
            if Gem.win_platform?
              Socket.tcp(uri.host, uri.port, connect_timeout: timeouts[:connection] || CONNECTION_TIMEOUT)
            end

            # Make the request
            response = http.request(request)
            response.uri = url

            successful_response?(response) ? response.body : ''
          rescue StandardError => e
            @log.debug("Trying to connect to #{url} but got: #{e.message}")
            ''
          end

          def http_obj(parsed_url, timeouts, proxy)
            # If get_request or put_request are called and set proxy to false,
            # manually set Net::HTTP.new's p_addr (proxy address) positional
            # argument to nil to override anywhere else a proxy may be set
            # (e.g. the http_proxy environment variable).
            http = if proxy
                     Net::HTTP.new(parsed_url.host)
                   else
                     Net::HTTP.new(parsed_url.host, 80, nil)
                   end
            http.read_timeout = timeouts[:session] || SESSION_TIMEOUT
            http.open_timeout = timeouts[:connection] || CONNECTION_TIMEOUT

            http.set_debug_output($stderr) if Options[:http_debug]

            http
          end

          def request_obj(headers, parsed_url, request_type)
            Module.const_get("Net::HTTP::#{request_type.capitalize}").new(parsed_url.request_uri, headers)
          end

          def successful_response?(response)
            success = response.code.to_i.equal?(200)

            @log.debug("Request to #{response.uri} failed with error code #{response.code}") unless success

            success
          end
        end
      end
    end
  end
end
