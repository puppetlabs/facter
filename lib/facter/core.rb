Facter.add(:facterversion) do
    setcode { Facter::FACTERVERSION.to_s }
end

Facter.add(:rubyversion) do
    setcode { RUBY_VERSION.to_s }
end

Facter.add(:puppetversion) do
    setcode {
        begin
            require 'puppet'
            Puppet::PUPPETVERSION.to_s
        rescue LoadError
            nil
        end
    }
end

Facter.add :rubysitedir do
    setcode do
        version = RUBY_VERSION.to_s.sub(/\.\d+$/, '')
        $:.find do |dir|
            dir =~ /#{File.join("site_ruby", version)}$/
        end
    end
end
