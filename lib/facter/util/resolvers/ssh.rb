# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      Ssh = Struct.new(:fingerprint, :type, :key, :name)
    end
  end
end
