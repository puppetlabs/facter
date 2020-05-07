# frozen_string_literal: true

module Facter
  module Resolvers
    class Virtualization < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        # Virtual
        # Is_Virtual

        MODEL_HASH = { 'VirtualBox' => 'virtualbox', 'VMware' => 'vmware', 'KVM' => 'kvm',
                       'Bochs' => 'bochs', 'Google' => 'gce', 'OpenStack' => 'openstack' }.freeze

        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_fact_from_computer_system(fact_name) }
        end

        def read_fact_from_computer_system(fact_name)
          win = Win32Ole.new
          comp = win.exec_query('SELECT Manufacturer,Model,OEMStringArray FROM Win32_ComputerSystem')
          unless comp
            @log.debug 'WMI query returned no results for Win32_ComputerSystem with values'\
            ' Manufacturer, Model and OEMStringArray.'
            return
          end

          build_fact_list(comp)
          @fact_list[fact_name]
        end

        def determine_hypervisor_by_model(comp)
          MODEL_HASH[MODEL_HASH.keys.find { |key| comp.Model =~ /^#{key}/ }]
        end

        def determine_hypervisor_by_manufacturer(comp)
          manufacturer = comp.Manufacturer
          if comp.Model =~ /^Virtual Machine/ && manufacturer =~ /^Microsoft/
            'hyperv'
          elsif manufacturer =~ /^Xen/
            'xen'
          elsif manufacturer =~ /^Amazon EC2/
            'kvm'
          else
            'physical'
          end
        end

        def build_fact_list(comp)
          @fact_list[:oem_strings] = []
          @fact_list[:oem_strings] += comp.to_enum.map(&:OEMStringArray).flatten

          comp = comp.to_enum.first
          hypervisor = determine_hypervisor_by_model(comp) || determine_hypervisor_by_manufacturer(comp)

          @fact_list[:virtual] = hypervisor
          @fact_list[:is_virtual] = hypervisor.include?('physical') ? false : true
        end
      end
    end
  end
end
