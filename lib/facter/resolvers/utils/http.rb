# frozen_string_literal: true

module Facter
  module Resolvers
    module Utils
      module Http
        class << self
          CONNECTION_TIMEOUT = 0.6
          SESSION_TIMEOUT = 5
          @log = Facter::Log.new(self)

          # Makes a GET http request and returns it's response.
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

          private

          def make_request(url, headers, timeouts, request_type)
            require 'net/http'

            uri = URI.parse(url)
            http = http_obj(uri, timeouts)
            request = request_obj(headers, uri, request_type)

            # Make the request
            resp = http.request(request)
            response_code_valid?(resp.code.to_i) ? resp.body : ''
          rescue StandardError => e
            @log.debug("Trying to connect to #{url} but got: #{e.message}")
            ''
          end

          def http_obj(parsed_url, timeouts)
            http = Net::HTTP.new(parsed_url.host)
            http.read_timeout = timeouts[:session] || SESSION_TIMEOUT
            http.open_timeout = timeouts[:connection] || CONNECTION_TIMEOUT
            http
          end

          def request_obj(headers, parsed_url, request_type)
            return Net::HTTP::Get.new(parsed_url.request_uri, headers) if request_type == 'GET'

            raise StandardError("Unknown http request type: #{request_type}")
          end

          def response_code_valid?(http_code)
            @log.debug("Request failed with error code #{http_code}") unless http_code.equal?(200)
            http_code.equal?(200)
          end
        end
      end
    end
  end
end
