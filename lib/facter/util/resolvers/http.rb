# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      module Http
        @log = Facter::Log.new(self)

        class << self
          CONNECTION_TIMEOUT = 0.6
          SESSION_TIMEOUT = 5

          # Makes a GET http request and returns its response.
          #
          # Params:
          # url: String which contains the address to which the request will be made
          # headers: Hash which contains the headers you need to add to your request.
          #          Default headers is an empty hash
          #          Example: { "Accept": 'application/json' }
          # timeouts: Hash that includes the values for the session and connection timeouts.
          #          Example: { session: 2.4. connection: 5 }
          #
          # Return value:
          # is a string with the response body if the response code is 200.
          # If the response code is not 200, an empty string is returned.
          def get_request(url, headers = {}, timeouts = {})
            make_request(url, headers, timeouts, 'GET')
          end

          def put_request(url, headers = {}, timeouts = {})
            make_request(url, headers, timeouts, 'PUT')
          end

          private

          def make_request(url, headers, timeouts, request_type)
            require 'net/http'

            uri = URI.parse(url)
            http = http_obj(uri, timeouts)
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

          def http_obj(parsed_url, timeouts)
            http = Net::HTTP.new(parsed_url.host)
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
