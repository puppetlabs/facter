# frozen_string_literal: true

module Facts
  module Linux
    class Disks
      FACT_NAME = 'disks'
      ALIASES = %w[blockdevices blockdevice_.*_model blockdevice_.*_size blockdevice_.*_vendor'].freeze

      def call_the_resolver
        facts = []
        disks = Facter::Resolvers::Linux::Disk.resolve(:disks)

        blockdevices = disks.keys.join(',')

        facts.push(Facter::ResolvedFact.new(FACT_NAME, disks))
        facts.push(Facter::ResolvedFact.new('blockdevices', blockdevices, :legacy))
        add_regex_facts(disks, facts)

        facts
      end

      private

      def add_regex_facts(disks, facts)
        disks.each do |disk_name, disk_info|
          facts.push(Facter::ResolvedFact.new("blockdevice_#{disk_name}_model", disk_info[:model], :legacy))
          facts.push(Facter::ResolvedFact.new("blockdevice_#{disk_name}_size", disk_info[:size_bytes], :legacy))
          facts.push(Facter::ResolvedFact.new("blockdevice_#{disk_name}_vendor", disk_info[:vendor], :legacy))
        end
      end
    end
  end
end
