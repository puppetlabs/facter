# frozen_string_literal: true

module Facter
  module Resolvers
    class PosxIdentity < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || retrieve_identity(fact_name)
          end
        end

        private

        def retrieve_identity(fact_name)
          require 'etc'

          login_info = Etc.getpwuid
          @fact_list[:gid] = login_info.gid
          @fact_list[:group] = Etc.getgrgid(login_info.gid).name
          @fact_list[:privileged] = login_info.uid.zero?
          @fact_list[:uid] = login_info.uid
          @fact_list[:user] = login_info.name
          @fact_list[fact_name]
        end
      end
    end
  end
end
