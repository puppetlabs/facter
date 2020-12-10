# frozen_string_literal: true

require 'base64'
require 'digest/sha1'

module Facter
  module Util
    module Resolvers
      class SshHelper
        class << self
          SSH_NAME = { 'ssh-dss' => 'dsa', 'ecdsa-sha2-nistp256' => 'ecdsa',
                       'ssh-ed25519' => 'ed25519', 'ssh-rsa' => 'rsa' }.freeze
          SSH_FINGERPRINT = { 'rsa' => 1, 'dsa' => 2, 'ecdsa' => 3, 'ed25519' => 4 }.freeze

          def create_ssh(key_type, key)
            key_name = SSH_NAME[key_type]
            return unless key_name

            decoded_key = Base64.decode64(key)
            ssh_fp = SSH_FINGERPRINT[key_name]
            sha1 = "SSHFP #{ssh_fp} 1 #{Digest::SHA1.new.update(decoded_key)}"
            sha256 = "SSHFP #{ssh_fp} 2 #{Digest::SHA2.new.update(decoded_key)}"

            fingerprint = Facter::Util::Resolvers::FingerPrint.new(sha1, sha256)
            Facter::Util::Resolvers::Ssh.new(fingerprint, key_type, key, key_name)
          end
        end
      end
    end
  end
end
