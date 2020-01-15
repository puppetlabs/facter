# frozen_string_literal: true

module Facter
  module Windows
    class Processor
      FACT_NAME = 'processor.*'

      def call_the_resolver
        arr = []
        processors = Resolvers::Processors.resolve(:models)

        (0...processors.count).each do |iterator|
          arr << ResolvedFact.new("processor#{iterator}", processors[iterator], :legacy)
        end
        arr
      end
    end
  end
end
