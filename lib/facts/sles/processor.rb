# frozen_string_literal: true

module Facts
  module Sles
    class Processor
      FACT_NAME = 'processor.*'

      def call_the_resolver
        arr = []
        processors = Facter::Resolvers::Linux::Processors.resolve(:models)

        (0...processors.count).each do |iterator|
          arr << Facter::ResolvedFact.new("processor#{iterator}", processors[iterator], :legacy)
        end
        arr
      end
    end
  end
end
