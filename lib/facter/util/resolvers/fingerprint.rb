# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      FingerPrint = Struct.new(:sha1, :sha256)
    end
  end
end
