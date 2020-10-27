# frozen_string_literal: true

module Facter
  class ResolvedFact
    attr_reader :name, :type
    attr_accessor :user_query, :filter_tokens, :value, :file, :group

    def initialize(name, value = '', type = :core, user_query = nil, filter_tokens = [], group = nil)
      @name = name
      @value = Utils.deep_stringify_keys(value)
      @type = type
      @user_query = user_query
      @filter_tokens = filter_tokens
      @group = group
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
