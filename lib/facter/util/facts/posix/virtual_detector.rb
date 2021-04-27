# frozen_string_literal: true

module Facter
  module Util
    module Facts
      module Posix
        module VirtualDetector
          class << self
            def platform
              @@fact_value ||= check_docker_lxc || check_freebsd || check_gce || retrieve_from_virt_what
              @@fact_value ||= check_vmware || check_open_vz || check_vserver || check_xen || check_other_facts
              @@fact_value ||= check_lspci || 'physical'

              @@fact_value
            end

            private

            def check_docker_lxc
              Facter::Resolvers::Containers.resolve(:vm)
            end

            def check_gce
              bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
              'gce' if bios_vendor&.include?('Google')
            end

            def check_vmware
              Facter::Resolvers::Vmware.resolve(:vm)
            end

            def retrieve_from_virt_what
              Facter::Resolvers::VirtWhat.resolve(:vm)
            end

            def check_open_vz
              Facter::Resolvers::OpenVz.resolve(:vm)
            end

            def check_vserver
              Facter::Resolvers::VirtWhat.resolve(:vserver)
            end

            def check_xen
              Facter::Resolvers::Xen.resolve(:vm)
            end

            def check_freebsd
              return unless Object.const_defined?('Facter::Resolvers::Freebsd::Virtual')

              Facter::Resolvers::Freebsd::Virtual.resolve(:vm)
            end

            def check_other_facts
              bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
              return 'kvm' if bios_vendor&.include?('Amazon EC2')

              product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
              return unless product_name

              Facter::Util::Facts::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }

              nil
            end

            def check_lspci
              Facter::Resolvers::Lspci.resolve(:vm)
            end
          end
        end
      end
    end
  end
end
