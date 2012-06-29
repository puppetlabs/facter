# A Facter plugin that loads external facts. 
# 
# Default Unix Directories:
# /etc/facter/facts.d, /etc/puppetlbas/facter/facts.d
# 
# Default Windows Direcotires: 
# C:\ProgramData\Puppetlabs\facter\facts.d (2008)
# C:\Documents and Settings\All Users\Application Data\Puppetlabs\facter\facts.d (2003) 
#
# Can also load from command-line specified directory
#
# Facts can be in the form of JSON, YAML or Text files
# and any executable that returns key=value pairs.

require 'facter/util/parser'
require 'facter/util/config'
require 'facter/util/composite_loader'

class Facter::Util::DirectoryLoader
  require 'yaml'
  
  class NoSuchDirectoryError < Exception 
  end 

  # A list of extensions to ignore in fact directory.
  SKIP_EXTENSIONS = %w{bak orig}

  # Directory for fact loading
  attr_reader :directory

  def initialize(dir)
    @directory = dir
  end
  
  def self.loader_for(dir)
    if File.directory?(dir) 
      Facter::Util::DirectoryLoader.new(dir)
    else
      raise NoSuchDirectoryError 
    end 
  end 
  
  def self.default_loader
    loaders = Facter::Util::Config.external_facts_dirs.collect do |dir|
      Facter::Util::DirectoryLoader.new(dir)
    end
    Facter::Util::CompositeLoader.new(loaders) 
  end 

  # Load facts from files in fact directory using the relevant parser classes to
  # parse them.
  def load
    entries.each do |file|
      parser = Facter::Util::Parser.parser_for(file)
      if parser == nil
        next
      end

      data = parser.results
      if data == false
        Facter.warn "Could not interpret fact file #{file}"
      elsif data == {} or data == nil
        Facter.warn "Fact file #{file} was parsed but returned an empty data set"
      else
        data.each { |p,v| Facter.add(p, :value => v) }
      end
    end
  end

private

  def entries
    Dir.entries(directory).find_all { |f| should_parse?(f) }.sort.map { |f| File.join(directory, f) }
  rescue
    []
  end

  def should_parse?(file)
    return false if file =~ /^\./
    ext = file.split(".")[-1]
    return false if SKIP_EXTENSIONS.include?(ext)
    true
  end
end
