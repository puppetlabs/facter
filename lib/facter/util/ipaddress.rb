require 'facter/util/resolution'

module Facter
module Util
module IPAddress
  ##
  # ifconfig provides a wrapper around Facter::Util::Resolution.exec intended
  # to be stubbed in the tests.
  def self.ifconfig(command="ifconfig 2>/dev/null")
    Facter::Util::Resolution.exec(command)
  end
end
end
end
