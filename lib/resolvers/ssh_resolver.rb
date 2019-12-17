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
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || retrieve_info(fact_name)
          end
        end

        private

        def retrieve_info(fact_name)
          ssh_list = []
          @file_paths.each do |file_path|
            next unless File.directory?(file_path)

            @file_names.each do |file_name|
              next unless File.file?(File.join(file_path, file_name))

              key_type, key = File.read(File.join(file_path, file_name)).split(' ')
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
