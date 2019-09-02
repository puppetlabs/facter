# frozen_string_literal: true

LIBS_TO_SKIP = ['win32ole'].freeze
module Kernel
  alias old_require require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end
