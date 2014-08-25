# Fact: filesystems
#
# Purpose:
#   This fact provides an alphabetic list of usable file systems that can
#   be used for block devices like hard drives, media cards, etc.
#
# Resolution:
#   Checks `/proc/filesystems`.
#
# Caveats:
#   Only supports Linux.
#

Facter.add('filesystems') do
  confine :kernel => :linux
  setcode do
    # fuseblk can't be created and arguably isn't usable here. If you feel this
    # doesn't match your use-case please raise a bug.
    exclude = %w(fuseblk)

    # Make regular expression form our patterns ...
    exclude = Regexp.union(*exclude.collect { |i| Regexp.new(i) })

    # We utilise rely on "cat" for reading values from entries under "/proc".
    # This is due to some problems with IO#read in Ruby and reading content of
    # the "proc" file system that was reported more than once in the past ...
    file_systems = []
    Facter::Core::Execution.exec('cat /proc/filesystems 2> /dev/null').each_line do |line|
      # Remove bloat ...
      line.strip!

      # Line of interest should not start with "nodev" ...
      next if line.empty? or line.match(/^nodev/)

      # We have something, so let us apply our device type filter ...
      next if line.match(exclude)

      file_systems << line
    end
    file_systems.sort.join(',')
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
