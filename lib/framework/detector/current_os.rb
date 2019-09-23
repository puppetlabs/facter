# frozen_string_literal: true

require 'rbconfig'
require 'singleton'

class CurrentOs
  include Singleton

  attr_reader :identifier, :version

  def initialize(*_args)
    @identifier = detect
  end

  def detect
    host_os = RbConfig::CONFIG['host_os']
    @identifier = case host_os
                  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                    :windows
                  when /darwin|mac os/
                    :macosx
                  when /linux/
                    detect_distro
                  when /solaris|bsd/
                    :solaris # TODO: break up login.
                  when /aix/
                    :aix
                  else
                    raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
                  end
  end

  def detect_distro
    [Facter::Resolvers::OsReleaseResolver,
     Facter::Resolvers::RedHatReleaseResolver,
     Facter::Resolvers::SuseRelease].each do |resolver|
      @identifier = resolver.resolve(:identifier)
      @version = resolver.resolve(:version)
      break if @identifier
    end
    @identifier
  end
end
