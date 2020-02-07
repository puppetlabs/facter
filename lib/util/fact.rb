# frozen_string_literal: true

# This class represents a fact. Each fact has a name and multiple
# {Facter::Util::Resolution resolutions}.
#
# Create facts using {Facter.add}
#
# @api public
module Facter
  module Util
    class Fact < LegacyFacter::Util::Fact
    end
  end
end
