# frozen_string_literal: true

require 'net/http'

module Facter
  module Resolvers
    class Ec2 < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}
      EC2_METADATA_ROOT_URL = 'http://169.254.169.254/latest/meta-data/'
      EC2_USERDATA_ROOT_URL = 'http://169.254.169.254/latest/user-data/'
      EC2_CONNECTION_TIMEOUT = 0.6
      EC2_SESSION_TIMEOUT = 5

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_facts(fact_name) }
        end

        def read_facts(fact_name)
          @fact_list[:metadata] = {}
          query_for_metadata(EC2_METADATA_ROOT_URL, @fact_list[:metadata])
          @fact_list[:userdata] = get_data_from(EC2_USERDATA_ROOT_URL).strip
          @fact_list[fact_name]
        end

        def query_for_metadata(url, container)
          metadata = get_data_from(url)
          metadata.each_line do |line|
            next if line.empty?

            http_path_component = build_path_compoent(line)
            next if http_path_component == 'security-credentials/'

            if http_path_component.end_with?('/')
              child = {}
              child[http_path_component] = query_for_metadata("#{url}#{http_path_component}", child)
              child.reject! { |key, _info| key == http_path_component }
              name = http_path_component.chomp('/')
              container[name] = child
            else
              container[http_path_component] = get_data_from("#{url}#{http_path_component}").strip
            end
          end
        end

        def build_path_compoent(line)
          array_match = /^(\d+)=.*$/.match(line)
          array_match ? "#{array_match[1]}/" : line.strip
        end

        def get_data_from(url)
          parsed_url = URI.parse(url)
          http = Net::HTTP.new(parsed_url.host)
          http.read_timeout = determine_session_timeout
          http.open_timeout = EC2_CONNECTION_TIMEOUT
          resp = http.get(parsed_url.path)
          response_code_valid?(resp.code) ? resp.body : ''
        rescue StandardError => e
          log.debug("Trying to connect to #{url} but got: #{e.message}")
          ''
        end

        def response_code_valid?(http_code)
          http_code.to_i.equal?(200)
        end

        def determine_session_timeout
          session_env = ENV['EC2_SESSION_TIMEOUT']
          session_env ? session_env.to_i : EC2_SESSION_TIMEOUT
        end
      end
    end
  end
end
