module Facter::Util::Windows
  module Process; end

  if Facter::Util::Config.is_windows?
    require 'facter/util/windows/api_types'
    require 'facter/util/windows/error'
    require 'facter/util/windows/user'
    require 'facter/util/windows/process'
  end
end
