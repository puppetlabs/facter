# Fact: rubyplatform
#
# Purpose: Returns the platform of Ruby that facter is running under.
#
# Resolution: Returns the value of the `RUBY_PLATFORM` constant.
#
# Caveats:
#

Facter.add(:rubyplatform) do
  setcode { RUBY_PLATFORM.to_s }
end
