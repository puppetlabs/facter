module Facter::Util::Partitions
  module OpenBSD
    def self.list
      Facter::Core::Execution.exec('df').scan(/\/dev\/(\S+)/).flatten
    end

    # On OpenBSD partitions don't have a UUID; disks have DUID but that's not
    # compatible.
    def self.uuid(partition)
      nil
    end

    def self.mount(partition)
      scan_mount(/\/dev\/#{partition}\son\s(\S+)/)
    end

    # Reported size is in 1K blocks
    def self.size(partition)
      scan_df(/\/dev\/#{partition}\s+(\S+)/)
    end

    def self.filesystem(partition)
      scan_mount(/\/dev\/#{partition}\son\s\S+\stype\s(\S+)/)
    end
   
    # On OpenBSD there are no labels for partitions
    def self.label(partition)
      nil
    end

    private
    def self.scan_mount(scan_regex)
      Facter::Core::Execution.exec('mount').scan(scan_regex).flatten.first
    end

    def self.scan_df(scan_regex)
      Facter::Core::Execution.exec('df -k').scan(scan_regex).flatten.first
    end
  end
end
