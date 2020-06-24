# frozen_string_literal: true

module Facts
  module Aix
    class Processor
      FACT_NAME = 'processor.*'
      TYPE = :legacy

      def call_the_resolver
        arr = []
        processors = Facter::Resolvers::Aix::Processors.resolve(:models)

        processors.count.times do |iterator|
          arr << Facter::ResolvedFact.new("processor#{iterator}", processors[iterator], :legacy)
        end
        arr
      end
    end
  end
end
