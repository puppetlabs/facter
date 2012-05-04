Facter.add("testfact") do
  setcode do
    {
      "test1" => ["test1", "test2"],
      "test2" => "value",
      "test3" => 3,
      "test4" => 100,
    }
  end
end
