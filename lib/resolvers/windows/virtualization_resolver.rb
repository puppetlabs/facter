# frozen_string_literal: true

class VirtualizationResolver < BaseResolver
  class << self
    # Manufacturer
    # Name
    # SerialNumber
    # UUID
    @@semaphore = Mutex.new
    @@fact_list ||= {}

    def resolve(fact_name)
      @@semaphore.synchronize do
        result ||= @@fact_list[fact_name]
        return result if result

        result || read_fact_from_computer_system(fact_name)
      end
    end

    def invalidate_cache
      @@fact_list = {}
    end

    private

    def read_fact_from_computer_system(fact_name)
      win = Win32Ole.new
      comp = win.exec_query('SELECT Manufacturer,Model FROM Win32_ComputerSystem').to_enum.first
      hypervisor = determine_hypervisor_by_model(comp) || determine_hypervisor_by_manufacturer(comp)
      build_fact_list(hypervisor)

      @@fact_list[fact_name]
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

    def build_fact_list(hypervisor)
      @@fact_list[:virtual] = hypervisor
      @@fact_list[:is_virtual] = (!hypervisor.include?('physical')).to_s
    end
  end
end
