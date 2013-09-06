require 'windows/system_info'
require 'windows/security'
require 'sys/admin'

module Facter::Util::Root
  extend ::Windows::SystemInfo
  extend ::Windows::Security

  def self.root?
    # if Vista or later, check for unrestricted process token
    return Win32::Security.elevated_security? unless windows_version < 6.0

    # otherwise 2003 or less
    check_token_membership
  end

  def self.check_token_membership
    sid = 0.chr * 80
    size = [80].pack('L')
    member = 0.chr * 4

    unless CreateWellKnownSid(Windows::Security::WinBuiltinAdministratorsSid, nil, sid, size)
      raise "Failed to create administrators SID"
    end

    unless IsValidSid(sid)
      raise "Invalid SID"
    end

    unless CheckTokenMembership(nil, sid, member)
      raise "Failed to check membership"
    end

    # Is administrators SID enabled in calling thread's access token?
    member.unpack('L')[0] == 1
  end
end
