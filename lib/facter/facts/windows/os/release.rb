# frozen_string_literal: true

module Facts
  module Windows
    module Os
      class Release
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

          fact_value = Facter::Util::Facts::WindowsReleaseFinder.find_release(input)
          arr << Facter::ResolvedFact.new(FACT_NAME, ({ full: fact_value, major: fact_value } if fact_value))
          ALIASES.each { |aliass| arr << Facter::ResolvedFact.new(aliass, fact_value, :legacy) }
          arr
        end

        def description_resolver(key)
          Facter::Resolvers::WinOsDescription.resolve(key)
        end

        def kernel_resolver(key)
          Facter::Resolvers::Kernel.resolve(key)
        end
      end
    end
  end
end
