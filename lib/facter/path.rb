# Fact: path
#
# Purpose: 
#   Returns the $PATH variable.
#
# Resolution: 
#   Gets $PATH from the environment.
#

Facter.add(:path) do
  setcode do
    ENV['PATH']
  end
end
