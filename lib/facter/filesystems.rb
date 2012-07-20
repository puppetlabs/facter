#
# filesystems.rb
#
# This fact provides an alphabetic list of usable file systems that can
# be used for block devices like hard drives, media cards and so on ...
#
Facter.add('filesystems') do
  confine :kernel => :linux

  exclude = /^nodev|fuseblk/

  setcode do
    # fuseblk can't be created and arguably isn't usable here. If you feel
    # this doesn't match your use-case please raise a bug.
    File.read('/proc/filesystems').
      split(/\n/).
      reject {|l| l =~ exclude }.
      map {|l| l.strip! }.
      join(',')
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
