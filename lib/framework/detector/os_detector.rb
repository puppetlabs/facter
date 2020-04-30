# frozen_string_literal: true

require 'rbconfig'

class OsDetector
  include Singleton

  attr_reader :identifier, :version, :hierarchy

  def initialize(*_args)
    @log = Facter::Log.new(self)
    @os_hierarchy = Facter::OsHierarchy.new
    @identifier = detect
  end

  private

  def detect
    host_os = RbConfig::CONFIG['host_os']
    identifier = case host_os
                 when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                   :windows
                 when /darwin|mac os/
                   :macosx
                 when /linux/
                   detect_distro
                 when /bsd/
                   :bsd
                 when /solaris/
                   :solaris
                 when /aix/
                   :aix
                 else
                   raise "unknown os: #{host_os.inspect}"
                 end

    @hierarchy = detect_hierarchy(identifier)
    @identifier = identifier
  end

  def detect_hierarchy(identifier)
    hierarchy = @os_hierarchy.construct_hierarchy(identifier)
    if hierarchy.empty?
      @log.debug("Could not detect hierarchy using os identifier: #{identifier} , trying with family")
      hierarchy = @os_hierarchy.construct_hierarchy(detect_family)
    end

    if hierarchy.empty?
      @log.debug("Could not detect hierarchy using family #{detect_family}, falling back to Linux")
      hierarchy = @os_hierarchy.construct_hierarchy(:linux)
    end

    hierarchy
  end

  def detect_family
    Facter::Resolvers::OsRelease.resolve(:id_like)
  end

  def detect_distro
    [Facter::Resolvers::OsRelease,
     Facter::Resolvers::RedHatRelease,
     Facter::Resolvers::SuseRelease].each do |resolver|
      @identifier = resolver.resolve(:identifier)
      @version = resolver.resolve(:version)
      break if @identifier
    end

    @identifier&.downcase&.to_sym
  end
end
