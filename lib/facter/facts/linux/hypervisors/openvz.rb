# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class Openvz
        FACT_NAME = 'hypervisors.openvz'

        def call_the_resolver
          fact_value = check_openvz
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        def check_openvz
          openvz = Facter::Resolvers::OpenVz.resolve(:vm)
          return unless openvz

          id = Facter::Resolvers::OpenVz.resolve(:id)

          { id: id.to_i, host: openvz == 'openvzhn' }
        end
      end
    end
  end
end
