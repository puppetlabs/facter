# encoding: UTF-8

require 'facter/util/ip/base'

class Facter::Util::IP::GNUkFreeBSD < Facter::Util::IP::Base
  def self.to_s
    'GNU/kFreeBSD'
  end
end
