module Facter
  if not defined? FACTERVERSION then
    FACTERVERSION = '1.6.13'
  end

  def self.version
    @facter_version || FACTERVERSION
  end

  def self.version=(version)
    @facter_version = version
  end
end
