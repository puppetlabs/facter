# frozen_string_literal: true

module LegacyFacter
  module Core
    module Execution
      class Base
        def with_env(values)
          old = {}
          values.each do |var, value|
            # save the old value if it exists
            if (old_val = ENV[var])
              old[var] = old_val
            end
            # set the new (temporary) value for the environment variable
            ENV[var] = value
          end
          # execute the caller's block, capture the return value
          rv = yield
        # use an ensure block to make absolutely sure we restore the variables
        ensure
          # restore the old values
          values.each do |var, _value|
            if old.include?(var)
              ENV[var] = old[var]
            else
              # if there was no old value, delete the key from the current environment variables hash
              ENV.delete(var)
            end
          end
          # return the captured return value
          rv
        end

        def execute(command, options = {})
          on_fail = options.fetch(:on_fail, :raise)
          expand = options.fetch(:expand, true)

          # Set LC_ALL and LANG to force i18n to C for the duration of this exec;
          # this ensures that any code that parses the
          # output of the command can expect it to be in a consistent / predictable format / locale
          with_env 'LC_ALL' => 'C', 'LANG' => 'C' do
            expanded_command = if !expand && builtin_command?(command)
                                 command
                               else
                                 expand_command(command)
                               end

            if expanded_command.nil?
              if on_fail == :raise
                raise Facter::Core::Execution::ExecutionFailure.new,
                      "Could not execute '#{command}': command not found"
              end

              return on_fail
            end

            execute_command(expanded_command, on_fail)
          end
        end

        private

        def log_stderr_from_file(msg, command)
          return if !msg || msg.empty?

          file_name = command.split('/').last
          logger = Facter::Log.new(file_name)
          logger.warn(msg.strip)
        end

        def builtin_command?(command)
          output, _status = Open3.capture2("type #{command}")
          output.chomp =~ /builtin/ ? true : false
        end

        def execute_command(command, on_fail)
          begin
            out, stderr, _status_ = Open3.capture3(command.to_s)
            log_stderr_from_file(stderr, command)
          rescue StandardError => e
            return on_fail unless on_fail == :raise

            raise Facter::Core::Execution::ExecutionFailure.new,
                  "Failed while executing '#{command}': #{e.message}"
          end

          out.strip
        end
      end
    end
  end
end
