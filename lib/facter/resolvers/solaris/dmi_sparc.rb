# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class DmiSparc < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            output = exec_prtdiag
            return unless output

            matches = output.match(/System Configuration:\s+(.+?)\s+sun\d+\S+\s+(.+)/)&.captures

            # There are circumstances (e.g. in non-global zones) when prtdiag
            # will return text, but it's an error message or some other string
            # that isn't parsed by the above match/capture. In that case, we
            # simply return.
            return if matches.nil?

            @fact_list[:manufacturer] = matches[0]&.strip
            @fact_list[:product_name] = matches[1]&.strip

            sneep = exec_sneep&.strip
            @fact_list[:serial_number] = sneep

            @fact_list[fact_name]
          end

          def exec_prtdiag
            return unless File.executable?('/usr/sbin/prtdiag')

            Facter::Core::Execution.execute('/usr/sbin/prtdiag', logger: log)
          end

          def exec_sneep
            return unless File.executable?('/usr/sbin/sneep')

            Facter::Core::Execution.execute('/usr/sbin/sneep', logger: log)
          end
        end
      end
    end
  end
end
