# frozen_string_literal: true

module LegacyFacter
  module Util
    module Root
      def self.root?
        LegacyFacter::Util::Windows::User.admin?
      end
    end
  end
end
