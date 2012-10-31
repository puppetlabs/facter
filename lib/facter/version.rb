module Facter

  version = 'DEVELOPMENT'
  if version == 'DEVELOPMENT'
    %x{git rev-parse --is-inside-work-tree > /dev/null 2>&1}
    if $?.success?
      version = %x{git describe --tags --always 2>&1}.chomp
    end
  end

  if not defined? FACTERVERSION
    FACTERVERSION = version
  end

  def self.version
    @facter_version || FACTERVERSION
  end

  def self.version=(version)
    @facter_version = version
  end
end
