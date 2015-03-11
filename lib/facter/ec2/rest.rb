require 'timeout'
require 'open-uri'

module Facter
  module EC2
    CONNECTION_ERRORS = [
      Errno::EHOSTDOWN,
      Errno::EHOSTUNREACH,
      Errno::ENETUNREACH,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::ETIMEDOUT,
    ]

    # Contains metadata keys that should not be collected
    FILTERED_KEYS = [
      'security-credentials/'
    ].freeze

    class Base
      def reachable?(retry_limit = 3)
        timeout = 0.2
        able_to_connect = false
        attempts = 0

        begin
          Timeout.timeout(timeout) do
            open(@baseurl, :proxy => nil).read
          end
          able_to_connect = true
        rescue OpenURI::HTTPError => e
          if e.message.match /404 Not Found/i
            able_to_connect = false
          else
            attempts = attempts + 1
            retry if attempts < retry_limit
          end
        rescue Timeout::Error
          attempts = attempts + 1
          retry if attempts < retry_limit
        rescue *CONNECTION_ERRORS
          attempts = attempts + 1
          retry if attempts < retry_limit
        end

        able_to_connect
      end
    end

    class Metadata < Base

      DEFAULT_URI = "http://169.254.169.254/latest/meta-data/"

      def initialize(uri = DEFAULT_URI)
        @baseurl = uri
      end

      def fetch(path = '')
        results = {}

        keys = fetch_endpoint(path)
        keys.each do |key|
          next if FILTERED_KEYS.include? key
          if key.match(%r[/$])
            # If a metadata key is suffixed with '/' then it's a general metadata
            # resource, so we have to recursively look up all the keys in the given
            # collection.
            name = key[0..-2]
            results[name] = fetch("#{path}#{key}")
          else
            # This is a simple key/value pair, we can just query the given endpoint
            # and store the results.
            ret = fetch_endpoint("#{path}#{key}")
            results[key] = ret.size > 1 ? ret : ret.first
          end
        end

        results
      end

      # @param path [String] The path relative to the object base url
      #
      # @return [Array, NilClass]
      def fetch_endpoint(path)
        uri = @baseurl + path
        body = open(uri, :proxy => nil).read
        parse_results(body)
      rescue OpenURI::HTTPError => e
        if e.message.match /404 Not Found/i
          return nil
        else
          Facter.log_exception(e, "Failed to fetch ec2 uri #{uri}: #{e.message}")
          return nil
        end
      rescue *CONNECTION_ERRORS => e
        Facter.log_exception(e, "Failed to fetch ec2 uri #{uri}: #{e.message}")
        return nil
      rescue Timeout::Error => e
        Facter.log_exception(e, "Failed to fetch ec2 uri #{uri}: #{e.message}")
        return nil
      end

      private

      def parse_results(body)
        lines = body.split("\n")
        lines.map do |line|
          if (match = line.match(/^(\d+)=.*$/))
            # Metadata arrays are formatted like '<index>=<associated key>/', so
            # we need to extract the index from that output.
            "#{match[1]}/"
          else
            line
          end
        end
      end
    end

    class Userdata < Base
      DEFAULT_URI = "http://169.254.169.254/latest/user-data/"

      def initialize(uri = DEFAULT_URI)
        @baseurl = uri
      end

      def fetch
        open(@baseurl).read
      rescue OpenURI::HTTPError => e
        if e.message.match /404 Not Found/i
          return nil
        else
          Facter.log_exception(e, "Failed to fetch ec2 uri #{uri}: #{e.message}")
          return nil
        end
      end
    end
  end
end
