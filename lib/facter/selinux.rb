# Fact for SElinux
# Written by immerda admin team (admin(at)immerda.ch)

Facter.add("selinux") do
    confine :kernel => :linux

    setcode do
        result = "false"
        if FileTest.exists?("/selinux/enforce")
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
        if FileTest.exists?("/selinux/enforce") and File.read("/selinux/enforce") =~ /1/i
            result = "true"
        end
        result
    end
end

Facter.add("selinux_policyversion") do
    confine :selinux => :true
    setcode do
        File.read("/selinux/policyvers")
    end
end

Facter.add("selinux_current_mode") do
    confine :selinux => :true
    setcode do
	result = 'unknown'
        mode = Facter::Util::Resolution.exec('/usr/sbin/sestatus')
        mode.each_line { |l| result = $1 if l =~ /^Current mode\:\s+(\w+)$/i }
        result.chomp
    end
end

Facter.add("selinux_config_mode") do
    confine :selinux => :true
    setcode do
        result = 'unknown'
        mode = Facter::Util::Resolution.exec('/usr/sbin/sestatus')
        mode.each_line { |l| result = $1 if l =~ /^Mode from config file\:\s+(\w+)$/i }
        result.chomp
    end
end

Facter.add("selinux_config_policy") do
    confine :selinux => :true
    setcode do
        result = 'unknown'
        mode = Facter::Util::Resolution.exec('/usr/sbin/sestatus')
        mode.each_line { |l| result = $1 if l =~ /^Policy from config file\:\s+(\w+)$/i }
        result.chomp
    end
end

# This is a legacy fact which returns the old selinux_mode fact value to prevent 
# breakages of existing manifests. It should be removed at the next major release.
# See ticket #6677.

Facter.add("selinux_mode") do
    confine :selinux => :true
    setcode do
        Facter.value(:selinux_config_policy)
    end
end
