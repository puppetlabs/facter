# frozen_string_literal: true

module Facter
  module Windows
    class OsRelease
      FACT_NAME = 'os.release'
      ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

      def call_the_resolver
        arr = []
        input = {
          consumerrel: description_resolver(:consumerrel),
          description: description_resolver(:description),
          version: kernel_resolver(:kernelmajorversion),
          kernel_version: kernel_resolver(:kernelversion)
        }

        fact_value = WindowsReleaseFinder.find_release(input)
        arr << ResolvedFact.new(FACT_NAME, ({ full: fact_value, major: fact_value } if fact_value))
        ALIASES.each { |aliass| arr << ResolvedFact.new(aliass, fact_value, :legacy) }
        arr
      end

      def description_resolver(key)
        Resolvers::WinOsDescription.resolve(key)
      end

      def kernel_resolver(key)
        Resolvers::Kernel.resolve(key)
      end
    end
  end
end
