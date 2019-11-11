# frozen_string_literal: true

module Facter
  module Sles
    class Ssh
      FACT_NAME = 'ssh'

      def call_the_resolver
        result = Resolvers::SshResolver.resolve(:ssh)
        ssh_facts = {}
        result.each do |ssh|
          ssh_facts.merge!(create_ssh_fact(ssh))
        end
        ResolvedFact.new(FACT_NAME, ssh_facts)
      end

      private

      def create_ssh_fact(ssh)
        { ssh.name.to_sym =>
              { 'fingerprints'.to_sym =>
                    { 'sha1'.to_sym => ssh.fingerprint.sha1,
                      'sha256'.to_sym => ssh.fingerprint.sha256 },
                'key'.to_sym => ssh.key,
                'type'.to_sym => ssh.type } }
      end
    end
  end
end
