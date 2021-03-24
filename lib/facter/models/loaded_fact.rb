# frozen_string_literal: true

module Facter
  class LoadedFact
    attr_reader :name, :klass, :type, :structured
    attr_accessor :file, :is_env, :options

    def initialize(name, klass, type = nil, file = nil, structured = false)
      @name = name
      @klass = klass
      @type = type.nil? ? :core : type
      @file = file
      @is_env = false
      @structured = structured
    end
  end
end
