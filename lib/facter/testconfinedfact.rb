Facter.add("testconfinedfact") do
  # A block confine for confining using structured facts
  confine do
    Facter["testfact"].value["test1"].include?("test1")
  end

  setcode do
    ["I worked because my confine was true"]
  end
end
