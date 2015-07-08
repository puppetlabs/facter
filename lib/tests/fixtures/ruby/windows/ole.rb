Facter.add(:foo) do
  setcode do
    require 'win32ole'
    context = WIN32OLE.new('WbemScripting.SWbemNamedValueSet')
    'bar' unless context.nil?
  end
end