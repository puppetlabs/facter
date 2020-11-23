# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      class Ssh
        attr_accessor :fingerprint, :type, :key, :name
        def initialize(fingerprint, type, key, name)
          @fingerprint = fingerprint
          @type = type
          @key = key
          @name = name
        end
      end
    end
  end
end
