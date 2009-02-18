Facter.add(:kernel) do
    setcode do
        require 'rbconfig'
        case Config::CONFIG['host_os']
        when /mswin/i; 'windows'
        else Facter::Util::Resolution.exec("uname -s")
        end
    end
end
