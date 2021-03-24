# frozen_string_literal: true

module Facter
  class CoreFact
    def initialize(searched_fact)
      @searched_fact = searched_fact
    end

    def create
      klass = @searched_fact.klass

      return unless klass

      fact_value = nil
      Facter::Framework::Benchmarking::Timer.measure(@searched_fact.name) do
        fact_value = klass.new.call_the_resolver
      end

      fact_value
    end
  end
end
