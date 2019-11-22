# frozen_string_literal: true

module Facter
  module Fedora
    class DiskSdaModel
      FACT_NAME = 'disk.sda.model'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sda_model)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
