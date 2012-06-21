# Fact: rubysitedir
#
# Purpose: Returns Ruby's site library directory.
#

require 'rbconfig'

Facter.add :rubysitedir do
  setcode do
    RbConfig::CONFIG["sitelibdir"]
  end
end
