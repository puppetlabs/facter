# Fact: lsbmajdistrelease
#
# Purpose: Returns the major version of the operation system version as gleaned
# from the lsbdistrelease fact.
#
# Resolution:
#   Parses the lsbdistrelease fact for numbers followed by a period and
#   returns those, or just the lsbdistrelease fact if none were found.
#
Facter.add('lsbmajdistrelease') do
  confine(:lsbdistrelease) {|ver| !!ver }

  regexp = /(\d+)\./

  setcode do
    lsbdistrelease = Facter.value(:lsbdistrelease)
    mdata = regexp.match(lsbdistrelease)
    mdata ? mdata[1] : lsbdistrelease
  end
end
