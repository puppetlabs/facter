# A Facter plugin that loads facts from /etc/facter/facts.d.
#
# Facts can be in the form of JSON, YAML or Text files
# and any executable that returns key=value pairs.

require 'facter/util/parser'
require 'facter/util/config'

class Facter::Util::DirectoryLoader
  require 'yaml'

  # A list of extensions to ignore in fact directory.
  SKIP_EXTENSIONS = %w{bak orig}

  # Directory for fact loading
  attr_reader :directory

  def initialize(dir = nil)
    @directory = dir || Facter::Util::Config.ext_fact_dir
  end

  def entries
    Dir.entries(directory).find_all{|f| parse?(f) }.sort.map {|f| File.join(directory, f) }
  rescue
    []
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

  def parse?(file)
    return false if file =~ /^\./
      ext = file.split(".")[-1]
    return false if SKIP_EXTENSIONS.include?(ext)
    true
  end
end
