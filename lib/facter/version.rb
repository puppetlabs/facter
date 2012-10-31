module Facter
  if not defined? FACTERVERSION then
    FACTERVERSION = 'DEVELOPMENT'
  end

  def self.version
    @facter_version || FACTERVERSION
  end

  def self.version=(version)
    @facter_version = version
  end
end
