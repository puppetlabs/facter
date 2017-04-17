module Facter::Util::Partitions
  module OpenBSD
    @df_output = nil
    @mount_output = nil

    def self.list
      @df_output ||= run_df
      @df_output.scan(/\/dev\/(\S+)/).flatten
    end

    def self.flushable?
      true
    end

    def self.flush!
      @df_output = nil
      @mount_output = nil
    end

    def self.flushed?
      !@df_output
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
    def self.run_mount
      Facter::Core::Execution.exec('mount')
    end

    def self.run_df
      Facter::Core::Execution.exec('df -k')
    end

    def self.scan_mount(scan_regex)
      @mount_output ||= run_mount
      @mount_output.scan(scan_regex).flatten.first
    end

    def self.scan_df(scan_regex)
      @df_output ||= run_df
      @df_output.scan(scan_regex).flatten.first
    end
  end
end
