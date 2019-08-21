# frozen_string_literal: true

module Facter
  module Macosx
    class OsMacosxProduct
      FACT_NAME = 'os.macosx.product'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @args = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact_value = SwVersResolver.resolve('ProductName')
        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
