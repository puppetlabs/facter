# frozen_string_literal: true

module Facter
  module Macosx
    class OsMacosxVersion
      FACT_NAME = 'os.macosx.version'

      def call_the_resolver
        fact_value = Resolvers::SwVers.resolve('ProductVersion')
        versions = fact_value.split('.')
        ver = { 'full' => fact_value, 'major' => "#{versions[0]}.#{versions[1]}", 'minor' => versions[-1] }

        ResolvedFact.new(FACT_NAME, ver)
      end
    end
  end
end
