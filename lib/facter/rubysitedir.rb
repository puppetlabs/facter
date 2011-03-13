# Fact: rubysitedir
#
# Purpose: Returns Ruby's site library directory.
#
# Resolution: Works out the version to major/minor (1.8, 1.9, etc), then joins
# that with all the $: library paths.
#
# Caveats:
#

Facter.add :rubysitedir do
    setcode do
        version = RUBY_VERSION.to_s.sub(/\.\d+$/, '')
        $:.find do |dir|
            dir =~ /#{File.join("site_ruby", version)}$/
        end
    end
end
