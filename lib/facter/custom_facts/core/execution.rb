# frozen_string_literal: true

module Facter
  module Core
    module Execution
      @@impl = if LegacyFacter::Util::Config.windows?
                 Facter::Core::Execution::Windows.new
               else
                 Facter::Core::Execution::Posix.new
               end

      def self.impl
        @@impl
      end

      module_function

      # Returns the locations to be searched when looking for a binary. This
      #   is currently determined by the +PATH+ environment variable plus
      #   `/sbin` and `/usr/sbin` when run on unix
      #
      # @return [Array<String>] The paths to be searched for binaries
      #
      # @api private
      def search_paths
        @@impl.search_paths
      end

      # Determines the full path to a binary. If the supplied filename does not
      #   already describe an absolute path then different locations (determined
      #   by {search_paths}) will be searched for a match.
      # @param bin [String] The executable to locate
      #
      # @return [String/nil] The full path to the executable or nil if not
      #   found
      #
      # @api public
      def which(bin)
        @@impl.which(bin)
      end

      # Determine in a platform-specific way whether a path is absolute. This
      #   defaults to the local platform if none is specified.
      # @param path [String] The path to check

      # @param platform [:posix/:windows/nil] The platform logic to use
      #
      # @api private
      def absolute_path?(path, platform = nil)
        case platform
        when :posix
          Facter::Core::Execution::Posix.new.absolute_path?(path)
        when :windows
          Facter::Core::Execution::Windows.new.absolute_path?(path)
        else
          @@impl.absolute_path?(path)
        end
      end

      # Given a command line, this returns the command line with the
      #   executable written as an absolute path. If the executable contains
      #   spaces, it has to be put in double quotes to be properly recognized.
      # @param command [String] the command line
      #
      # @return [String/nil] The command line with the executable's path
      #   expanded, or nil if the executable cannot be found.
      #
      # @api private
      def expand_command(command)
        @@impl.expand_command(command)
      end

      # Overrides environment variables within a block of code.  The
      #   specified values will be set for the duration of the block, after
      #   which the original values (if any) will be restored.
      # @param values [Hash<String=>String>] A hash of the environment
      #   variables to override
      #
      # @return [String] The block's return string
      #
      # @api private
      def with_env(values, &block)
        @@impl.with_env(values, &block)
      end

      # Try to execute a command and return the output.
      # @param command [String] Command to run
      #
      # @return [String/nil] Output of the program, or nil if the command does
      #   not exist or could not be executed.
      #
      # @deprecated Use #{execute} instead
      # @api public
      def exec(command)
        @@impl.execute(command, on_fail: nil)
      end

      # Execute a command and return the output of that program.
      # @param command [String] Command to run
      #
      # @param options [Hash] Hash with options for the command
      #
      # Options accepted values :on_fail How to behave when the command could
      #   not be run. Specifying :raise will raise an error, anything else will
      #   return that object on failure. Default is :raise.
      #   :logger Optional logger used to log the command's stderr.
      #   :time_limit Optional time out for the specified command. If no time_limit is passed,
      #   a default of 300 seconds is used.
      #
      # @raise [Facter::Core::Execution::ExecutionFailure] If the command does
      #   not exist or could not be executed and :on_fail is set to :raise
      #
      # @return [String] the output of the program, or the value of :on_fail (if it's different than :raise) if
      #   command execution failed and :on_fail was specified.
      #
      # @api public
      def execute(command, options = {})
        @@impl.execute(command, options)
      end

      # Execute a command and return the stdout and stderr of that program.
      # @param command [String] Command to run
      #
      # @param on_fail[Object] How to behave when the command could
      #   not be run. Specifying :raise will raise an error, anything else will
      #   return that object on failure. Default is :raise.
      # @param logger Optional logger used to log the command's stderr.
      # @param time_limit Optional time out for the specified command. If no time_limit is passed,
      #   a default of 300 seconds is used.
      #
      # @raise [Facter::Core::Execution::ExecutionFailure] If the command does
      #   not exist or could not be executed and :on_fail is set to :raise
      #
      # @return [String, String] the stdout and stderr of the program, or the value of
      #   :on_fail if command execution failed and :on_fail was specified.
      #
      # @api private
      def execute_command(command, on_fail = nil, logger = nil, time_limit = nil)
        @@impl.execute_command(command, on_fail, logger, time_limit)
      end

      class ExecutionFailure < StandardError; end
    end
  end
end
