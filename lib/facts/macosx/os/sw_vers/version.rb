# frozen_string_literal: true

module Facter
  module Macosx
    class OsMacosxVersion
      FACT_NAME = 'os.macosx.version'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @filter_tokens = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver
        fact_value = SwVersResolver.resolve('ProductVersion')
        versions = fact_value.split('.')
        ver = { 'full' => fact_value, 'major' => "#{versions[0]}.#{versions[1]}", 'minor' => versions[-1] }

        if @filter_tokens.any?
          #   filter_by tokens
          value = ver.dig(*@filter_tokens)
          puts value
        end

        [Fact.new(FACT_NAME, ver)]
      end
    end
  end
end
