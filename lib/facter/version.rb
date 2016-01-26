module Facter
  if not defined? FACTERVERSION then
    FACTERVERSION = '2.4.6'
  end

  # Returns the running version of Facter.
  #
  # @comment The intent is that software external to Facter be able to
  #   determine the Facter version with no side-effects.  The expected
  #   use is:
  #
  #     require 'facter/version'
  #     version = Facter.version
  #
  #   This function has the following ordering precedence.  This precedence list
  #   is designed to facilitate automated packaging tasks by simply writing to
  #   the VERSION file in the same directory as this source file.
  #
  #    1. If a version has been explicitly assigned using the Facter.version=
  #       method, return that version.
  #    2. If there is a VERSION file, read the contents, trim any
  #       trailing whitespace, and return that version string.
  #    3. Return the value of the Facter::FACTERVERSION constant hard-coded into
  #       the source code.
  #
  #   If there is no VERSION file, the method must return the version string of
  #   the nearest parent version that is an officially released version.  That is
  #   to say, if a branch named 3.1.x contains 25 patches on top of the most
  #   recent official release of 3.1.1, then the version method must return the
  #   string "3.1.1" if no "VERSION" file is present.
  #
  #   By design the version identifier is _not_ intended to vary during the life of
  #   a process.  There is no guarantee provided that writing to the VERSION file
  #   while a Puppet process is running will cause the version string to be
  #   updated.  On the contrary, the contents of the VERSION are cached to reduce
  #   filesystem accesses.
  #
  #   The VERSION file is intended to be used by package maintainers who may be
  #   applying patches or otherwise changing the software version in a manner
  #   that warrants a different software version identifier.  The VERSION file is
  #   intended to be managed and owned by the release process and packaging
  #   related tasks, and as such should not reside in version control.  The
  #   FACTERVERSION constant is intended to be version controlled in history.
  #
  #   Ideally, this behavior will allow package maintainers to precisely specify
  #   the version of the software they're packaging as in the following example:
  #
  #       $ git describe > lib/facter/VERSION
  #       $ ruby -r facter -e 'puts Facter.version'
  #       1.6.14-6-g66f2c99
  #
  # @api public
  #
  # @return [String] containing the facter version, e.g. "1.6.14"
  def self.version
    version_file = File.join(File.dirname(__FILE__), 'VERSION')
    return @facter_version if @facter_version
    if version = read_version_file(version_file)
      @facter_version = version
    end
    @facter_version ||= FACTERVERSION
  end

  # Sets the Facter version
  #
  # @return [void]
  #
  # @api private
  def self.version=(version)
    @facter_version = version
  end

  # This reads the content of the "VERSION" file that lives in the
  # same directory as this source code file.
  #
  # @api private
  #
  # @return [String] the version -- for example: "1.6.14-6-gea42046" or nil if the VERSION
  #   file does not exist.
  def self.read_version_file(path)
    if File.exists?(path)
      File.read(path).chomp
    end
  end
  private_class_method :read_version_file
end
