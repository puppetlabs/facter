# frozen_string_literal: true

module Facter
  module Resolvers
    class Virtualization < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        # Virtual
        # Is_Virtual

        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_fact_from_computer_system(fact_name)
          end
        end

        private

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
          model_hash = { 'VirtualBox' => 'virtualbox', 'VMware' => 'vmware', 'KVM' => 'kvm',
                         'Bochs' => 'bochs', 'Google' => 'gce', 'OpenStack' => 'openstack' }
          model_hash[model_hash.keys.find { |key| comp.Model =~ /^#{key}/ }]
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
          @fact_list[:is_virtual] = (!hypervisor.include?('physical')).to_s
        end
      end
    end
  end
end
