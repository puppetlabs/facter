module Facter
module Util

# {Facter::Util::FileRead} is a utility module intended to provide easily
# mockable methods that delegate to simple file read methods.  The intent is to
# avoid the need to execute the `cat` system command or `File.read` directly in
# Ruby, as mocking these behaviors can have wide-ranging effects.
#
# All Facter facts are encouraged to use this method instead of File.read or
# Facter::Core::Execution.exec('cat ...')
#
# @api public
module FileRead
  # read returns the raw content of a file as a string.  If the file does not
  # exist, or the process does not have permission to read the file then nil is
  # returned.
  #
  # @api public
  #
  # @param path [String] the path to be read
  #
  # @return [String, nil] the raw contents of the file or `nil` if the
  #   file cannot be read because it does not exist or the process does not have
  #   permission to read the file.
  def self.read(path)
    File.read(path)
  rescue Errno::ENOENT, Errno::EACCES => detail
    Facter.debug "Could not read #{path}: #{detail.message}"
    nil
  end

  def self.read_binary(path)
    File.open(path, "rb") { |contents| contents.read }
  end
end
end
end
