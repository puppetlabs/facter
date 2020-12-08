# frozen_string_literal: true

module Facter
  class LoadedFact
    attr_reader :name, :klass, :type
    attr_accessor :file, :is_env

    def initialize(name, klass, type = nil, file = nil)
      @name = name
      @klass = klass
      @type = type.nil? ? :core : type
      @file = file
      @is_env = false
    end
  end
end
