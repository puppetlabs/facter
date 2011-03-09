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

Facter.add("selinux_mode") do
    confine :selinux => :true
    setcode do
	result = 'unknown'
        mode = Facter::Util::Resolution.exec('/usr/sbin/sestatus')
        mode.each_line { |l| result = $1 if l =~ /^Current mode\:\s+(\w+)$/i }
        result.chomp
    end
end
