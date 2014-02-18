require 'facter/util/blockdevices/linux'
require 'facter/util/blockdevices/freebsd'

module Facter::Util::Blockdevices

  IMPLEMENTATIONS = {
    'FreeBSD' => FreeBSD,
    'Linux'   => Linux
  }

  module NoImplementation
    def self.devices
      []
    end

    def self.device_partitions
      []
    end
  end

  def self.implementation
    IMPLEMENTATIONS[Facter.value(:kernel)] || NoImplementation
  end

  def self.devices
    implementation.devices
  end

  def self.device_model(device_name)
    implementation.device_model(device_name)
  end

  def self.device_vendor(device_name)
    implementation.device_vendor(device_name)
  end

  def self.device_size(device_name)
    implementation.device_size(device_name)
  end

  def self.device_partitions(device_name)
    if Facter.value(:kernel) == 'Linux'
      implementation.device_partitions(device_name)
    else
      NoImplementation.device_partitions
    end
  end

  def self.partition_uuid(partition_name)
    implementation.partition_uuid(partition_name)
  end

  def self.available?
    !self.devices.empty?
  end

end
