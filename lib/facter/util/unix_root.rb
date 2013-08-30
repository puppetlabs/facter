module Facter::Util::Root
  def self.root?
    Process.uid == 0
  end
end
