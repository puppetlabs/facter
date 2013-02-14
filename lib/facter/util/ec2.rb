require 'timeout'
require 'open-uri'

# Provide a set of utility static methods that help with resolving the EC2
# fact.
module Facter::Util::EC2
  CONNECTION_ERRORS = [
    OpenURI::HTTPError,
    Errno::EHOSTDOWN,
    Errno::EHOSTUNREACH,
    Errno::ENETUNREACH,
    Errno::ECONNABORTED,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::ETIMEDOUT,
  ]
  ##
  # metadata is a recursive function that walks over the metadata server
  # located at http://169.254.169.254 and defines a fact for each value found.
  # This method introduces a high amount of latency to Facter, so care must be
  # taken to call it only when reasonably certain the host is running in an
  # environment where the metadata server is available.
  def self.define_metadata_facts(id = "")
    begin
      if body = read_uri("http://169.254.169.254/latest/meta-data/#{id}")
        body.split("\n").each do |o|
          key = "#{id}#{o.gsub(/\=.*$/, '/')}"
          if key[-1..-1] != '/'
            value = read_uri("http://169.254.169.254/latest/meta-data/#{key}").split("\n")
            symbol = "ec2_#{key.gsub(/\-|\//, '_')}".to_sym
            Facter.add(symbol) { setcode { value.join(',') } }
          else
            define_metadata_facts(key)
          end
        end
      end
    rescue *CONNECTION_ERRORS => detail
      Facter.warn "Could not retrieve ec2 metadata: #{detail.message}"
    end
  end

  ##
  # define_userdata_fact creates a single fact named 'ec2_userdata' which has a
  # value of the contents of the EC2 userdata field.  This method introduces a
  # high amount of latency to Facter, so care must be taken to call it only
  # when reasonably certain the host is running in an environment where the
  # metadata server is available.
  def self.define_userdata_fact
    Facter.add(:ec2_userdata) do
      setcode do
        if userdata = Facter::Util::EC2.userdata
          userdata.split
        end
      end
    end
  end

  ##
  # with_metadata_server takes a block of code and executes the block only if
  # Facter is running on node that can access a metadata server at
  # http://169.254.168.254/.  This is useful to decide if it's reasonably
  # likely that talking to the EC2 metadata server will be successful or not.
  #
  # @option options [Integer] :timeout (100) the maxiumum number of
  # milliseconds Facter will block trying to talk to the metadata server.
  # Defaults to 200.
  #
  # @option options [String] :fact ('virtual') the fact to check.  The block
  # will only be executed if the fact named here matches the value named in the
  # :value option.
  #
  # @option options [String] :value ('xenu') the value to check.  The block
  # will be executed if Facter.value(options[:fact]) matches this value.
  #
  # @option options [String] :api_version ('latest') the Amazon AWS API
  # version.  The version string is usually a date, e.g. '2008-02-01'.
  #
  # @option options [Fixnum] :retry_limit (3) the maximum number of times that
  # this method will try to contact the metadata server.  The maximum run time
  # is the timeout times this limit, so please keep the value small.
  #
  # @return [Object] the return value of the passed block, or {false} if the
  # block was not executed because the conditions were not met or a timeout
  # occurs.
  def self.with_metadata_server(options = {}, &block)
    opts = options.dup
    opts[:timeout] ||= 100
    opts[:fact] ||= 'virtual'
    opts[:value] ||= 'xenu'
    opts[:api_version] ||= 'latest'
    opts[:retry_limit] ||= 3
    # Conversion to fractional seconds for Timeout
    timeout = opts[:timeout] / 1000.0
    raise ArgumentError, "A value is required for :fact" if opts[:fact].nil?
    raise ArgumentError, "A value is required for :value" if opts[:value].nil?
    return false if Facter.value(opts[:fact]) != opts[:value]

    metadata_base_url = "http://169.254.169.254"

    attempts = 0
    begin
      able_to_connect = false
      attempts = attempts + 1
      # Read the list of supported API versions
      Timeout.timeout(timeout) do
        read_uri(metadata_base_url)
      end
    rescue Timeout::Error => detail
      retry if attempts < opts[:retry_limit]
      Facter.warn "Timeout exceeded trying to communicate with #{metadata_base_url}, " +
        "metadata server facts will be undefined. #{detail.message}"
    rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH, Errno::ECONNREFUSED => detail
      retry if attempts < opts[:retry_limit]
      Facter.warn "No metadata server available at #{metadata_base_url}, " +
        "metadata server facts will be undefined. #{detail.message}"
    rescue OpenURI::HTTPError => detail
      retry if attempts < opts[:retry_limit]
      Facter.warn "Metadata server at #{metadata_base_url} responded with an error. " +
        "metadata server facts will be undefined. #{detail.message}"
    else
      able_to_connect = true
    end

    if able_to_connect
      return block.call
    else
      return false
    end
  end

  ##
  # userdata returns a single string containing the body of the response of the
  # GET request for the URI http://169.254.169.254/latest/user-data/  If the
  # metadata server responds with a 404 Not Found error code then this method
  # retuns `nil`.
  #
  # @param version [String] containing the API version for the request.
  # Defaults to "latest" and other examples are documented at
  # http://aws.amazon.com/archives/Amazon%20EC2
  #
  # @api public
  #
  # @return [String] containing the response body or `nil`
  def self.userdata(version="latest")
    uri = "http://169.254.169.254/#{version}/user-data/"
    begin
      read_uri(uri)
    rescue OpenURI::HTTPError => detail
      case detail.message
      when /404 Not Found/i
        Facter.debug "No user-data present at #{uri}: server responded with #{detail.message}"
        return nil
      else
        raise detail
      end
    end
  end

  ##
  # read_uri provides a seam method to easily test the HTTP client
  # functionality of a HTTP based metadata server.
  #
  # @api private
  #
  # @return [String] containing the body of the response
  def self.read_uri(uri)
    open(uri).read
  end
  private_class_method :read_uri

  ##
  # add_ec2_facts defines EC2 related facts when running on an EC2 compatible
  # node.  This method will only ever do work once for the life of a process in
  # order to limit the amount of network I/O.
  #
  # @option options [Boolean] :force (false) whether or not to force
  # re-definition of the facts.
  def self.add_ec2_facts(options = {})
    opts = options.dup
    opts[:force] ||= false
    unless opts[:force]
      return nil if @add_ec2_facts_has_run
    end
    @add_ec2_facts_has_run = true
    with_metadata_server :timeout => 50 do
      define_userdata_fact
      define_metadata_facts
    end
  end
end
