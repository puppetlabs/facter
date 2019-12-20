# frozen_string_literal: true

module Facter
  class ResolvedFact
    attr_reader :name, :type
    attr_accessor :user_query, :filter_tokens, :value

    def initialize(name, value = '', type = :core)
      @name = name
      @value = value
      logger = Log.new(self)
      type =~ /core|legacy/ ? @type = type : logger.warn('The specified type is invalid!')
      @type ||= :unknown
    end
  end
end
