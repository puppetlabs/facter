# frozen_string_literal: true

module Facts
  module Windows
    class Ssh
      FACT_NAME = 'ssh'
      ALIASES = %w[ssh.*key sshfp_.*].freeze

      def call_the_resolver
        resolved_facts = []
        privileged = Facter::Resolvers::Identity.resolve(:privileged)
        ssh_info = Facter::Resolvers::Windows::Ssh.resolve(:ssh) if privileged
        ssh_facts = {}

        ssh_info&.each do |ssh_data|
          ssh_facts.merge!(create_ssh_fact(ssh_data))
          resolved_facts.push(build_key_data(ssh_data))
          resolved_facts.push(build_fp_data(ssh_data))
        end
        resolved_facts.push(Facter::ResolvedFact.new(FACT_NAME, ssh_facts.empty? ? nil : ssh_facts))

        resolved_facts
      end

      private

      def create_ssh_fact(ssh)
        { ssh.name.to_sym =>
              { fingerprints: { sha1: ssh.fingerprint.sha1,
                                sha256: ssh.fingerprint.sha256 },
                key: ssh.key,
                type: ssh.type } }
      end

      def build_key_data(ssh_data)
        fact_name = "ssh#{ssh_data.name}key"
        fact_value = ssh_data.key

        Facter::ResolvedFact.new(fact_name, fact_value, :legacy)
      end

      def build_fp_data(ssh_data)
        fact_name = "sshfp_#{ssh_data.name}"
        fact_value = "#{ssh_data.fingerprint.sha1}\n#{ssh_data.fingerprint.sha256}"

        Facter::ResolvedFact.new(fact_name, fact_value, :legacy)
      end
    end
  end
end
