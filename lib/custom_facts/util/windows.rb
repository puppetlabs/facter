module LegacyFacter::Util::Windows
  module Process; end

  if LegacyFacter::Util::Config.windows?
    require_relative 'windows/api_types'
    require_relative 'windows/error'
    require_relative 'windows/user'
    require_relative 'windows/process'
  end
end
