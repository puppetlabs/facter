# frozen_string_literal: true

module Facts
  module Linux
    module Cloud
      class Provider
        FACT_NAME = 'cloud.provider'

        def call_the_resolver
          provider = case Facter::Util::Facts::Posix::VirtualDetector.platform
                     when 'hyperv'
                       metadata = Facter::Resolvers::Az.resolve(:metadata)
                       'azure' unless metadata.nil? || metadata.empty?
                     when 'kvm', 'xen', 'xenhvm', 'xenu'
                       metadata = Facter::Resolvers::Ec2.resolve(:metadata)
                       if metadata && !metadata.empty?
                         if Process.uid.zero? && File.executable?('/opt/puppetlabs/puppet/bin/virt-what') # virt-what needs to be run as root
                           output = Facter::Core::Execution.execute('/opt/puppetlabs/puppet/bin/virt-what')
                           # rubocop:disable Metrics/BlockNesting
                           output.lines(chomp: true).any?('aws') ? 'aws' : nil
                           # rubocop:enable Metrics/BlockNesting
                         else
                           'aws'
                         end
                       end
                     when 'gce'
                       metadata = Facter::Resolvers::Gce.resolve(:metadata)
                       'gce' unless metadata.nil? || metadata.empty?
                     end

          Facter::ResolvedFact.new(FACT_NAME, provider)
        end
      end
    end
  end
end
