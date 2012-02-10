# This provides a block based mechanism for provider resolution confines.
#
# This allows us to provide more complex logic then the normal confine provides
# so we can support structured facts and things like that.
class Facter::Util::ConfineBlock
  # Store the block of code for later evaluation
  def initialize(block)
    @block = block
  end

  # Evaluate the fact, returning true or false.
  def true?
    @block.call
  end
end
