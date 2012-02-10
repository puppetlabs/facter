Facter.add("testfact") do
  setcode do
    {
      "test1" => ["test1", "test2"]
    }
  end
end
