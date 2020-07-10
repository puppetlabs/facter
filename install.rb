#! /usr/bin/env ruby
# frozen_string_literal: true

#--
# Copyright 2004 Austin Ziegler <ruby-install@halostatue.ca>
#   Install utility. Based on the original installation script for rdoc by the
#   Pragmatic Programmers.
#
# This program is free software. It may be redistributed and/or modified under
# the terms of the GPL version 2 (or later) or the Ruby licence.
#
# Usage
# -----
# In most cases, if you have a typical project layout, you will need to do
# absolutely nothing to make this work for you. This layout is:
#
#   bin/    # executable files -- "commands"
#   lib/    # the source of the library
#
# The default behaviour:
# 1) Install commands from bin/ into the Ruby bin directory. On Windows, if a
#    if a corresponding batch file (.bat or .cmd) exists in the bin directory,
#    it will be copied over as well. Otherwise, a batch file (always .bat) will
#    be created to run the specified command.
# 2) Install all library files ending in .rb from lib/ into Ruby's
#    site_lib/version directory.
#
#++

require 'rbconfig'
require 'find'
require 'fileutils'
require 'tempfile'
require 'optparse'
require 'ostruct'

class Installer
  include FileUtils
  InstallOptions = OpenStruct.new

  # Returns true if OS is windows (copied from facter/util/config.rb)
  def windows?
    (defined?(RbConfig) ? RbConfig : Config)::CONFIG['host_os'] =~ /mswin|win32|dos|mingw|cygwin/i
  end

  def glob(list)
    g = list.map { |i| Dir.glob(i) }
    g.flatten!
    g.compact!
    g
  end

  def do_configs(configs, target, strip = 'ext/')
    Dir.mkdir(target) unless File.directory? target
    configs.each do |cf|
      ocf = File.join(InstallOptions.config_dir, cf.gsub(/#{strip}/, ''))
      install(cf, ocf, { mode: 0o644, preserve: true, verbose: true })
    end
  end

  def do_bins(bins, target, strip = 's?bin/')
    Dir.mkdir(target) unless File.directory? target
    bins.each do |bf|
      obf = bf.gsub(/#{strip}/, '')
      install_binfile(bf, obf, target)
    end
  end

  def do_libs(libs, strip = 'lib/')
    libs.each do |lf|
      olf = File.join(InstallOptions.site_dir, lf.gsub(/#{strip}/, ''))
      op = File.dirname(olf)
      makedirs(op, { mode: 0o755, verbose: true })
      chmod(0o755, op)
      install(lf, olf, { mode: 0o644, preserve: true, verbose: true })
    end
  end

  def do_man(man, strip = 'man/')
    man.each do |mf|
      omf = File.join(InstallOptions.man_dir, mf.gsub(/#{strip}/, ''))
      om = File.dirname(omf)
      makedirs(om, { mode: 0o755, verbose: true })
      chmod(0o755, om)
      install(mf, omf, { mode: 0o644, preserve: true, verbose: true })

      gzip = `which gzip`
      gzip.chomp!
      `#{gzip} -f #{omf}`
    end
  end

  ##
  # Prepare the file installation.
  #
  def prepare_installation
    InstallOptions.configs = true
    InstallOptions.batch_files = true

    ARGV.options do |opts|
      opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options]"
      opts.separator ''
      opts.on('--[no-]configs', 'Prevents the installation of config files', 'Default off.') do |onconfigs|
        InstallOptions.configs = onconfigs
      end
      opts.on('--destdir[=OPTIONAL]',
              'Installation prefix for all targets',
              'Default essentially /') do |destdir|
        InstallOptions.destdir = destdir
      end
      # opts.on('--configdir[=OPTIONAL]', 'Installation directory for config files', 'Default /etc') do |configdir|
      #   InstallOptions.configdir = configdir
      # end
      opts.on('--bindir[=OPTIONAL]',
              'Installation directory for binaries',
              'overrides RbConfig::CONFIG["bindir"]') do |bindir|
        InstallOptions.bindir = bindir
      end
      opts.on('--ruby[=OPTIONAL]',
              'Ruby interpreter to use with installation',
              'overrides ruby used to call install.rb') do |ruby|
        InstallOptions.ruby = ruby
      end
      opts.on('--sitelibdir[=OPTIONAL]',
              'Installation directory for libraries',
              'overrides RbConfig::CONFIG["sitelibdir"]') do |sitelibdir|
        InstallOptions.sitelibdir = sitelibdir
      end
      # opts.on('--mandir[=OPTIONAL]',
      #         'Installation directory for man pages',
      #          'overrides RbConfig::CONFIG["mandir"]') do |mandir|
      #   InstallOptions.mandir = mandir
      # end
      opts.on('--full', 'Performs a full installation. All', 'optional installation steps are run.') do |_full|
        InstallOptions.configs = true
      end
      opts.on('--no-batch-files', 'Prevents installation of batch files for windows', 'Default off') do |_batch_files|
        InstallOptions.batch_files = false
      end
      opts.separator('')
      opts.on_tail('--help', 'Shows this help text.') do
        warn opts
        exit
      end

      opts.parse!
    end

    version = [RbConfig::CONFIG['MAJOR'], RbConfig::CONFIG['MINOR']].join('.')
    libdir = File.join(RbConfig::CONFIG['libdir'], 'ruby', version)

    # Mac OS X 10.5 and higher declare bindir
    # /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin
    # which is not generally where people expect executables to be installed
    # These settings are appropriate defaults for all OS X versions.
    RbConfig::CONFIG['bindir'] = '/usr/bin' if RUBY_PLATFORM =~ /^universal-darwin[\d\.]+$/

    # if InstallOptions.configdir
    #   configdir = InstallOptions.configdir
    # elsif windows?
    #   path = File.join(File.dirname(__FILE__), "lib", "custom_facts", "util", "config.rb")
    #   require_relative(path)

    #   configdir = File.join(LegacyFacter::Util::Config.windows_data_dir, "PuppetLabs", "facter", "etc")
    # else
    #   configdir = File.join('/', 'etc', 'puppetlabs', 'facter')
    # end

    bindir = InstallOptions.bindir || RbConfig::CONFIG['bindir']

    if InstallOptions.sitelibdir
      sitelibdir = InstallOptions.sitelibdir
    else
      sitelibdir = RbConfig::CONFIG['sitelibdir']
      if sitelibdir.nil?
        sitelibdir = $LOAD_PATH.find { |x| x =~ /site_ruby/ }
        if sitelibdir.nil?
          sitelibdir = File.join(libdir, 'site_ruby')
        elsif sitelibdir !~ Regexp.quote(version)
          sitelibdir = File.join(sitelibdir, version)
        end
      end
    end

    # if InstallOptions.mandir
    #   mandir = InstallOptions.mandir
    # else
    #   mandir = RbConfig::CONFIG['mandir']
    # end

    # This is the new way forward
    destdir = InstallOptions.destdir || ''

    # configdir = join(destdir, configdir)
    bindir = join(destdir, bindir)
    # mandir = join(destdir, mandir)
    sitelibdir = join(destdir, sitelibdir)

    # makedirs(configdir) if InstallOptions.configs
    makedirs(bindir)
    # makedirs(mandir)
    makedirs(sitelibdir)

    InstallOptions.site_dir = sitelibdir
    # InstallOptions.config_dir = configdir
    InstallOptions.bin_dir  = bindir
    InstallOptions.lib_dir  = libdir
    # InstallOptions.man_dir  = mandir
  end

  ##
  # Join two paths. On Windows, dir must be converted to a relative path,
  # by stripping the drive letter, but only if the basedir is not empty.
  #
  def join(basedir, dir)
    return "#{basedir}#{dir[2..-1]}" if windows? && !basedir.empty? && (dir.length > 2)

    "#{basedir}#{dir}"
  end

  ##
  # Install file(s) from ./bin to RbConfig::CONFIG['bindir']. Patch it on the way
  # to insert a #! line; on a Unix install, the command is named as expected
  # (e.g., bin/rdoc becomes rdoc); the shebang line handles running it. Under
  # windows, we add an '.rb' extension and let file associations do their stuff.
  def install_binfile(from, op_file, target)
    tmp_file = Tempfile.new('facter-binfile')

    ruby = if !InstallOptions.ruby.nil?
             InstallOptions.ruby
           else
             File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
           end

    File.open(from) do |ip|
      File.open(tmp_file.path, 'w') do |op|
        op.puts "#!#{ruby}"
        contents = ip.readlines
        contents.shift if contents[0] =~ /^#!/
        op.write contents.join
      end
    end

    if windows? && InstallOptions.batch_files
      installed_wrapper = false

      if File.exist?("#{from}.bat")
        install("#{from}.bat", File.join(target, "#{op_file}.bat"), mode: 0o755, preserve: true, verbose: true)
        installed_wrapper = true
      end

      if File.exist?("#{from}.cmd")
        install("#{from}.cmd", File.join(target, "#{op_file}.cmd"), mode: 0o755, preserve: true, verbose: true)
        installed_wrapper = true
      end

      unless installed_wrapper
        tmp_file2 = Tempfile.new('facter-wrapper')
        cwv = <<-SCRIPT
          @echo off
          SETLOCAL
          if exist "%~dp0environment.bat" (
            call "%~dp0environment.bat" %0 %*
          ) else (
            SET "PATH=%~dp0;%PATH%"
          )
          ruby.exe -S -- facter %*
        SCRIPT
        File.open(tmp_file2.path, 'w') { |cw| cw.puts cwv }
        install(tmp_file2.path, File.join(target, "#{op_file}.bat"), mode: 0o755, preserve: true, verbose: true)

        tmp_file2.unlink
      end
    end
    install(tmp_file.path, File.join(target, op_file), mode: 0o755, preserve: true, verbose: true)
    tmp_file.unlink
  end

  # Change directory into the facter root so we don't get the wrong files for install.
  def run
    cd File.dirname(__FILE__) do
      # Set these values to what you want installed.
      bins  = glob(%w[bin/facter])
      libs  = glob(%w[lib/**/*.rb lib/facter/os_hierarchy.json lib/facter/fact_groups.conf])

      prepare_installation

      do_bins(bins, InstallOptions.bin_dir)
      do_libs(libs)
    end
  end
end

Installer.new.run
