# A module to help test architecture facts on non-AIX test hardware

module Facter::Util::Architecture
  ##
  # lsattr is intended to directly delegate to Facter::Core::Execution.exec in
  # an effort to make the processorX facts easier to test.  See also the
  # {lsdev} method.
  def self.lsattr(command="lsattr -El proc0 -a type")
    Facter::Core::Execution.exec(command)
  end

  ##
  # kernel_fact_value is intended to directly delegate to Facter.value(:kernel)
  # to make it easier to stub the kernel fact without affecting the entire
  # system.
  def self.kernel_fact_value
    Facter.value(:kernel)
  end
end
