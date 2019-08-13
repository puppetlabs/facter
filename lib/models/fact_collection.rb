# frozen_string_literal: true

module Facter
  class FactCollection < ::Thor::CoreExt::HashWithIndifferentAccess
    def initialize
      super
    end

    def bury(*args)
      raise ArgumentError, '2 or more arguments required' if args.count < 2

      if args.count == 2
        self[args[0]] = args[1]
      else
        arg = args.shift
        self[arg] = FactCollection.new unless self[arg]
        self[arg].bury(*args) unless args.empty?
      end

      self
    end
  end
end
