#! /usr/bin/env ruby

require 'spec_helper'
require 'stringio'

describe "Domain name facts" do

  def resolv_conf_contains(*lines)
    file_handle = StringIO.new(lines.join("\n"))
    FileTest.stubs(:exists?).with("/etc/resolv.conf").returns(true)
    File.stubs(:open).with("/etc/resolv.conf").yields(file_handle)
  end

  [
    { :kernel => "Linux", :hostname_command => "hostname -f 2> /dev/null" },
    { :kernel => "SunOS", :hostname_command => "hostname 2> /dev/null" },
    { :kernel => "Darwin", :hostname_command => "hostname -f 2> /dev/null" },
    { :kernel => "FreeBSD", :hostname_command => "hostname -f 2> /dev/null" },
    { :kernel => "HP-UX", :hostname_command => "hostname 2> /dev/null" },
  ].each do |scenario|

    describe "on #{scenario[:kernel]}" do
      let(:hostname_command) { scenario[:hostname_command] }
      let(:dnsdomain_command) { "dnsdomainname 2> /dev/null" }

      def the_hostname_is(value)
        Facter::Core::Execution.stubs(:exec).with(hostname_command).returns(value)
      end

      def the_dnsdomainname_is(value)
        Facter::Core::Execution.stubs(:exec).with(dnsdomain_command).returns(value)
      end

      before do
        Facter.fact(:kernel).stubs(:value).returns(scenario[:kernel])
      end

      it "should use the hostname binary" do
        the_hostname_is("test.example.com")

        Facter.fact(:domain).value.should == "example.com"
      end

      it "should fall back to the dnsdomainname binary" do
        the_hostname_is("myhost")
        the_dnsdomainname_is("example.com")

        Facter.fact(:domain).value.should == "example.com"
      end

      it "should fall back to /etc/resolv.conf" do
        the_hostname_is("myhost")
        the_dnsdomainname_is("")

        resolv_conf_contains("domain testing.com")

        Facter.fact(:domain).value.should == "testing.com"
      end

      describe "Top level domain" do
        it "should find the domain name" do
          the_hostname_is("ns01.tld")

          Facter.fact(:domain).value.should == "tld"
        end
      end

      describe "when using /etc/resolv.conf" do
        before do
          the_hostname_is("")
          the_dnsdomainname_is("")
        end

        it "should use the domain field over the search field" do
          resolv_conf_contains(
            "nameserver 4.2.2.1",
            "search example.org",
            "domain example.com"
          )

          Facter.fact(:domain).value.should == 'example.com'
        end

        it "should fall back to the search field" do
          resolv_conf_contains(
            "nameserver 4.2.2.1",
            "search example.org"
          )

          Facter.fact(:domain).value.should == 'example.org'
        end

        it "should use the first domain in the search field" do
          resolv_conf_contains("search example.org example.net")

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
         [["domain domain"], "domain"],
         [["domain search"], "search"],
         [["search domain"], "domain"],
         [["search search"], "search"],
         [["search domain notdomain"], "domain"],
         [["#search notdomain", "search search"], "search"],
         [["# search notdomain", "search search"], "search"],
         [["#domain notdomain", "domain domain"], "domain"],
         [["# domain notdomain", "domain domain"], "domain"],
        ].each do |tuple|
          conf  = tuple[0]
          expect = tuple[1]
          it "should return #{expect} from \"#{conf}\"" do
            resolv_conf_contains(*conf)

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

      def expects_dnsdomains(domains)
        nics = []

        domains.each do |domain|
          nic = stubs 'nic'
          nic.stubs(:DNSDomain).returns(domain)
          nics << nic
        end

        require 'facter/util/wmi'
        Facter::Util::WMI.stubs(:execquery).with("select DNSDomain from Win32_NetworkAdapterConfiguration where IPEnabled = True").returns(nics)
      end

      it "uses the first DNSDomain" do
        expects_dnsdomains(['foo.com', 'bar.com'])

        Facter.fact(:domain).value.should == 'foo.com'
      end

      it "uses the first non-nil DNSDomain" do
        expects_dnsdomains([nil, 'bar.com'])

        Facter.fact(:domain).value.should == 'bar.com'
      end

      it "uses the first non-empty DNSDomain" do
        expects_dnsdomains(['', 'bar.com'])

        Facter.fact(:domain).value.should == 'bar.com'
      end

      context "without any network adapters with a specified DNSDomain" do
        let(:hostname_command) { 'hostname > NUL' }

        it "should return nil" do
          expects_dnsdomains([nil])

          Facter::Core::Execution.stubs(:exec).with(hostname_command).returns('sometest')
          FileTest.stubs(:exists?).with("/etc/resolv.conf").returns(false)

          Facter.fact(:domain).value.should be_nil
        end
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

      [
        {
          :scenario => 'when there is only a hostname',
          :hostname => 'host.testdomain.',
          :dnsdomainname => '',
          :resolve_domain => '',
          :resolve_search => '',
          :expect => 'testdomain'
        },
        {
          :scenario => 'when there is only a domain name',
          :hostname => '',
          :dnsdomainname => 'testdomain.',
          :resolve_domain => '',
          :resolve_search => '',
          :expect => 'testdomain'
        },
        {
          :scenario => 'when there is only a resolve domain',
          :hostname => '',
          :dnsdomainname => '',
          :resolve_domain => 'testdomain.',
          :resolve_search => '',
          :expect => 'testdomain'
        },
        {
          :scenario => 'when there is only a resolve search',
          :hostname => '',
          :dnsdomainname => '',
          :resolve_domain => '',
          :resolve_search => 'testdomain.',
          :expect => 'testdomain'
        },
        {
          :scenario => 'when there is no information available',
          :hostname => '',
          :dnsdomainname => '',
          :resolve_domain => '',
          :resolve_search => '',
          :expect => nil
        }
      ].each do |scenario|

        describe scenario[:scenario] do
          before(:each) do
            Facter::Core::Execution.stubs(:exec).with("hostname -f 2> /dev/null").returns(scenario[:hostname])
            Facter::Core::Execution.stubs(:exec).with("dnsdomainname 2> /dev/null").returns(scenario[:dnsdomainname])
            resolv_conf_contains(
              "search #{scenario[:resolve_search]}",
              "domain #{scenario[:resolve_domain]}"
            )
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
