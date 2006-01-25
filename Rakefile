# Rakefile for facter

begin
    require 'rubygems'
    require 'rake/gempackagetask'
rescue Exception
    nil
end

require 'rake/clean'
require 'rake/testtask'

require 'rake/rdoctask'
#CLEAN.include('**/*.o')
CLOBBER.include('doc/*')

def announce(msg='')
  STDERR.puts msg
end

# Determine the current version

if `ruby -Ilib ./bin/facter --version` =~ /\S+$/
  CURRENT_VERSION = $&
else
  CURRENT_VERSION = "0.0.0"
end

if ENV['REL']
  PKG_VERSION = ENV['REL']
else
  PKG_VERSION = CURRENT_VERSION
end

DOWNDIR = "/export/docroots/reductivelabs.com/htdocs/downloads"

# The default task is run if rake is given no explicit arguments.

desc "Default Task"
task :default => :unittests

# Test Tasks ---------------------------------------------------------

#task :u => :unittests
#task :a => :alltests

#task :alltests => :unittests

#Rake::TestTask.new(:unittests) do |t|
#    t.test_files = FileList['tests/*.rb']
#    t.warning = true
#    t.verbose = false
#end

# SVN Tasks ----------------------------------------------------------
# ... none.

# Install rake using the standard install.rb script.

desc "Install the application"
task :install do
    ruby "install.rb"
end

# Create a task to build the RDOC documentation tree.

rd = Rake::RDocTask.new(:html) { |rdoc|
    rdoc.rdoc_dir = 'html'
    rdoc.template = 'html'
    rdoc.title    = "Facter"
    rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README'
    rdoc.rdoc_files.include('README', 'LICENSE', 'TODO', 'CHANGELOG')
    rdoc.rdoc_files.include('lib/**/*.rb')
    CLEAN.include("html")
}

# ====================================================================
# Create a task that will package the Rake software into distributable
# tar, zip and gem files.

PKG_FILES = FileList[
    'install.rb',
    '[A-Z]*',
    'bin/**/*', 
    'lib/**/*.rb', 
    'test/**/*.rb',
    'doc/**/*',
    'etc/*'
]
PKG_FILES.delete_if {|item| item.include?(".svn")}

if ! defined?(Gem)
    puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    
    #### Basic information.

    s.name = 'facter'
    s.version = PKG_VERSION
    s.summary = "Facter collects Operating system facts."
    s.description = <<-EOF
      Facter is a module for collecting simple facts about a host 
      Operating system.
    EOF

    #### Dependencies and requirements.

    #s.add_dependency('log4r', '> 1.0.4')
    #s.requirements << ""

    s.files = PKG_FILES.to_a

    #### Load-time details: library and application (you will need one or both).

    s.require_path = 'lib'                         # Use these for libraries.

    s.bindir = "bin"                               # Use these for applications.
    s.executables = ["facter"]
    s.default_executable = "facter"

    #### Documentation and testing.

    s.has_rdoc = true
    s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
    s.rdoc_options <<
      '--title' <<  'Facter' <<
      '--main' << 'README' <<
      '--line-numbers'

    #### Author and project details.

    s.author = "Luke Kanies"
    s.email = "dev@reductivelabs.com"
    s.homepage = "http://reductivelabs.com/projects/facter"
    #s.rubyforge_project = "facter"
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    #pkg.need_zip = true
    pkg.need_tar = true
  end

  CLEAN.include("pkg")
end

# Misc tasks =========================================================

#ARCHIVEDIR = '/...'

#task :archive => [:package] do
#  cp FileList["pkg/*.tgz", "pkg/*.zip", "pkg/*.gem"], ARCHIVEDIR
#end

# Define an optional publish target in an external file.  If the
# publish.rf file is not found, the publish targets won't be defined.

#load "publish.rf" if File.exist? "publish.rf"

# Support Tasks ------------------------------------------------------

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
	count += 1
	if line =~ pattern
	  puts "#{fn}:#{count}:#{line}"
	end
      end
    end
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep "/#.*(FIXME|TODO|TBD)/"
end

#desc "Look for Debugging print lines"
#task :dbg do
#  egrep /\bDBG|\bbreakpoint\b/
#end

#desc "List all ruby files"
#task :rubyfiles do 
#  puts Dir['**/*.rb'].reject { |fn| fn =~ /^pkg/ }
#  puts Dir['bin/*'].reject { |fn| fn =~ /CVS|(~$)|(\.rb$)/ }
#end

# --------------------------------------------------------------------
# Creating a release

desc "Make a new release"
task :release => [
  :prerelease,
  :clobber,
  :update_version,
  :tag,
  :package,
  :copy] do
  #:alltests,
  
  announce 
  announce "**************************************************************"
  announce "* Release #{PKG_VERSION} Complete."
  announce "* Packages ready to upload."
  announce "**************************************************************"
  announce 
end

# Validate that everything is ready to go for a release.
task :prerelease do
  announce 
  announce "**************************************************************"
  announce "* Making RubyGem Release #{PKG_VERSION}"
  announce "* (current version #{CURRENT_VERSION})"
  announce "**************************************************************"
  announce  

  # Is a release number supplied?
  unless ENV['REL']
    fail "Usage: rake release REL=x.y.z [REUSE=tag_suffix]"
  end

  # Is the release different than the current release.
  # (or is REUSE set?)
  if PKG_VERSION == CURRENT_VERSION && ! ENV['REUSE']
    fail "Current version is #{PKG_VERSION}, must specify REUSE=tag_suffix to reuse version"
  end

  # Are all source files checked in?
  if ENV['RELTEST']
    announce "Release Task Testing, skipping checked-in file test"
  else
    announce "Checking for unchecked-in files..."
    data = `svn -q update`
    unless data =~ /^$/
      fail "SVN update is not clean ... do you have unchecked-in files?"
    end
    announce "No outstanding checkins found ... OK"
  end
end

task :update_version => [:prerelease] do
  if PKG_VERSION == CURRENT_VERSION
    announce "No version change ... skipping version update"
  else
    announce "Updating Facter version to #{PKG_VERSION}"
    open("lib/facter.rb") do |rakein|
      open("lib/facter.rb.new", "w") do |rakeout|
	rakein.each do |line|
	  if line =~ /^\s*FACTERVERSION\s*=\s*/
	    rakeout.puts "FACTERVERSION = '#{PKG_VERSION}'"
	  else
	    rakeout.puts line
	  end
	end
      end
    end
    mv "lib/facter.rb.new", "lib/facter.rb"
    if ENV['RELTEST']
      announce "Release Task Testing, skipping commiting of new version"
    else
      sh %{svn commit -m "Updated to version #{PKG_VERSION}" lib/facter.rb}
    end
  end
end

desc "Tag all the SVN files with the latest release number (REL=x.y.z)"
task :tag => [:prerelease] do
  reltag = "REL_#{PKG_VERSION.gsub(/\./, '_')}"
  reltag << ENV['REUSE'].gsub(/\./, '_') if ENV['REUSE']
  announce "Tagging SVN copy with [#{reltag}]"
  if ENV['RELTEST']
    announce "Release Task Testing, skipping SVN tagging"
  else
    sh %{svn copy ../trunk/ ../tags/#{reltag}}
    sh %{cd ../tags; svn ci -m 'Adding Release tag #{reltag}'}
  end
end

desc "Copy the newly created package into the downloads directory"
task :copy => [:package, :html] do
    sh %{cp pkg/facter-#{PKG_VERSION}.gem #{DOWNDIR}/gems}
    sh %{generate_yaml_index.rb -d #{DOWNDIR}}
    sh %{cp pkg/facter-#{PKG_VERSION}.tgz #{DOWNDIR}/facter}
    sh %{ln -sf facter-#{PKG_VERSION}.tgz #{DOWNDIR}/facter/facter-latest.tgz}
    sh %{cp -r html #{DOWNDIR}/facter/apidocs}
end

desc "Create an RPM"
task :rpm do
    tarball = File.join(Dir.getwd, "pkg", "facter-#{PKG_VERSION}.tgz")

    sourcedir = `rpm --define 'name facter' --define 'version #{PKG_VERSION}' --eval '%_sourcedir'`.chomp

    basedir = File.dirname(sourcedir)
    FileUtils.mkdir_p(basedir)

    if ! FileTest::exist?(sourcedir)
        FileUtils.mkdir_p(sourcedir)
    end

    target = "#{sourcedir}/facter-#{PKG_VERSION}.tgz"

    sh %{cp -r #{tarball} #{sourcedir}}
    sh %{cp conf/redhat/facter.spec %s/facter.spec} % basedir

    FileUtils::cd(basedir)

    system("rpmbuild -ba facter.spec")
end

# $Id$
