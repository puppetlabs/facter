# frozen_string_literal: true

module Facts
  module Macosx
    module Os
      class Release
        FACT_NAME = 'os.release'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:kernelrelease)
          release_strings = fact_value.split('.')
          Facter::ResolvedFact.new(FACT_NAME,
                                   full: fact_value,
                                   major: release_strings[0],
                                   minor: release_strings[1])
        end
      end
    end
  end
end
