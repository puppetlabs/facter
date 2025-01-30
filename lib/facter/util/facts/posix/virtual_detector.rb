# frozen_string_literal: true

module Facter
  module Util
    module Facts
      module Posix
        module VirtualDetector
          class << self
            def platform
              @fact_value ||= # rubocop:disable Naming/MemoizedInstanceVariableName
                check_docker_lxc || check_freebsd || check_openbsd || check_gce || check_illumos_lx || \
                retrieve_from_virt_what || check_vmware || check_open_vz || check_vserver || \
                check_xen || check_other_facts || check_lspci || 'physical'
            end

            private

            def check_docker_lxc
              resolve(Facter::Resolvers::Containers, :vm)
            end

            def check_gce
              bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
              'gce' if bios_vendor&.include?('Google')
            end

            def check_illumos_lx
              'illumos-lx' if Facter::Resolvers::Uname.resolve(:kernelversion) == 'BrandZ virtual linux'
            end

            def check_vmware
              resolve(Facter::Resolvers::Vmware, :vm)
            end

            def retrieve_from_virt_what
              resolve(Facter::Resolvers::VirtWhat, :vm)
            end

            def check_open_vz
              resolve(Facter::Resolvers::OpenVz, :vm)
            end

            def check_vserver
              resolve(Facter::Resolvers::VirtWhat, :vserver)
            end

            def check_xen
              resolve(Facter::Resolvers::Xen, :vm)
            end

            def check_freebsd
              return unless Object.const_defined?('Facter::Resolvers::Freebsd::Virtual')

              resolve(Facter::Resolvers::Freebsd::Virtual, :vm)
            end

            def check_openbsd
              return unless Object.const_defined?('Facter::Resolvers::Openbsd::Virtual')

              resolve(Facter::Resolvers::Openbsd::Virtual, :vm)
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
              resolve(Facter::Resolvers::Lspci, :vm)
            end

            def resolve(resolver, fact_name)
              value = resolver.resolve(fact_name)
              resolver.log.debug("Resolved '#{fact_name}' to '#{value}'")
              value
            end
          end
        end
      end
    end
  end
end
