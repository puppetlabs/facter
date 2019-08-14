# frozen_string_literal: true

module Facter
  module Macosx
    class NetworkIP
      FACT_NAME = 'networking.ip'
      @aliases = []

      # def self.fact_name
      #   @@fact_name
      # end

      def initialize(*args)
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        { 'ip' => 'l92.l68.O.l' }
      end
    end
  end
end
