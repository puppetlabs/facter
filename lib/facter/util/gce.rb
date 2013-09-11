# Copyright 2013 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Google Compute Engine: Storing and Retrieving Metadata
# https://developers.google.com/compute/docs/metadata

# TL;DR
# From the GCE instance, collect all facts about the GCE instance and project
# with 'curl "http://metadata/computeMetadata/v1beta1/?recursive=true&alt=json'
#

require 'timeout'
require 'open-uri'

# Provide a set of utility static methods that help with resolving the GCE
# fact.
module Facter::Util::GCE
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

  METADATA_URL="http://metadata/computeMetadata/v1beta1/?recursive=true&alt=json"

  ##
  # recursive function to flatten the json response into single
  # key/value pairs.  hash keys become keys, lists are appended
  # to keys with numerical index
  def self.metadata_facts(var, val)
    if val.is_a?(Hash)
      val.each_pair do |k, v|
        if ["image", "machineType", "zone", "network"].include? k
          v = v.split('/')[-1]
        end
        metadata_facts("#{var}_#{k}", v)
      end
    elsif val.is_a?(Array)
      val.each_with_index do |v, i|
        metadata_facts("#{var}_#{i}", v)
      end
    else
      # convert the sshKeys single entry into multiple entries, one
      # per key
      if var.end_with? "sshKeys"
        val.split("\n").each_with_index do |v, i|
          Facter.add("#{var}_#{i}".to_sym) { setcode { v } }
        end
      else
        Facter.add(var.to_sym) { setcode { val } }
      end
    end
  end

  ##
  # with_metadata_server takes a block of code and executes the block only if
  # Facter is running on node that can access a metadata server at
  # http://metadata/.  The request URI is configurable and the response body
  # will be passed to the first argument of the block.  This is useful to
  # decide if it's reasonably likely that talking to the GCE metadata server
  # will be successful or not.
  #
  # @option options [Integer] :timeout (100) the maxiumum number of
  # milliseconds Facter will block trying to talk to the metadata server.
  #
  # @option options [String] :fact ('virtual') the fact to check.  The block
  # will only be executed if the fact named here matches the value named in the
  # :value option.
  #
  # @option options [String] :value ('gce') the value to check.  The block
  # will be executed if Facter.value(options[:fact]) matches this value.
  #
  # @option options [Fixnum] :retry_limit (3) the maximum number of times that
  # this method will try to contact the metadata server.  The maximum run time
  # is the timeout times this limit, so please keep the value small.
  #
  # @option options [String] :url ({METADATA_URL}) the url that will be used to
  # attempt the initial connection to the metadata server.  If the URL responds
  # then the body of the response will be passed as the first argument to the
  # block provided.
  #
  # @return [Boolean] the return {true} if successfula, {false} otherwise
  #
  def self.with_metadata_server(options = {}, &block)
    opts = options.dup
    opts[:timeout] ||= 100
    opts[:fact] ||= 'virtual'
    opts[:value] ||= 'gce'
    opts[:retry_limit] ||= 3
    opts[:url] ||= METADATA_URL
    # Conversion to fractional seconds for Timeout
    timeout = opts[:timeout] / 1000.0
    raise ArgumentError, "A value is required for :fact" if opts[:fact].nil?
    raise ArgumentError, "A value is required for :value" if opts[:value].nil?
    return false if Facter.value(opts[:fact]) != opts[:value]

    attempts = 0
    begin
      body = nil
      attempts = attempts + 1
      # Read the list of supported API versions
      Timeout.timeout(timeout) do
        body = read_uri(opts[:url])
      end
    rescue *CONNECTION_ERRORS => detail
      retry if attempts < opts[:retry_limit]
      Facter.warn "Unable to fetch metadata from #{opts[:url]}, " +
        "metadata server facts will be undefined. #{detail.message}"
      return false
    end

    if body
      return block.call(body)
    else
      return false
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
  # add_gce_facts defines GCE related facts when running on an GCE compatible
  # node.  This method will only ever do work once for the life of a process in
  # order to limit the amount of network I/O.
  #
  # @option options [Boolean] :force (false) whether or not to force
  # re-definition of the facts.
  def self.add_gce_facts(options = {})
    opts = options.dup
    opts[:force] ||= false
    unless opts[:force]
      return nil if @add_gce_facts_has_run
    end
    @add_gce_facts_has_run = true
    if require_json
      with_metadata_server(:timeout => 50) do |body|
        metadata_facts("gce", JSON.parse(body))
      end
    end
  end

  private

  # @api private
  def self.require_json
    return true if Facter.json?
    Facter.warn("Cannot load GCE facts: no JSON gem available")
    return false
  end

end
