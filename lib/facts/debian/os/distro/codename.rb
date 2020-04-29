# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Codename
          FACT_NAME = 'os.distro.codename'

          def call_the_resolver
            fact_value = Facter::Resolvers::OsRelease.resolve(:version_codename)
            fact_value ||= retrieve_from_version

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end

          def retrieve_from_version
            version = Facter::Resolvers::OsRelease.resolve(:version)
            return unless version

            codename = /\(.*\)$/.match(version).to_s.gsub(/\(|\)/, '')
            return codename unless codename.empty?

            /[A-Za-z]+\s[A-Za-z]+/.match(version).to_s.split(' ').first.downcase
          end
        end
      end
    end
  end
end
