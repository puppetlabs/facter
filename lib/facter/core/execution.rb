require 'facter/util/config'

module Facter
  module Core
    module Execution

      require 'facter/core/execution/base'
      require 'facter/core/execution/windows'
      require 'facter/core/execution/posix'

      @@impl = if Facter::Util::Config.is_windows?
                 Facter::Core::Execution::Windows.new
               else
                 Facter::Core::Execution::Posix.new
               end

      def self.impl
        @@impl
      end

      module_function

      # Returns the locations to be searched when looking for a binary. This
      # is currently determined by the +PATH+ environment variable plus
      # `/sbin` and `/usr/sbin` when run on unix
      #
      # @return [Array<String>] the paths to be searched for binaries
      # @api private
      def search_paths
        @@impl.search_paths
      end

      # Determines the full path to a binary. If the supplied filename does not
      # already describe an absolute path then different locations (determined
      # by {search_paths}) will be searched for a match.
      #
      # Returns nil if no matching executable can be found otherwise returns
      # the expanded pathname.
      #
      # @param bin [String] the executable to locate
      # @return [String,nil] the full path to the executable or nil if not
      #   found
      #
      # @api public
      def which(bin)
        @@impl.which(bin)
      end

      # Determine in a platform-specific way whether a path is absolute. This
      # defaults to the local platform if none is specified.
      #
      # @param path [String] the path to check
      # @param platform [:posix,:windows,nil] the platform logic to use
      def absolute_path?(path, platform = nil)
        @@impl.absolute_path?(path, platform)
      end

      # Given a command line, this returns the command line with the
      # executable written as an absolute path. If the executable contains
      # spaces, it has be put in double quotes to be properly recognized.
      #
      # @param command [String] the command line
      #
      # @return [String, nil] the command line with the executable's path
      # expanded, or nil if the executable cannot be found.
      def expand_command(command)
        @@impl.expand_command(command)
      end

      # Overrides environment variables within a block of code.  The
      # specified values will be set for the duration of the block, after
      # which the original values (if any) will be restored.
      #
      # @overload with_env(values, { || ... })
      #
      # @param values [Hash<String=>String>] A hash of the environment
      #   variables to override
      #
      # @return [void]
      #
      # @api public
      def with_env(values, &block)
        @@impl.with_env(values, &block)
      end

      # Try to execute a command and return the output.
      #
      # @param code [String] the program to run
      #
      # @return [String] the output of the program, or nil if the command does
      #   not exist or could not be executed.
      #
      # @deprecated Use #{execute} instead
      # @api public
      def exec(command)
        @@impl.execute(command, :on_fail => nil)
      end

      # Execute a command and return the output of that program.
      #
      # @param code [String] the program to run
      # @param options [Hash]
      #
      # @option options [Object] :on_fail How to behave when the command could
      #   not be run. Specifying :raise will raise an error, anything else will
      #   return that object on failure. Default is :raise.
      #
      # @raise [Facter::Core::Execution::ExecutionFailure] If the command does
      #   not exist or could not be executed.
      #
      # @return [String] the output of the program, or the value of :on_fail if
      #   command execution failed and :on_fail was specified.
      #
      # @api public
      # @since 2.0.1
      def execute(command, options = {})
        @@impl.execute(command, options)
      end

      class ExecutionFailure < StandardError; end
    end
  end
end
