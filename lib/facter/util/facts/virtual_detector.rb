# frozen_string_literal: true

module Facter
  module Util
    module Facts
      class VirtualDetector
        def initialize
          @log = Facter::Log.new(self)
        end

        def platform # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          fact_value = check_docker_lxc || check_dmi || check_freebsd || check_gce || retrieve_from_virt_what
          fact_value ||= check_vmware || check_open_vz || check_vserver || check_xen || check_other_facts
          fact_value ||= check_lspci || 'physical'

          fact_value
        end

        def check_docker_lxc
          @log.debug('Checking Docker and LXC')
          Facter::Resolvers::Containers.resolve(:vm)
        end

        def check_dmi
          @log.debug('Checking DMI')
          vendor = Facter::Resolvers::DmiDecode.resolve(:vendor)
          @log.debug("dmi detected vendor: #{vendor}")
          return 'kvm' if vendor =~ /Amazon/

          'xen' if vendor =~ /Xen/
        end

        def check_gce
          @log.debug('Checking GCE')
          bios_vendor = Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
          'gce' if bios_vendor&.include?('Google')
        end

        def check_vmware
          @log.debug('Checking VMware')
          Facter::Resolvers::Vmware.resolve(:vm)
        end

        def retrieve_from_virt_what
          @log.debug('Checking virtual_what')
          Facter::Resolvers::VirtWhat.resolve(:vm)
        end

        def check_open_vz
          @log.debug('Checking OpenVZ')
          Facter::Resolvers::OpenVz.resolve(:vm)
        end

        def check_vserver
          @log.debug('Checking VServer')
          Facter::Resolvers::VirtWhat.resolve(:vserver)
        end

        def check_xen
          @log.debug('Checking XEN')
          Facter::Resolvers::Xen.resolve(:vm)
        end

        def check_freebsd
          return unless Object.const_defined?('Facter::Resolvers::Freebsd::Virtual')

          @log.debug('Checking if jailed')
          Facter::Resolvers::Freebsd::Virtual.resolve(:vm)
        end

        def check_other_facts
          @log.debug('Checking others')
          product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)
          bios_vendor =  Facter::Resolvers::Linux::DmiBios.resolve(:bios_vendor)
          return 'kvm' if bios_vendor&.include?('Amazon EC2')
          return unless product_name

          Facter::Util::Facts::HYPERVISORS_HASH.each { |key, value| return value if product_name.include?(key) }

          nil
        end

        def check_lspci
          @log.debug('Checking lspci')
          Facter::Resolvers::Lspci.resolve(:vm)
        end
      end
    end
  end
end
