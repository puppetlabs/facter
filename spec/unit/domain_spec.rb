require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Domain name facts" do

  describe "on linux" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    it "should use the hostname binary" do
      Facter::Util::Resolution.expects(:exec).with("hostname").returns "test.example.com"
      Facter.fact(:domain).value.should == "example.com"
    end

    it "should fall back to the dnsdomainname binary" do
      Facter::Util::Resolution.stubs(:exec).with("hostname")
      Facter::Util::Resolution.expects(:exec).with("dnsdomainname").returns("example.com")
      Facter.fact(:domain).value.should == "example.com"
    end


    it "should fall back to /etc/resolv.conf" do
      Facter::Util::Resolution.stubs(:exec).with("hostname").at_least_once
      Facter::Util::Resolution.stubs(:exec).with("dnsdomainname").at_least_once
      File.expects(:open).with('/etc/resolv.conf').at_least_once
      Facter.fact(:domain).value
    end

    it "should attempt to resolve facts in a specific order" do
      seq = sequence('domain')
      Facter::Util::Resolution.stubs(:exec).with("hostname").in_sequence(seq).at_least_once
      Facter::Util::Resolution.stubs(:exec).with("dnsdomainname").in_sequence(seq).at_least_once
      File.expects(:open).with('/etc/resolv.conf').in_sequence(seq).at_least_once
      Facter.fact(:domain).value
    end

    describe "when using /etc/resolv.conf" do
      before do
        Facter::Util::Resolution.stubs(:exec).with("hostname")
        Facter::Util::Resolution.stubs(:exec).with("dnsdomainname")
        @f = mock()
        File.stubs(:open).with("/etc/resolv.conf").yields(@f)
      end

      it "should use the domain field over the search field" do
        lines = [
          "nameserver 4.2.2.1",
          "search example.org",
          "domain example.com",
        ]
        @f.expects(:each).multiple_yields(*lines)
        Facter.fact(:domain).value.should == 'example.com'
      end

      it "should fall back to the search field" do
        lines = [
          "nameserver 4.2.2.1",
          "search example.org",
        ]
        @f.expects(:each).multiple_yields(*lines)
        Facter.fact(:domain).value.should == 'example.org'
      end

      it "should use the first domain in the search field" do
        lines = [
          "search example.org example.net",
        ]
        @f.expects(:each).multiple_yields(*lines)
        Facter.fact(:domain).value.should == 'example.org'
      end

      # Test permutations of domain and search
      [
        %w{domain domain},
        %w{domain search},
        %w{search domain},
        %w{search search},
      ].each do |pair|
        field = pair[0]
        substr = pair[1]
        it "should permit #{substr} as a substring of the #{field} field" do
          lines = [
            "#{field} test.#{substr}.example.org"
          ]
          @f.expects(:each).multiple_yields(*lines)
          Facter.fact(:domain).value.should == "test.#{substr}.example.org"
        end
      end
    end
  end
end
