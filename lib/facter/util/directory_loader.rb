# A Facter plugin that loads facts from /etc/facter/facts.d.
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
    dir = []
    dir[0] = Facter::Util::DirectoryLoader.new(Facter::Util::Config.external_facts_dirs[0])
    if (Facter::Util::Config.external_facts_dirs.size > 1) 
      dir[1] = Facter::Util::DirectoryLoader.new(Facter::Util::Config.external_facts_dirs[1])
    end 
    Facter::Util::CompositeLoader.new(dir) 
  end 

  # Load facts from files in fact directory using the relevant parser classes to
  # parse them.
  def load
    entries.each do |file|
      parser = Facter::Util::Parser.new(file)
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
