# Fact: selinux
#
# Purpose:
#
# Resolution:
#
# Caveats:
#

# Fact for SElinux
# Written by immerda admin team (admin(at)immerda.ch)

sestatus_cmd = '/usr/sbin/sestatus'

# This supports the fact that the selinux mount point is not always in the
# same location -- the selinux mount point is operating system specific.
def selinux_mount_point
  path = "/selinux"
  if FileTest.exists?('/proc/self/mounts')
    # Centos 5 shows an error in which having ruby use File.read to read
    # /proc/self/mounts combined with the puppet agent run with --listen causes
    # a hang. Reading from other parts of /proc does not seem to cause this problem.
    # The work around is to read the file in another process.
    # -- andy Fri Aug 31 2012
    selinux_line = Facter::Core::Execution.exec('cat /proc/self/mounts').each_line.find { |line| line =~ /selinuxfs/ }
    if selinux_line
      path = selinux_line.split[1]
    end
  end
  path
end

Facter.add("selinux") do
  confine :kernel => :linux
  setcode do
    result = "false"
    if FileTest.exists?("#{selinux_mount_point}/enforce")
      if FileTest.exists?("/proc/self/attr/current")
        if (File.read("/proc/self/attr/current") != "kernel\0")
          result = "true"
        end
      end
    end
    result
  end
end

Facter.add("selinux_enforced") do
  confine :selinux => :true
  setcode do
    result = "false"
    if FileTest.exists?("#{selinux_mount_point}/enforce") and
       File.read("#{selinux_mount_point}/enforce") =~ /1/i
      result = "true"
    end
    result
  end
end

Facter.add("selinux_policyversion") do
  confine :selinux => :true
  setcode do
    result = 'unknown'
    if FileTest.exists?("#{selinux_mount_point}/policyvers")
      result = File.read("#{selinux_mount_point}/policyvers").chomp
    end
    result
  end
end

Facter.add("selinux_current_mode") do
  confine :selinux => :true
  setcode do
    result = 'unknown'
    mode = Facter::Core::Execution.exec(sestatus_cmd)
    mode.each_line { |l| result = $1 if l =~ /^Current mode\:\s+(\w+)$/i }
    result.chomp
  end
end

Facter.add("selinux_config_mode") do
  confine :selinux => :true
  setcode do
    result = 'unknown'
    mode = Facter::Core::Execution.exec(sestatus_cmd)
    mode.each_line { |l| result = $1 if l =~ /^Mode from config file\:\s+(\w+)$/i }
    result.chomp
  end
end

Facter.add("selinux_config_policy") do
  confine :selinux => :true
  setcode do
    result = 'unknown'
    mode = Facter::Core::Execution.exec(sestatus_cmd)
    mode.each_line { |l| result = $1 if l =~ /^Policy from config file\:\s+(\w+)$/i }
    result.chomp
  end
end
