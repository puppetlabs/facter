# frozen_string_literal: true

module Facts
  module Linux
    class Partitions
      FACT_NAME = 'partitions'

      def call_the_resolver
        Facter::ResolvedFact.new(FACT_NAME, partitions)
      end

      def partitions
        parts = Facter::Resolvers::Partitions.resolve(:partitions)
        mountpoints = Facter::Resolvers::Linux::Mountpoints.resolve(:mountpoints)
        return parts unless mountpoints

        mountpoints.each do |mnt|
          next unless parts[mnt[:device]]

          parts[mnt[:device]].merge!(mount: mnt[:path])
        end
        parts.empty? ? nil : parts
      end
    end
  end
end
