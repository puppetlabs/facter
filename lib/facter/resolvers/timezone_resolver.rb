# frozen_string_literal: true

module Facter
  module Resolvers
    class Timezone < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { determine_timezone }
        end

        def determine_timezone
          @fact_list[:timezone] = Time.now.localtime.strftime('%Z')
        end
      end
    end
  end
end
