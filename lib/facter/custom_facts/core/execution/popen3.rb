# frozen_string_literal: true

#
# Because Open3 uses Process.detach the env $? is not set so
# this class reimplements Open3.popen3 with Process.wait instead.
# [FACT-2934] When calling Facter::Core::Execution, $? and $CHILD_STATUS
# ruby env variables should be set.
#

module Facter
  module Core
    module Execution
      class Popen3
        @log ||= Log.new(self)

        def self.popen_rune(cmd, opts, child_io, parent_io) # :nodoc:
          pid = spawn(*cmd, opts)
          child_io.each(&:close)
          result = [*parent_io, pid]
          if defined? yield
            begin
              return yield(*result)
            ensure
              parent_io.each(&:close)
              begin
                Process.wait(pid)
              rescue Errno::ENOENT
                # For some reason, the first Process.wait executed in JRuby
                # always fails with ENOENT. However, the command output is
                # filled in so we just need to silently continue.
                # https://github.com/jruby/jruby/issues/5971
                raise unless RUBY_PLATFORM == 'java'

                @log.debug('Caught ENOENT during Process.wait on JRuby, continuing...')
              end
            end
          end
          result
        end

        def self.popen3e(*cmd, &block)
          opts = if cmd.last.is_a? Hash
                   cmd.pop.dup
                 else
                   {}
                 end
          in_r, in_w = IO.pipe
          opts[:in] = in_r
          in_w.sync = true
          out_r, out_w = IO.pipe
          opts[:out] = out_w
          err_r, err_w = IO.pipe
          opts[:err] = err_w
          popen_rune(cmd, opts, [in_r, out_w, err_w], [in_w, out_r, err_r], &block)
        end
      end
    end
  end
end
