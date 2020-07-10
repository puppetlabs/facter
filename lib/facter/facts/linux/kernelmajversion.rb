# frozen_string_literal: true

module Facts
  module Linux
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        full_version = Facter::Resolvers::Uname.resolve(:kernelrelease)

        Facter::ResolvedFact.new(FACT_NAME, major_version(full_version))
      end

      private

      def major_version(full_version)
        versions_split = full_version.split('.')
        return versions_split[0] if versions_split.length <= 1

        versions_split[0] + '.' + versions_split[1]
      end
    end
  end
end
