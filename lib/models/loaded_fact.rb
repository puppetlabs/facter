# frozen_string_literal: true

module Facter
  class LoadedFact
    attr_reader :name, :klass, :type

    def initialize(name, klass, type = nil)
      @name = name
      @klass = klass
      @type = type.nil? ? :core : type
    end
  end
end
