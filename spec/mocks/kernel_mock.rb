# frozen_string_literal: true

LIBS_TO_SKIP = %w[win32ole ffi].freeze
module Kernel
  alias old_require require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end
