# frozen_string_literal: true

module Facter
  class FingerPrint
    attr_accessor :sha1, :sha256
    def initialize(sha1, sha256)
      @sha1 = sha1
      @sha256 = sha256
    end
  end
end
