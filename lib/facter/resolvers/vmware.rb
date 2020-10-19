# frozen_string_literal: true

module Facter
  module Resolvers
    class Vmware < BaseResolver
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { vmware_command(fact_name) }
        end

        def vmware_command(fact_name)
          output = Facter::Core::Execution.execute('vmware -v', logger: log)
          return if output.empty?

          parts = output.split("\s")
          return unless parts.size.equal?(2)

          @fact_list[:vm] = "#{parts[0].downcase}_#{parts[1].downcase}"
          @fact_list[fact_name]
        end
      end
    end
  end
end
