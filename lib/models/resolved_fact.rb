# frozen_string_literal: true

module Facter
  class ResolvedFact
    attr_reader :name, :type
    attr_accessor :user_query, :filter_tokens, :value

    def initialize(name, value = '', type = :core)
      unless type =~ /core|legacy|custom/
        raise ArgumentError, 'The type provided for fact is not legacy, core or custom!'
      end

      @name = name
      @value = Utils.deep_stringify_keys(value)
      @type = type
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
