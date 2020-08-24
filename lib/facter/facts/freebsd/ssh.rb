# frozen_string_literal: true

module Facts
  module Freebsd
    class Ssh
      FACT_NAME = 'ssh'
      ALIASES = %w[ssh.*key sshfp_.*].freeze

      def call_the_resolver
        resolved_facts = []
        resolver_data = Facter::Resolvers::SshResolver.resolve(:ssh)

        fact_value = extract_fact(resolver_data)

        resolved_facts.push(Facter::ResolvedFact.new(FACT_NAME, fact_value))

        resolver_data.each do |ssh_data|
          resolved_facts.push(build_key_data(ssh_data))
          resolved_facts.push(build_fp_data(ssh_data))
        end

        resolved_facts
      end

      private

      def extract_fact(resolver_data)
        resolver_data.map { |el| create_ssh_fact(el) }.inject(:merge)
      end

      def create_ssh_fact(ssh)
        return {} unless ssh

        { ssh.name.to_sym => {
          fingerprints: {
            sha1: ssh.fingerprint.sha1,
            sha256: ssh.fingerprint.sha256
          },
          key: ssh.key,
          type: ssh.type
        } }
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
