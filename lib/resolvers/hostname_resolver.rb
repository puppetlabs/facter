# frozen_string_literal: true

module Facter
  module Resolvers
    class Hostname < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_hostname(fact_name) }
        end

        def retrieve_hostname(fact_name)
          output, _status = Open3.capture2('hostname')

          # get domain
          domain = read_domain(output)

          # get hostname
          hostname = output =~ /(.*?)\./ ? Regexp.last_match(1) : output
          @fact_list[:hostname] ||= hostname&.strip
          @fact_list[:domain] ||= domain&.strip
          @fact_list[:fqdn] ||= "#{@fact_list[:hostname]}.#{@fact_list[:domain]}"
          @fact_list[fact_name]
        end

        def read_domain(output)
          if output =~ /.*?\.(.+$)/
            domain = Regexp.last_match(1)
          elsif File.exist?('/etc/resolv.conf')
            file = File.read('/etc/resolv.conf')
            if file.match(/^search\s+(\S+)/)
              domain = Regexp.last_match(1)
            elsif file.match(/^domain\s+(\S+)/)
              domain = Regexp.last_match(1)
            end
          end
          domain
        end
      end
    end
  end
end
