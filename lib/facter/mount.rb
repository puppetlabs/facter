#
# mounts.rb
#
# This fact provides list of mount points present in the system alongside
# any known block devices on which a particular mount point resides ...
#
# We do some filtering based on patterns for file systems and devices that
# make no sense and are not of our concern ...
#

require 'facter'

def enumerate_proc
  # We store a list of block devices hosting mount points here ...
  mounts = []

  # We store a list of mount points present in the system here ...
  devices = []

  # Support for the following might not be of interest ...
  exclude = %w( afs anon_inodefs aufs autofs bdev bind binfmt_.* cgroup cifs coda
    cpuset debugfs devfs devpts ecryptfs fd ftpfs fuse.* gvfs.* hugetlbfs inotifyfs
    iso9660 lustre.* mfs mqueue ncpfs NFS nfs.* none pipefs proc ramfs rootfs rpc_.*
    securityfs shfs shm smbfs sockfs sysfs tmpfs udev udf unionfs usbfs )

  #
  # Modern Linux kernels provide "/proc/mounts" in the following format:
  #
  #   rootfs / rootfs rw 0 0
  #   none /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
  #   none /proc proc rw,nosuid,nodev,noexec,relatime 0 0
  #   udev /dev tmpfs rw,relatime,mode=755 0 0
  #   none /sys/kernel/security securityfs rw,relatime 0 0
  #   none /sys/fs/fuse/connections fusectl rw,relatime 0 0
  #   none /sys/kernel/debug debugfs rw,relatime 0 0
  #   none /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
  #   none /dev/shm tmpfs rw,nosuid,nodev,relatime 0 0
  #   none /var/run tmpfs rw,nosuid,relatime,mode=755 0 0
  #   none /var/lock tmpfs rw,nosuid,nodev,noexec,relatime 0 0
  #   none /lib/init/rw tmpfs rw,nosuid,relatime,mode=755 0 0
  #   /dev/sda5 /home xfs rw,relatime,attr2,noquota 0 0
  #   /dev/sda1 /boot ext3 rw,relatime,errors=continue,data=ordered 0 0
  #   binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc rw,nosuid,nodev,noexec,relatime 0 0
  #

  # Make regular expression from our patterns ...
  exclude = Regexp.union(exclude.collect { |i| Regexp.new(i) })

  # List of numeric identifiers with their corresponding canonical forms ...
  known_devices = Dir.glob('/dev/*').inject({}) do |k,v|
    #
    # We protect ourselves against broken symbolic links under "/dev" and
    # skip all non-block devices as for example a sound card cannot really
    # host a file system ...
    #
    if File.exists?(v) and File.blockdev?(v)
      # Resolve any symbolic links we may encounter ...
      v = File.readlink(v) if File.symlink?(v)

      #
      # Make sure that we have full path to the entry under "/dev" ...
      # This tends to be often broken there ...  Relative path hell ...
      #
      v = File.join('/dev', v) unless File.exists?(v)

      k.update(File.stat(v).rdev => v)
    end

    k # Yield hash back into the block ...
  end

  #
  # We utilise rely on "cat" for reading values from entries under "/proc".
  # This is due to some problems with IO#read in Ruby and reading content of
  # the "proc" file system that was reported more than once in the past ...
  #
  Facter::Util::Resolution.exec("cat /proc/mounts 2> /dev/null").each_line do |line|
    # Remove bloat ...
    line.strip!

    # Line of interest should not start with ...
    next if line.empty? or line.match(/^none/)

    # We have something, so let us apply our device type filter ...
    next if line.match(exclude)

    # At this point we split single and valid row into tokens ...
    row = line.split(' ')

    # Only device and mount point are of interest ...
    #
    # When there are any spaces in the mount point name then Kernel will
    # replace them with as octal "\040" (which is 32 decimal).  We have
    # to accomodate for this and convert them back into proper spaces ...
    #
    # An example of such case:
    #
    #   /dev/sda1 /srv/shares/My\040Files ext3 rw,relatime,errors=continue,data=ordered 0 0
    #
    device = row[0].strip.gsub('\\040', ' ')
    mount  = row[1].strip.gsub('\\040', ' ')

    #
    # Correlate mount point with a real device that exists in the system.
    # This is to take care about entries like "rootfs" under "/proc/mounts".
    #
    device = known_devices.values_at(File.stat(mount).dev).shift || device

    # Add where appropriate ...
    devices << device
    mounts  << mount
  end
  
  [devices,mounts]
end

Facter.add('mount_devices') do
  confine :kernel => :linux
  setcode { enumerate_proc[0].sort.uniq.join(',') }
end

Facter.add('mount_points') do
  confine :kernel => :linux
  setcode { enumerate_proc[1].uniq.join(',') }
end