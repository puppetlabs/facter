Facter.add :rubysitedir do
    setcode do
        version = RUBY_VERSION.to_s.sub(/\.\d+$/, '')
        $:.find do |dir|
            dir =~ /#{File.join("site_ruby", version)}$/
        end
    end
end
