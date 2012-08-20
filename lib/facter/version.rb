module Facter
  if not defined? FACTERVERSION then
    FACTERVERSION = '2.0.0-rc4'
  end

  def self.version
    @facter_version || FACTERVERSION
  end

  def self.version=(version)
    @facter_version = version
  end
end
