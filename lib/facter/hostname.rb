Facter.add(:hostname, :ldapname => "cn") do
    setcode do
        require 'socket'
        hostname = nil
        name = Socket.gethostbyname(Socket.gethostname).first
        if name
            if name =~ /^([\w-]+)\.(.+)$/
                hostname = $1
                # the FQDN/Domain facts use this
                $fqdn = name
            else
                hostname = name
            end
            hostname
        else
            nil
        end
    end
end

Facter.add(:hostname) do
    confine :kernel => :darwin, :kernelrelease => "R7"
    setcode do
        %x{/usr/sbin/scutil --get LocalHostName}
    end
end
