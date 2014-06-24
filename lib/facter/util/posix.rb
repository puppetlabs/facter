module Facter
module Util
module POSIX
  # Provides a consistent way of invoking sysctl(8) across POSIX platforms
  #
  # @param mib [String] the sysctl(8) MIB name
  #
  # @api private
  def sysctl(mib)
    Facter::Util::Resolution.exec("sysctl -n #{mib} 2>/dev/null")
  end

  module_function :sysctl
end
end
end
