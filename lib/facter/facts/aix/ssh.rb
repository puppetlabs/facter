# frozen_string_literal: true

module Facts
  module Aix
    class Ssh
      FACT_NAME = 'ssh'

      def call_the_resolver
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end

      private

      def fact_value
        resolver_data.map { |el| create_ssh_fact(el) }.inject(:merge)
      end

      def resolver_data
        Facter::Resolvers::Ssh.resolve(:ssh)
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
    end
  end
end
