# frozen_string_literal: true

module Facter
  class Fact
    attr_accessor :name, :value

    def initialize(name, value = '')
      @name = name
      @value = value
    end
  end
end
