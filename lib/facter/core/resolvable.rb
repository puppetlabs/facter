require 'timeout'

# The resolvable mixin defines behavior for evaluating and returning fact
# resolutions.
#
# Classes including this mixin should implement at #name method describing
# the value being resolved and a #resolve_value that actually executes the code
# to resolve the value.
module Facter::Core::Resolvable

  # The timeout, in seconds, for evaluating this resolution.
  # @return [Integer]
  # @api public
  attr_accessor :timeout

  # Return the timeout period for resolving a value.
  # (see #timeout)
  # @return [Numeric]
  # @comment requiring 'timeout' stdlib class causes Object#timeout to be
  #   defined which delegates to Timeout.timeout. This method may potentially
  #   overwrite the #timeout attr_reader on this class, so we define #limit to
  #   avoid conflicts.
  def limit
    @timeout || 0
  end

  ##
  # on_flush accepts a block and executes the block when the resolution's value
  # is flushed.  This makes it possible to model a single, expensive system
  # call inside of a Ruby object and then define multiple dynamic facts which
  # resolve by sending messages to the model instance.  If one of the dynamic
  # facts is flushed then it can, in turn, flush the data stored in the model
  # instance to keep all of the dynamic facts in sync without making multiple,
  # expensive, system calls.
  #
  # Please see the Solaris zones fact for an example of how this feature may be
  # used.
  #
  # @see Facter::Util::Fact#flush
  # @see Facter::Util::Resolution#flush
  #
  # @api public
  def on_flush(&block)
    @on_flush_block = block
  end

  ##
  # flush executes the block, if any, stored by the {on_flush} method
  #
  # @see Facter::Util::Fact#flush
  # @see Facter::Util::Resolution#on_flush
  #
  # @api private
  def flush
    @on_flush_block.call if @on_flush_block
  end

  def value
    result = nil

    with_timing do
      Timeout.timeout(limit) do
        result = resolve_value
      end
    end

    Facter::Util::Normalization.normalize(result)
  rescue Timeout::Error => detail
    Facter.log_exception(detail, "Timed out after #{limit} seconds while resolving #{qualified_name}")
    return nil
  rescue Facter::Util::Normalization::NormalizationError => detail
    Facter.log_exception(detail, "Fact resolution #{qualified_name} resolved to an invalid value: #{detail.message}")
    return nil
  rescue => detail
    Facter.log_exception(detail, "Could not retrieve #{qualified_name}: #{detail.message}")
    return nil
  end

  private

  def with_timing
    starttime = Time.now.to_f

    yield

    finishtime = Time.now.to_f
    ms = (finishtime - starttime) * 1000
    Facter.show_time "#{qualified_name}: #{"%.2f" % ms}ms"
  end

  def qualified_name
    "fact='#{@fact.name.to_s}', resolution='#{@name || '<anonymous>'}'"
  end
end
