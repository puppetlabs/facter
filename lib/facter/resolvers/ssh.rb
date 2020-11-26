# frozen_string_literal: true

module Facter
  module Resolvers
    class Ssh < BaseResolver
      @log = Facter::Log.new(self)

      init_resolver

      FILE_NAMES = %w[ssh_host_rsa_key.pub ssh_host_dsa_key.pub ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub].freeze
      FILE_PATHS = %w[/etc/ssh /usr/local/etc/ssh /etc /usr/local/etc /etc/opt/ssh].freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_info(fact_name) }
        end

        def retrieve_info(fact_name)
          ssh_list = []
          FILE_PATHS.each do |file_path|
            next unless File.directory?(file_path)

            FILE_NAMES.each do |file_name|
              file_content = Facter::Util::FileHelper.safe_read(File.join(file_path, file_name), nil)
              next unless file_content

              key_type, key = file_content.split(' ')
              ssh = Facter::Util::Resolvers::SshHelper.create_ssh(key_type, key)
              ssh_list << ssh if ssh
            end
          end
          @fact_list[:ssh] = ssh_list
          @fact_list[fact_name]
        end
      end
    end
  end
end
