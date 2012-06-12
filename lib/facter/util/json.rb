module Facter 

  # Idealy this should be an autoloaded feature test like in Puppet, 
  # but that's more overhead that is needed right now.
  def self.json?
    begin
      require 'json' 
      true 
    rescue LoadError
      false
    end
  end
end

