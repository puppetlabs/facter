# Fact: path
#
# Purpose: 
#   Returns the $PATH variable.
#
# Resolution: 
#   Gets $PATH from the environment.
#
## path.rb
#

Facter.add(:path) do
  setcode do
    ENV['PATH']
  end
end
