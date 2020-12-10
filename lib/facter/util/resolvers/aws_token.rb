# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      module AwsToken
        attr_reader :token

        @log = Facter::Log.new(self)

        class << self
          AWS_API_TOKEN_URL = 'http://169.254.169.254/latest/api/token'

          def get(lifetime = 100)
            @expiry ||= Time.now

            return @token if @token && @expiry > Time.now

            @token = nil
            @expiry = Time.now + lifetime

            headers = {
              'X-aws-ec2-metadata-token-ttl-seconds' => lifetime.to_s
            }

            @token = Facter::Util::Resolvers::Http.put_request(AWS_API_TOKEN_URL, headers)
          end

          def reset
            @expiry = nil
            @token = nil
          end
        end
      end
    end
  end
end
