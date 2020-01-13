# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class DmiBios < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          #:model

          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts }
          end

          def read_facts
            # OSX only supports the product name
            output, _status = Open3.capture2('sysctl -n hw.model')
            @fact_list[:macosx_model] = output&.strip
          end
        end
      end
    end
  end
end
