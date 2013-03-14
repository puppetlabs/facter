# encoding: UTF-8

require 'facter/util/ip/base'
require 'facter/util/ip/darwin'
require 'facter/util/ip/sun_os'
require 'facter/util/ip/linux'
require 'facter/util/ip/net_bsd'
require 'facter/util/ip/open_bsd'
require 'facter/util/ip/free_bsd'
require 'facter/util/ip/dragonfly'
require 'facter/util/ip/windows'
require 'facter/util/ip/hpux'
require 'facter/util/ip/gnu_k_free_bsd'

# A base module for collecting IP related info from all kinds of platforms.
class Facter::Util::IP
  INTERFACE_KEYS = %w[ipaddress ipaddress6 macaddress netmask mtu]

  attr_accessor :interfaces_hash

  # Uses the interfaces stored in {@interfaces} to obtain and parse the
  # attributes corresponding to {INTERFACE_KEYS} and stores the resulting hash
  # in {@interfaces_hash}.
  #
  # @api private
  def parse!
    @interfaces_hash = @interfaces.inject({}) do |hashA, interface|
      hashA[interface] = INTERFACE_KEYS.inject({}) do |hashB, key|
        hashB[key] = value_for_interface_and_label interface, key

        hashB
      end

      hashA[interface][:network] = network interface

      hashA
    end
  end

  # Adds interface facts like 'eth0'. Also defines dynamic facts describing
  # attributes of each interface, like 'ipaddress_eth0' and 'network_eth0'.
  #
  # @api private
  def self.add_interface_facts
    model = new

    model.refresh
    model.add_dynamic_interface_facts

    Facter.add :interfaces do
      confine :kernel => model.supported_platforms

      setcode do
        model.refresh if model.flushed?
        model.add_dynamic_interface_facts
        model.stringified_interfaces
      end

      on_flush { model.flush! }
    end
  end


  # Convert an interface name into purely alphanumeric characters.
  #
  # @param [String] interface e.g. 'eth0'
  #
  # @return [String]
  #
  # @api private
  def self.alphafy(interface)
    interface.to_s.gsub(/[^a-z0-9_]/i, '_')
  end

  # Returns an array of supported platforms in string format. These array values
  # are synonymous with the values returned from Facter.value(:kernel).
  #
  # @return [Array] contains strings corresponding to a kernel
  #
  # @api private
  def supported_platforms
    kernel_classes.map(&:to_s)
  end

  # A delegate method to the kernel's subclass ultimately obtaining the
  # interfaces.
  #
  # @return [Array]
  #
  # @api private
  def interfaces
    kernel_class.interfaces
  end

  # Uses the ifconfig command
  #
  # @param [Array] additional arguments
  #
  # @return [String] the output of the command
  #
  # @api private
  def self.exec_ifconfig(additional_arguments=[])
    Facter::Util::Resolution.exec("#{self.get_ifconfig} #{additional_arguments.join(' ')}")
  end

  # Looks up the ifconfig binary.
  #
  # @return [String] path to the ifconfig binary
  #
  # @api private
  def self.get_ifconfig
    common_paths=["/bin/ifconfig","/sbin/ifconfig","/usr/sbin/ifconfig"]
    common_paths.select{|path| File.executable?(path)}.first
  end

  # A delegate method to `value_for_interface_and_label` which is implemented in
  # Facter::Util::IP::Base and it's subclasses.
  #
  # @param interface [String] label [String] e.g ['eth0', 'MTU']
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def value_for_interface_and_label(interface, label)
    kernel_class.value_for_interface_and_label interface, label
  end

  # A delegate method to obtain the network of an interface
  #
  # @param interface [String] e.g 'eth0'
  #
  # @return [String] or [NilClass]
  #
  # @api private
  def network(interface)
    kernel_class.network(interface)
  end

  # A delegate method for obtaining Facter::Util::IP::Base's subclasses.
  #
  # @return [Array]
  #
  # @api private
  def kernel_classes
    Facter::Util::IP::Base.subclasses
  end

  # Obtains the cooresponding Facter::Util::IP::Base subclass for the current
  # kernel.
  #
  # @return Subclass of [Facter::Util::IP::Base]
  #
  # @api private
  def kernel_class
    kernel_classes.find { |klass| klass.to_s == Facter.value(:kernel) }
  end

  # Boolean to determine whether the current kernel is supported.
  #
  # @return [Boolean] true or false
  #
  # @api private
  def kernel_supported?
    supported_platforms.include?(Facter.value(:kernel))
  end

  # Stringifies interfaces so that it can be used as a fact value.
  #
  # @return [String] the interfaces as a string
  #
  # @api private
  def stringified_interfaces
    alphafied_interfaces = @interfaces.map do |interface|
      Facter::Util::IP.alphafy(interface)
    end

    alphafied_interfaces.join ','
  end

  # Defines all of the dynamic interface facts derived from parsing the output
  # of the network interface ouput. The interface facts are dynamic, so this
  # method has the behavior of figuring out what facts need to be added and how
  # they should be resolved.
  #
  # @api private
  def add_dynamic_interface_facts
    model = self

    @interfaces.each do |interface|
      INTERFACE_KEYS.each do |key|
        Facter.add "#{key}_#{model.class.alphafy(interface)}" do
          confine :kernel => model.supported_platforms

          setcode do
            model.refresh if model.flushed?

            # Don't resolve if the interface has since been deleted
            if keys_hash = model.interfaces_hash[interface]
              keys_hash[key]
            end
          end

          on_flush { model.flush! }
        end
      end

      Facter.add "network_#{interface}" do
        confine :kernel => model.supported_platforms

        setcode do
          model.refresh if model.flushed?

          # Don't resolve if the interface has since been deleted
          if keys_hash = model.interfaces_hash[interface]
            keys_hash[:network]
          end
        end

        on_flush { model.flush! }
      end
    end
  end

  # Executes the platform specific system command to obtain the interfaces and
  # stores them in {@interfaces}.
  #
  # @api private
  def refresh
    @interfaces = interfaces

    parse!
  end

  # Checks to see if the intstance has been flushed.
  #
  # @return [Boolean] true if there is no parsed data
  #
  # @api private
  def flushed?
    !interfaces_hash
  end

  # Purges the saved data so that the fact can be resolved properly upon flush.
  #
  # @api private
  def flush!
    @interfaces_hash = nil
  end
end
