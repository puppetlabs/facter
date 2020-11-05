# frozen_string_literal: true

module Facter
  class CoreFact
    def initialize(searched_fact)
      @searched_fact = searched_fact
    end

    def create
      fact_class = @searched_fact.fact_class

      return unless fact_class

      fact_value = nil
      Facter::Framework::Benchmarking::Timer.measure(@searched_fact.name) do
        fact_value = fact_class.new.call_the_resolver
      end

      fact_value
    end
  end
end
