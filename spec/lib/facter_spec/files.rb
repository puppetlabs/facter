require 'fileutils'
require 'tempfile'

# A support module for testing files.
module FacterSpec::Files
  def self.cleanup
    $global_tempfiles ||= []
    while path = $global_tempfiles.pop do
      begin
        FileUtils.rm_r path, :secure => true
      rescue Errno::ENOENT
        # nothing to do
      end
    end
  end

  def make_absolute(path)
    return path unless Puppet.features.microsoft_windows?
    # REMIND UNC
    return path if path =~ /^[A-Za-z]:/

    pwd = Dir.getwd
    return "#{pwd[0,2]}#{path}" if pwd.length > 2 and pwd =~ /^[A-Za-z]:/
    return "C:#{path}"
  end

  def tmpfile(name = "tmpfile", ext = "tmp")
    # Generate a temporary file, just for the name...
    source = Tempfile.new(name)
    path = source.path + "." + ext
    source.close!

    # Append extension to temporary file
#    if ext != nil
#      path = path + "." + ext
#    end

    # ...record it for cleanup,
    $global_tempfiles ||= []
    $global_tempfiles << File.expand_path(path)

    # ...and bam.
    path
  end

  def tmpdir(name = "tmpdir")
    path = tmpfile(name)
    FileUtils.mkdir_p(path)
    path
  end
end
