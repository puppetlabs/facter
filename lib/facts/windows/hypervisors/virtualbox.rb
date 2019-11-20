# frozen_string_literal: true

module Facter
  module Windows
    class HypervisorsVirtualbox
      FACT_NAME = 'hypervisors.virtualbox'

      def call_the_resolver
        fact_value = populate_version_and_revision if virtualbox?

        ResolvedFact.new(FACT_NAME, fact_value)
      end

      private

      def virtualbox?
        Resolvers::Virtualization.resolve(:virtual) == 'virtualbox' ||
          Resolvers::DMIComputerSystem.resolve(:name) == 'VirtualBox'
      end

      def populate_version_and_revision
        oem_strings = Resolvers::Virtualization.resolve(:oem_strings)
        return unless oem_strings

        version = revision = ''

        oem_strings.each do |string|
          version = string[8, string.size] if string.start_with?('vboxVer_') && version.empty?
          revision = string[8, string.size] if string.start_with?('vboxRev_') && revision.empty?
        end
        { version: version, revision: revision }
      end
    end
  end
end
