# frozen_string_literal: true

require 'base64'
require 'digest/sha1'

module Facter
  module Resolvers
    class SshResolver < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      @file_names = %w[ssh_host_rsa_key.pub ssh_host_dsa_key.pub ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub]
      @file_paths = %w[/etc/ssh /usr/local/etc/ssh /etc /usr/local/etc /etc/opt/ssh]
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_info(fact_name) }
        end

        def retrieve_info(fact_name)
          ssh_list = []
          @file_paths.each do |file_path|
            next unless File.directory?(file_path)

            @file_names.each do |file_name|
              file_content = Util::FileHelper.safe_read(File.join(file_path, file_name), nil)
              next unless file_content

              key_type, key = file_content.split(' ')
              key_name = determine_ssh_key_name(key_type)
              ssh_list << create_ssh(key_name, key_type, key)
            end
          end
          @fact_list[:ssh] = ssh_list
          @fact_list[fact_name]
        end

        def create_ssh(key_name, key_type, key)
          decoded_key = Base64.decode64(key)
          ssh_fa = determine_ssh_fingerprint(key_name)
          sha1 = "SSHFP #{ssh_fa} 1 #{Digest::SHA1.new.update(decoded_key)}"
          sha256 = "SSHFP #{ssh_fa} 2 #{Digest::SHA2.new.update(decoded_key)}"

          fingerprint = FingerPrint.new(sha1, sha256)
          Ssh.new(fingerprint, key_type, key, key_name)
        end

        def determine_ssh_key_name(key)
          case key
          when 'ssh-dss'
            'dsa'
          when 'ecdsa-sha2-nistp256'
            'ecdsa'
          when 'ssh-ed25519'
            'ed25519'
          when 'ssh-rsa'
            'rsa'
          end
        end

        def determine_ssh_fingerprint(key_name)
          case key_name
          when 'rsa'
            1
          when 'dsa'
            2
          when 'ecdsa'
            3
          when 'ed25519'
            4
          end
        end
      end
    end
  end
end
