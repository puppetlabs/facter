# frozen_string_literal: true

module Facter
  module Resolvers
    module Windows
      class Ssh < BaseResolver
        @log = Facter::Log.new(self)

        init_resolver

        FILE_NAMES = %w[ssh_host_rsa_key.pub ssh_host_dsa_key.pub
                        ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub].freeze
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { retrieve_info(fact_name) }
          end

          def retrieve_info(fact_name)
            ssh_dir = determine_ssh_dir
            return unless ssh_dir && File.directory?(ssh_dir)

            ssh_list = []

            FILE_NAMES.each do |file_name|
              output = Facter::Util::FileHelper.safe_read(File.join(ssh_dir, file_name))
              next if output.empty?

              key_type, key = output.split(' ')
              ssh_list << Facter::Util::Resolvers::SshHelper.create_ssh(key_type, key)
            end
            @fact_list[:ssh] = ssh_list.empty? ? nil : ssh_list
            @fact_list[fact_name]
          end

          def determine_ssh_dir
            progdata_dir = ENV['programdata']

            return if !progdata_dir || progdata_dir.empty?

            File.join(progdata_dir, 'ssh')
          end
        end
      end
    end
  end
end
