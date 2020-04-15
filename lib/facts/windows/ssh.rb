# frozen_string_literal: true

module Facts
  module Windows
    class Ssh
      FACT_NAME = 'ssh'

      def call_the_resolver
        privileged = Facter::Resolvers::Identity.resolve(:privileged)
        ssh_info = Facter::Resolvers::Windows::Ssh.resolve(:ssh) if privileged
        ssh_facts = {}
        ssh_info&.each { |ssh| ssh_facts.merge!(create_ssh_fact(ssh)) }
        Facter::ResolvedFact.new(FACT_NAME, ssh_facts.empty? ? nil : ssh_facts)
      end

      private

      def create_ssh_fact(ssh)
        { ssh.name.to_sym =>
              { fingerprints: { sha1: ssh.fingerprint.sha1,
                                sha256: ssh.fingerprint.sha256 },
                key: ssh.key,
                type: ssh.type } }
      end
    end
  end
end
