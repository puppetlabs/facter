# frozen_string_literal: true

module Facter
  module Linux
    class OsName
      FACT_NAME = 'os.name'
      @aliases = []

      def initialize(*args)
        @args = args
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact = OsResolver.resolve(:name)
        { FACT_NAME => fact }
      end
    end
  end
end
