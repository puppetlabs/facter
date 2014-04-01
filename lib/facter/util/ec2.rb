require 'timeout'
require 'open-uri'

# Provide a set of utility static methods that help with resolving the EC2
# fact.
#
# @see http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
module Facter::Util::EC2
  CONNECTION_ERRORS = [
    Errno::EHOSTDOWN,
    Errno::EHOSTUNREACH,
    Errno::ENETUNREACH,
    Errno::ECONNABORTED,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::ETIMEDOUT,
  ]

  # Query a specific AWS metadata URI.
  #
  # @api private
  def self.fetch(uri)
    body = open(uri).read

    lines = body.split("\n").map do |line|
      if (match = line.match(/^(\d+)=.*$/))
        # Metadata arrays are formatted like '<index>=<associated key>/', so
        # we need to extract the index from that output.
        "#{match[1]}/"
      else
        line
      end
    end

    lines
  rescue OpenURI::HTTPError => e
    if e.message.match /404 Not Found/i
      return nil
    else
      Facter.log_exception(e, "Failed to fetch ec2 uri #{uri}: #{e.message}")
      return nil
    end
  rescue *CONNECTION_ERRORS => e
    Facter.log_exception(e, "Failed to fetch ec2 uri #{uri}: #{e.message}")
  end

  def self.recursive_fetch(uri)
    results = {}

    keys = fetch(uri)

    keys.each do |key|
      if key.match(%r[/$])
        # If a metadata key is suffixed with '/' then it's a general metadata
        # resource, so we have to recursively look up all the keys in the given
        # collection.
        name = key[0..-2]
        results[name] = recursive_fetch("#{uri}#{key}")
      else
        # This is a simple key/value pair, we can just query the given endpoint
        # and store the results.
        ret = fetch("#{uri}#{key}")
        results[key] = ret.size > 1 ? ret : ret.first
      end
    end

    results
  end

  # Is the given URI reachable?
  #
  # @param uri [String] The HTTP URI to attempt to reach
  #
  # @return [true, false] If the given URI could be fetched after retry_limit attempts
  def self.uri_reachable?(uri, retry_limit = 3)
    timeout = 0.2
    able_to_connect = false
    attempts = 0

    begin
      Timeout.timeout(timeout) do
        open(uri).read
      end
      able_to_connect = true
    rescue OpenURI::HTTPError => e
      if e.message.match /404 Not Found/i
        able_to_connect = false
      else
        retry if attempts < retry_limit
      end
    rescue Timeout::Error
      retry if attempts < retry_limit
    rescue *CONNECTION_ERRORS
      retry if attempts < retry_limit
    ensure
      attempts = attempts + 1
    end

    able_to_connect
  end
end
