# frozen_string_literal: true

module Facter
  class OptionStore
    # default options
    @debug = false
    @trace = false
    @verbose = false
    # TODO: constant is not yet available when running puppet facts
    @log_level = :warn
    @show_legacy = true
    @block = true
    @custom_dir = []
    @custom_facts = true
    @external_dir = []
    @external_facts = true
    @ruby = true
    @blocked_facts = []
    @user_query = []

    class << self
      attr_reader :debug, :verbose, :log_level, :show_legacy, :trace,
                  :custom_dir, :external_dir, :external_facts, :ruby,
                  :custom_facts, :blocked_facts

      attr_accessor :config, :user_query, :strict, :json, :haml,
                    :cache, :yaml, :puppet, :ttls, :block, :cli

      def all
        options = {}
        instance_variables.each do |iv|
          variable_name = iv.to_s.delete('@')
          options[variable_name.to_sym] = OptionStore.send(variable_name.to_sym)
        end
        options
      end

      def ruby=(bool)
        if bool == true
          @ruby = true
        else
          @ruby = false
          @custom_facts = false
          @blocked_facts << 'ruby'
        end
      end

      def external_dir=(dirs)
        return unless dirs.any?

        @external_dir = dirs
      end

      def blocked_facts=(*facts)
        @blocked_facts += [*facts]

        @blocked_facts.flatten!
      end

      def custom_dir=(*dirs)
        return unless dirs.any?

        @ruby = true

        @custom_dir = [*dirs]
        @custom_dir.flatten!
      end

      def debug=(bool)
        if bool == true
          self.log_level = :debug
        else
          @debug = false
          self.log_level = Facter::DEFAULT_LOG_LEVEL
        end
      end

      def verbose=(bool)
        if bool == true
          @verbose = true
          self.log_level = :info
        else
          @verbose = false
          self.log_level = Facter::DEFAULT_LOG_LEVEL
        end
      end

      def custom_facts=(bool)
        if bool == true
          @custom_facts = true
          @ruby = true
        else
          @custom_facts = false
        end
      end

      def log_level=(level)
        level = level.to_sym
        case level
        when :trace
          @log_level = :debug
          @trace = true
        when :debug
          @log_level = :debug
          @debug = true
        else
          @log_level = level
        end

        Facter::Log.level = @log_level
        Facter.trace(@trace)
      end

      def show_legacy=(bool)
        if bool == true
          @show_legacy = bool
          @ruby = true
        else
          @show_legacy = false
        end
      end

      def trace=(bool)
        if bool == true
          self.log_level = :trace
        else
          @log_level = Facter::DEFAULT_LOG_LEVEL
          @trace = false
          Facter.trace(false)
        end
      end

      def set(key, value)
        send("#{key}=".to_sym, value)
      end

      def reset
        @debug = false
        @trace = false
        @verbose = false
        # TODO: constant is not yet available when running puppet facts
        @log_level = :warn
        @show_legacy = true
        @block = true
        @custom_dir = []
        @custom_facts = true
        @external_dir = []
        @external_facts = true
        @ruby = true
        @blocked_facts = []
        @user_query = []
        @cli = nil
      end
    end
  end
end
