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

# A base module for collecting IP-related
# information from all kinds of platforms.
module Facter::Util::IP
  # Convert an interface name into purely alphanumeric characters.
  #
  # @param [String] interface e.g. 'eth0'
  #
  # @return [String]
  #
  # @api public
  def self.alphafy(interface)
    interface.to_s.gsub(/[^a-z0-9_]/i, '_')
  end

  # Returns an array of supported platforms in string format. These array values
  # are synonymous with the values returned from Facter.value(:kernel).
  #
  # @return [Array] contains strings corresponding to a kernel
  #
  # @api public
  def self.supported_platforms
    kernel_classes.map(&:to_s)
  end

  # A delegate method to the kernel's subclass ultimately obtaining the
  # interfaces.
  #
  # @return [Array]
  #
  # @api public
  def self.interfaces
    kernel_class.interfaces
  end

  # Uses the ifconfig command
  #
  # @param [Array] additional arguments
  #
  # @return [String] the output of the command
  #
  # @api public
  def self.exec_ifconfig(additional_arguments=[])
    Facter::Util::Resolution.exec("#{self.get_ifconfig} #{additional_arguments.join(' ')}")
  end

  # Looks up the ifconfig binary.
  #
  # @return [String] path to the ifconfig binary
  #
  # @api public
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
  # @api public
  def self.value_for_interface_and_label(interface, label)
    if kernel_supported?
      kernel_class.value_for_interface_and_label(interface, label)
    end
  end

  # A delegate method to obtain the network of an interface
  #
  # @param interface [String] e.g 'eth0'
  #
  # @return [String] or [NilClass]
  #
  # @api public
  def self.network(interface)
    if kernel_supported?
      kernel_class.network(interface, label)
    end
  end

  private

  # A delegate method for obtaining Facter::Util::IP::Base's subclasses.
  #
  # @return [Array]
  #
  # @api private
  def self.kernel_classes
    Facter::Util::IP::Base.subclasses
  end

  # Obtains the cooresponding Facter::Util::IP::Base subclass for the current
  # kernel.
  #
  # @return Subclass of [Facter::Util::IP::Base]
  #
  # @api private
  def self.kernel_class
    kernel_classes.find { |klass| klass.to_s == Facter.value(:kernel) }
  end

  # Boolean to determine whether the current kernel is supported.
  #
  # @return [Boolean] true or false
  #
  # @api private
  def self.kernel_supported?
    supported_platforms.include?(Facter.value(:kernel))
  end
end
