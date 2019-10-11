
module LegacyFacter::Util::Root
  def self.root?
    LegacyFacter::Util::Windows::User.admin?
  end
end
