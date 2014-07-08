# Fact: rubyversion
#
# Purpose: Returns the version of Ruby facter is running under.
#
# Resolution: Returns the value of the `RUBY_VERSION` constant.
#
# Caveats:
#

Facter.add(:rubyversion) do
  setcode { RUBY_VERSION.to_s }
end
