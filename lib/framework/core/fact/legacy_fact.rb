# frozen_string_literal: true

module Facter
  class LegacyFact
    def initialize(searched_fact)
      @searched_fact = searched_fact
    end

    def create
      fact_class = @searched_fact.fact_class
      filter_criteria = extract_filter_criteria(@searched_fact)

      fact_class.new.call_the_resolver(filter_criteria)
    end

    Trimmer = Struct.new(:start, :end)
    def extract_filter_criteria(searched_fact)
      name_tokens = searched_fact.name.split('.*')
      trimmer = Trimmer.new(name_tokens[0].length, -(name_tokens[1] || '').length - 1)

      searched_fact.user_query[trimmer.start..trimmer.end]
    end
  end
end
