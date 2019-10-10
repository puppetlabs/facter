# frozen_string_literal: true

module Facter
  class ExternalFactLoader
    attr_reader :custom_facts, :external_facts, :facts

    def initialize
      LegacyFacter.search("#{ROOT_DIR}/custom_facts")
      LegacyFacter.search_external(["#{ROOT_DIR}/external_facts"])

      custom_facts_to_load = LegacyFacter.collection.custom_facts
      external_facts_to_load = LegacyFacter.collection.external_facts

      @custom_facts = {}
      @external_facts = {}
      @facts = {}

      custom_facts_to_load.each { |k, _v| @custom_facts.merge!(k.to_s => nil) }
      external_facts_to_load.each { |k, _v| @external_facts.merge!(k.to_s => nil) }

      @facts = @custom_facts.merge(@external_facts)
    end
  end
end
