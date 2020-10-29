# frozen_string_literal: true

module Facter
  class ResolvedFact
    attr_reader :name, :type
    attr_accessor :user_query, :filter_tokens, :value, :file, :cache_group

    def initialize(name, value = '', type = :core, user_query = nil, filter_tokens = [], cache_group = nil)
      @name = name
      @value = Utils.deep_stringify_keys(value)
      @type = type
      @user_query = user_query
      @filter_tokens = filter_tokens
      @cache_group = cache_group
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
