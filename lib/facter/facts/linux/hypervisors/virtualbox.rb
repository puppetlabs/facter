# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class VirtualBox
        FACT_NAME = 'hypervisors.virtualbox'

        def call_the_resolver
          fact_value = check_virtualbox
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        def check_virtualbox
          virtualbox_details = nil

          if Facter::Resolvers::Linux::DmiBios.resolve(:product_name) == 'VirtualBox' ||
             Facter::Resolvers::VirtWhat.resolve(:vm) =~ /virtualbox/ ||
             Facter::Resolvers::Lspci.resolve(:vm) == 'virtualbox'

            virtualbox_details = {}

            version = Facter::Resolvers::DmiDecode.resolve(:virtualbox_version)
            revision = Facter::Resolvers::DmiDecode.resolve(:virtualbox_revision)

            virtualbox_details[:version] = version if version
            virtualbox_details[:revision] = revision if revision
          end

          virtualbox_details
        end
      end
    end
  end
end
