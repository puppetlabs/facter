# frozen_string_literal: true

module Facter
  module Resolvers
    class DMIComputerSystem < BaseResolver
      @log = Facter::Log.new(self)
      init_resolver

      class << self
        # Name
        # UUID

        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_fact_from_computer_system(fact_name) }
        end

        def read_fact_from_computer_system(fact_name)
          win = Win32Ole.new
          computersystem = win.return_first('SELECT Name,UUID FROM Win32_ComputerSystemProduct')
          unless computersystem
            @log.debug 'WMI query returned no results for Win32_ComputerSystemProduct with values Name and UUID.'
            return
          end

          build_fact_list(computersystem)

          @fact_list[fact_name]
        end

        def build_fact_list(computersys)
          @fact_list[:name] = computersys.Name
          @fact_list[:uuid] = computersys.UUID
        end
      end
    end
  end
end
