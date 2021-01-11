# frozen_string_literal: true

module Facter
  module Resolvers
    class Augeas < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_augeas_version(fact_name) }
        end

        def read_augeas_version(fact_name)
          @fact_list[:augeas_version] = read_augeas_from_cli
          @fact_list[:augeas_version] ||= read_augeas_from_gem

          @fact_list[fact_name]
        end

        def read_augeas_from_cli
          command = if File.readable?('/opt/puppetlabs/puppet/bin/augparse')
                      '/opt/puppetlabs/puppet/bin/augparse'
                    else
                      'augparse'
                    end

          output = Facter::Core::Execution.execute("#{command} --version 2>&1", logger: log)
          Regexp.last_match(1) if output =~ /^augparse (\d+\.\d+\.\d+)/
        end

        def read_augeas_from_gem
          require 'augeas'

          if Gem.loaded_specs['augeas']
            ::Augeas.create { |aug| aug.get('/augeas/version') }
          else
            # it is used for legacy augeas <= 0.5.0 (ruby-augeas gem)
            ::Augeas.open { |aug| aug.get('/augeas/version') }
          end
        end
      end
    end
  end
end
