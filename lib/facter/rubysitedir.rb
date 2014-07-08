# Fact: rubysitedir
#
# Purpose: Returns Ruby's site library directory.
#
# Resolution:
#   Uses the RbConfig module.
#

require 'rbconfig'

Facter.add :rubysitedir do
  setcode do
    RbConfig::CONFIG["sitelibdir"]
  end
end
