require 'facter/util/windows'

module Facter::Util::Root
  def self.root?
    Facter::Util::Windows::User.admin?
  end
end
