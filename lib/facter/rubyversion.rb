# Fact: rubyversion
#
# Purpose: Returns the version of Ruby facter is running under.
#
# Resolution: Returns RUBY_VERSION.
#
# Caveats:
#

Facter.add(:rubyversion) do
    setcode { RUBY_VERSION.to_s }
end
