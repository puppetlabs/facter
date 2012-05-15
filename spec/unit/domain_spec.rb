#!/usr/bin/env rspec

require 'spec_helper'

describe "Domain name facts" do

  { :linux => {:kernel => "Linux", :hostname_command => "hostname -f"},
    :solaris => {:kernel => "SunOS", :hostname_command => "hostname"},
    :darwin => {:kernel => "Darwin", :hostname_command => "hostname -f"},
    :freebsd => {:kernel => "FreeBSD", :hostname_command => "hostname -f"},
    :hpux => {:kernel => "HP-UX", :hostname_command => "hostname"},
  }.each do |key, nested_hash|

    describe "on #{key}" do
      before do
        Facter.fact(:kernel).stubs(:value).returns(nested_hash[:kernel])
        FileTest.stubs(:exists?).with("/etc/resolv.conf").returns(true)
      end
      
      let :hostname_command do 
        nested_hash[:hostname_command]
      end 
      
      it "should use the hostname binary" do
        Facter::Util::Resolution.expects(:exec).with(hostname_command).returns "test.example.com"
        Facter.fact(:domain).value.should == "example.com"
      end
      
      it "should fall back to the dnsdomainname binary" do
        Facter::Util::Resolution.expects(:exec).with(hostname_command).returns("myhost")
        Facter::Util::Resolution.expects(:exec).with("dnsdomainname").returns("example.com")
        Facter.fact(:domain).value.should == "example.com"
      end
      
      
      it "should fall back to /etc/resolv.conf" do
        Facter::Util::Resolution.expects(:exec).with(hostname_command).at_least_once.returns("myhost")
        Facter::Util::Resolution.expects(:exec).with("dnsdomainname").at_least_once.returns("")
        File.expects(:open).with('/etc/resolv.conf').at_least_once
        Facter.fact(:domain).value
      end
      
      it "should attempt to resolve facts in a specific order" do
        seq = sequence('domain')
        Facter::Util::Resolution.stubs(:exec).with(hostname_command).in_sequence(seq).at_least_once
        Facter::Util::Resolution.stubs(:exec).with("dnsdomainname").in_sequence(seq).at_least_once
        File.expects(:open).with('/etc/resolv.conf').in_sequence(seq).at_least_once
        Facter.fact(:domain).value
      end
      
      describe "Top level domain" do 
        it "should find the domain name" do
          Facter::Util::Resolution.expects(:exec).with(hostname_command).returns "ns01.tld"
          Facter::Util::Resolution.expects(:exec).with("dnsdomainname").never
          File.expects(:exists?).with('/etc/resolv.conf').never
          Facter.fact(:domain).value.should == "tld" 
        end  
      end 
      
      describe "when using /etc/resolv.conf" do
        before do
          Facter::Util::Resolution.stubs(:exec).with(hostname_command)
          Facter::Util::Resolution.stubs(:exec).with("dnsdomainname")
          @mock_file = mock()
          File.stubs(:open).with("/etc/resolv.conf").yields(@mock_file)
        end
        
        it "should use the domain field over the search field" do
          lines = [
                   "nameserver 4.2.2.1",
                   "search example.org",
                   "domain example.com",
                  ]
          @mock_file.expects(:each).multiple_yields(*lines)
          Facter.fact(:domain).value.should == 'example.com'
        end

        it "should fall back to the search field" do
          lines = [
                   "nameserver 4.2.2.1",
                   "search example.org",
                  ]
          @mock_file.expects(:each).multiple_yields(*lines)
          Facter.fact(:domain).value.should == 'example.org'
        end
        
        it "should use the first domain in the search field" do
          lines = [
                   "search example.org example.net",
                  ]
          @mock_file.expects(:each).multiple_yields(*lines)
          Facter.fact(:domain).value.should == 'example.org'
        end
        
        # Test permutations of domain and search, where 'domain' can be a value of
        # the search keyword and the domain keyword
        # and also where 'search' can be a value of the search keyword and the
        # domain keyword
        # For example, /etc/resolv.conf may look like:
        #     domain domain
        # or
        #     search search
        # or
        #     domain search
        #
        #
        # Why someone would have their machines named 'www.domain' or 'www.search', I
        # don't know, but we'll at least handle it properly
        [
         ["domain domain", "domain"],
         ["domain search", "search"],
         ["search domain", "domain"],
         ["search search", "search"],
         ["search domain notdomain", "domain"],
         [["#search notdomain","search search"], "search"],
         [["# search notdomain","search search"], "search"],
         [["#domain notdomain","domain domain"], "domain"],
         [["# domain notdomain","domain domain"], "domain"],
        ].each do |tuple|
          field  = tuple[0]
          expect = tuple[1]
          it "should return #{expect} from \"#{field}\"" do
            lines = [
                     field
                    ].flatten
            @mock_file.expects(:each).multiple_yields(*lines)
            Facter.fact(:domain).value.should == expect
          end
        end
      end
    end
  end 

  describe "on Windows" do
    before(:each) do
      Facter.fact(:kernel).stubs(:value).returns("windows")
      require 'facter/util/registry'
    end

    describe "with primary dns suffix" do
      before(:each) do
        Facter::Util::Registry.stubs(:hklm_read).returns('baz.com')
      end

      it "should get the primary dns suffix" do
        Facter.fact(:domain).value.should == 'baz.com'
      end

      it "should not execute the wmi query" do
        require 'facter/util/wmi'
        Facter::Util::WMI.expects(:execquery).never
        Facter.fact(:domain).value
      end
    end

    describe "without primary dns suffix" do
      before(:each) do
        Facter::Util::Registry.stubs(:hklm_read).returns('')
      end

      it "should use the DNSDomain for the first nic where ip is enabled" do
        nic = stubs 'nic'
        nic.stubs(:DNSDomain).returns("foo.com")

        nic2 = stubs 'nic'
        nic2.stubs(:DNSDomain).returns("bar.com")

        require 'facter/util/wmi'
        Facter::Util::WMI.stubs(:execquery).with("select DNSDomain from Win32_NetworkAdapterConfiguration where IPEnabled = True").returns([nic, nic2])

        Facter.fact(:domain).value.should == 'foo.com'
      end
    end
  end

  describe "with trailing dots" do 
    describe "on Windows" do 
      before do
        Facter.fact(:kernel).stubs(:value).returns("windows")
        require 'facter/util/registry'
        require 'facter/util/wmi'
      end
 
      [{:registry => 'testdomain.', :wmi => '', :expect => 'testdomain'},
       {:registry => '', :wmi => 'testdomain.', :expect => 'testdomain'},
      ].each do |scenario|

        describe "scenarios" do 
          before(:each) do
            Facter::Util::Registry.stubs(:hklm_read).returns(scenario[:registry])
            nic = stubs 'nic'
            nic.stubs(:DNSDomain).returns(scenario[:wmi])
            Facter::Util::WMI.stubs(:execquery).with("select DNSDomain from Win32_NetworkAdapterConfiguration where IPEnabled = True").returns([nic])
          end
 
          it "should return #{scenario[:expect]}" do
            Facter.fact(:domain).value.should == scenario[:expect]
          end
 
          it "should remove trailing dots"  do
            Facter.fact(:domain).value.should_not =~ /\.$/
          end
        end 
      end 
    end

    describe "on everything else" do
      before do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        FileTest.stubs(:exists?).with("/etc/resolv.conf").returns(true)
      end

      [{:hostname => 'host.testdomain.', :dnsdomainname => '', :resolve_domain => '', :resolve_search => '', :expect => 'testdomain'},
       {:hostname => '', :dnsdomainname => 'testdomain.', :resolve_domain => '', :resolve_search => '', :expect => 'testdomain'},
       {:hostname => '', :dnsdomainname => '', :resolve_domain => 'testdomain.', :resolve_search => '', :expect => 'testdomain'},
       {:hostname => '', :dnsdomainname => '', :resolve_domain => '', :resolve_search => 'testdomain.', :expect => 'testdomain'}, 
       {:hostname => '', :dnsdomainname => '', :resolve_domain => '', :resolve_search => '', :expect => nil}
      ].each do |scenario|

        describe "scenarios" do
          before(:each) do 
            Facter::Util::Resolution.stubs(:exec).with("hostname -f").returns(scenario[:hostname])
            Facter::Util::Resolution.stubs(:exec).with("dnsdomainname").returns(scenario[:dnsdomainname])
            @mock_file = mock()
            File.stubs(:open).with("/etc/resolv.conf").yields(@mock_file)
            lines = [
                     "search #{scenario[:resolve_search]}",
                     "domain #{scenario[:resolve_domain]}",
                    ]
            @mock_file.stubs(:each).multiple_yields(*lines)
          end

          it "should remove trailing dots" do
            Facter.fact(:domain).value.should_not =~ /\.$/
          end

          it "should return #{scenario[:expect]}" do
            Facter.fact(:domain).value.should == scenario[:expect]
          end
        end
      end      
    end
  end
end
