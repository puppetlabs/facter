# Fact: macosx
#
# Purpose:
#   Returns a number of Mac specific facts, from system profiler and
#   sw_vers.
#
# Resolution:
#   Uses util/macosx.rb to do the fact reconnaissance, then outputs them
#   preceded by `sp_`
#
# Caveats:
#

#
# macosx.rb
# Additional Facts coming from Mac OS X system_profiler command
#
# Copyright (C) 2007 Jeff McCune
# Author: Jeff McCune <jeff.mccune@northstarlabs.net>
#
# Jeff McCune
# There's a lot more information coming out of system_profiler -xml
# We could add quite a bit more, but I didn't want to overload facter
# at this point in time.
# In particular, Installed Software might be an interesting addition.

if Facter.value(:kernel) == "Darwin"
  require 'facter/util/macosx'

  Facter::Util::Macosx.hardware_overview.each do |fact, value|
    Facter.add("sp_#{fact}") do
      confine :kernel => :darwin
      setcode do
        value
      end
    end
  end

  Facter::Util::Macosx.os_overview.each do |fact, value|
    Facter.add("sp_#{fact}") do
      confine :kernel => :darwin
      setcode do
        value
      end
    end
  end

  Facter::Util::Macosx.sw_vers.each do |fact, value|
    Facter.add(fact) do
      confine :kernel => :darwin
      setcode do
        value
      end
    end
  end
end
