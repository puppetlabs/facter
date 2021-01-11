# frozen_string_literal: true

module Facts
  module Linux
    class SshfpAlgorithm
      FACT_NAME = 'sshfp_.*'
      TYPE = :legacy

      def call_the_resolver
        facts = []
        result = Facter::Resolvers::Ssh.resolve(:ssh)
        result.each do |ssh|
          facts << Facter::ResolvedFact.new("sshfp_#{ssh.name.to_sym}",
                                            "#{ssh.fingerprint.sha1}\n#{ssh.fingerprint.sha256}", :legacy)
        end
        facts
      end
    end
  end
end
