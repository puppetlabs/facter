# A Facter plugin that loads external facts.
#
# Default Unix Directories:
# /etc/facter/facts.d", "/etc/puppetlabs/facter/facts.d"
#
# Default Windows Direcotires:
# C:\ProgramData\Puppetlabs\facter\facts.d (2008)
# C:\Documents and Settings\All Users\Application Data\Puppetlabs\facter\facts.d (2003)
#
# Can also load from command-line specified directory
#
# Facts can be in the form of JSON, YAML or Text files
# and any executable that returns key=value pairs.

require 'facter'
require 'facter/util/config'
require 'facter/util/composite_loader'
require 'facter/util/parser'
require 'yaml'

class Facter::Util::DirectoryLoader

  class NoSuchDirectoryError < Exception
  end

  # This value makes it highly likely that external facts will take
  # precedence over all other facts
  EXTERNAL_FACT_WEIGHT = 10000

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
  def load(collection)
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
        data.each { |p,v| collection.add(p, :value => v) { has_weight(EXTERNAL_FACT_WEIGHT) } }
      end
    end
  end

private

  def entries
    Dir.entries(directory).find_all { |f| should_parse?(f) }.sort.map { |f| File.join(directory, f) }
  rescue Errno::ENOENT => detail
    []
  end

  def should_parse?(file)
    not file =~ /^\./
  end
end
