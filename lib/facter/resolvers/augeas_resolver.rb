# frozen_string_literal: true

module Facter
  module Resolvers
    class Augeas < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

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
          output = Facter::Core::Execution.execute('augparse --version 2>&1', logger: log)
          Regexp.last_match(1) if output =~ /^augparse (\d+\.\d+\.\d+)/
        end

        def read_augeas_from_gem
          require 'augeas'

          return ::Augeas.create { |aug| aug.get('/augeas/version') } if ::Augeas.respond_to?(:create)

          # it is used for legacy augeas <= 0.5.0
          return ::Augeas.open { |aug| aug.get('/augeas/version') } if ::Augeas.respond_to?(:open)
        rescue StandardError => e
          log.debug('ruby-augeas not available')
          log.log_exception(e)
          nil
        end
      end
    end
  end
end
