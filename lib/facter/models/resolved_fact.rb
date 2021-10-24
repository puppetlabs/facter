# frozen_string_literal: true

module Facter
  class ResolvedFact
    attr_reader :name, :type
    attr_accessor :user_query, :value, :file

    def initialize(name, value = '', type = :core, user_query = nil)
      @name = name
      @value = Utils.deep_stringify_keys(value)
      @type = type
      @user_query = user_query
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

    def resolves?(user_query)
      @name == user_query
    end
  end
end
