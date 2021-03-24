# frozen_string_literal: true

module Facter
  class ResolvedFact
    extend Forwardable
    def_delegators :@fact_attributes, :user_query, :filter_tokens, :structured
    def_delegators :@fact_attributes, :user_query=, :filter_tokens=, :structured=

    attr_reader :name, :type
    attr_accessor :value, :file, :options

    def initialize(name, value, type = :core, fact_attributes = NullFactAttributes.new)
      @name = name
      @value = Utils.deep_stringify_keys(value)
      @type = type
      @fact_attributes = fact_attributes
    end

    def legacy?
      type == :legacy
    end

    def core?
      type == :core
    end

    def to_s
      @value.to_s
    end
  end
end
