module Facter::Util::Partitions
  module Linux
    # Only Linux 2.6+ kernels support sysfs which is required to easily get device details
    SYSFS_BLOCK_DIRECTORY     = '/sys/block/'
    DEVDISK_BY_UUID_DIRECTORY = '/dev/disk/by-uuid/'

    def self.list
      if File.exist?(SYSFS_BLOCK_DIRECTORY)
        devices = Dir.entries(SYSFS_BLOCK_DIRECTORY).select { |d| File.exist?( SYSFS_BLOCK_DIRECTORY + d + "/device" ) }
  
        if devices.empty?
          []
        else
          devices.collect do |device|
            Dir.glob( SYSFS_BLOCK_DIRECTORY + device + "/#{device}*" ).collect do |d|
              File.basename(d)
            end
          end.flatten
        end
      else
        []
      end
    end

    def self.uuid(partition)
      uuid = nil
      if File.exist?(DEVDISK_BY_UUID_DIRECTORY)
        Dir.entries(DEVDISK_BY_UUID_DIRECTORY).each do |file|
          qualified_file = File.join(DEVDISK_BY_UUID_DIRECTORY, file)

          #A uuid is 16 octets long (RFC4122) which is 32hex chars + 4 '-'s
          next unless file.length == 36
          next unless File.symlink?(qualified_file)
          next unless File.readlink(qualified_file).match(%r[(?:\.\./\.\./|/dev/)#{partition}$])

          uuid = file
        end
      end
      uuid
    end

    def self.size(partition)
      read_size(partition)
    end

    def self.mount(partition)
      if Facter::Core::Execution.which('mount')
        Facter::Core::Execution.exec('mount').scan(/\/dev\/#{partition}\son\s(\S+)/).flatten.first
      end
    end

    def self.filesystem(partition)
      if Facter::Core::Execution.which('blkid')
        Facter::Core::Execution.exec("blkid #{File.join('/dev', partition)}").scan(/TYPE="([^"]*)"/).flatten.first
      end
    end
    
    def self.label(partition)
      if Facter::Core::Execution.which('blkid')
        Facter::Core::Execution.exec("blkid #{File.join('/dev', partition)}").scan(/LABEL="([^"]*)"/).flatten.first
      end
    end
    
    private
    def self.read_size(partition)
      if device = partition.match(/(\D+)/)[1] and File.readable?(File.join(SYSFS_BLOCK_DIRECTORY, device, partition, 'size'))
        File.read(File.join(SYSFS_BLOCK_DIRECTORY, device, partition, 'size')).chomp
      end
    end
  end
end
