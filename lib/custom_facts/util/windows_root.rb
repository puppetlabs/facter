# frozen_string_literal: true

module LegacyFacter
  module Util
    module Root
    end
    def self.root?
      LegacyFacter::Util::Windows::User.admin?
    end
  end
end
