require 'open-uri'

module Facter
  module GCE

    # @api private
    class Metadata
      CONNECTION_ERRORS = [
        OpenURI::HTTPError,
        Errno::EHOSTDOWN,
        Errno::EHOSTUNREACH,
        Errno::ENETUNREACH,
        Errno::ECONNABORTED,
        Errno::ECONNREFUSED,
        Errno::ECONNRESET,
        Errno::ETIMEDOUT,
        Timeout::Error,
      ]

      METADATA_URL = "http://metadata/computeMetadata/v1beta1/?recursive=true&alt=json"

      def initialize(url = METADATA_URL)
        @url = url
      end

      def fetch
        with_metadata_server do |body|
          # This will only be reached if the confine associated with this class
          # was true which means that JSON was required, but it's a bit
          # questionable that we're relying on JSON being loaded as a side
          # effect of that.
          hash = ::JSON.parse(body)
          transform_metadata!(hash)
          hash
        end
      end

      private

      def with_metadata_server
        retry_limit = 3
        timeout = 0.05
        body = nil
        attempts = 0

        begin
          Timeout.timeout(timeout) do
            body = open(@url).read
          end
        rescue *CONNECTION_ERRORS => e
          attempts = attempts + 1
          if attempts < retry_limit
            retry
          else
            Facter.log_exception(e, "Unable to fetch metadata from #{@url}: #{e.message}")
            return nil
          end
        end

        if body
          yield body
        end
      end

      # @return [void]
      def transform_metadata!(data)
        case data
        when Hash
          data.keys.each do |key|
            value = data[key]
            if ["image", "machineType", "zone", "network"].include? key
              data[key] = value.split('/').last
            elsif key == "sshKeys"
              data['sshKeys'] = value.split("\n")
            end
            transform_metadata!(value)
          end
        when Array
          data.each do |value|
            transform_metadata!(value)
          end
        end
        nil
      end
    end
  end
end
