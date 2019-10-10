# frozen_string_literal: true

module Facter
  class FactFactory
    def self.build(searched_fact)
      if searched_fact.name.include?('.*')
        LegacyFact.new(searched_fact)
      else
        CoreFact.new(searched_fact)
      end
    end
  end
end
