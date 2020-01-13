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
          @fact_list.fetch(fact_name) { retrieve_hostname }
        end

        def retrieve_hostname
          output, _status = Open3.capture2('hostname')
          @fact_list[:hostname] = output&.strip
        end
      end
    end
  end
end
