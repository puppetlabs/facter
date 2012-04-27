Facter.add("testfact") do
  setcode do
    {
      "test1" => ["test1", "test2"],
      "test2" => "value",
    }
  end
end
