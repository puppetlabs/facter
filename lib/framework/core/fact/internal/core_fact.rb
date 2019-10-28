# frozen_string_literal: true

module Facter
  class CoreFact
    def initialize(searched_fact)
      @searched_fact = searched_fact
    end

    def create
      fact_class = @searched_fact.fact_class

      fact_class.new.call_the_resolver
    end
  end
end
