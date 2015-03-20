raise 'nope' unless Facter.version == Facter::CFACTERVERSION && Facter.version == Facter::FACTERVERSION
Facter.debug Facter.version