libdir = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

Facter.add(:named) do
  setcode do
    Facter.value('named_fact')
  end
end

Facter.add(:unnamed) do
  setcode do
    Facter.value('unnamed_fact')
  end
end

