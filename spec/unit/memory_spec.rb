#! /usr/bin/env ruby

require 'spec_helper'

describe "Memory facts" do
  before(:each) do
    Facter.collection.internal_loader.load(:memory)
  end

  after(:each) do
    Facter.clear
  end

  describe "when returning scaled sizes" do
    [  "memorysize",
       "memoryfree",
       "swapsize",
       "swapfree"
    ].each do |fact|

      describe "when #{fact}_mb does not exist" do
        before(:each) do
          Facter.fact(fact + "_mb").stubs(:value).returns(nil)
        end

        it "#{fact} should not exist either" do
          Facter.fact(fact).value.should be_nil
        end
      end

      {   "200.00"      => "200.00 MB",
          "1536.00"     => "1.50 GB",
          "1572864.00"  => "1.50 TB",
      }.each do |mbval, scval|
        it "should scale #{fact} when given #{mbval} MB" do
          Facter.fact(fact + "_mb").stubs(:value).returns(mbval)
          Facter.fact(fact).value.should == scval
        end
      end
    end

    after(:each) do
      Facter.clear
    end
  end

  describe "on Darwin" do
    before(:each) do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      Facter::Util::POSIX.stubs(:sysctl).with('hw.memsize').returns('8589934592')
      Facter::Core::Execution.stubs(:exec).with('vm_stat').returns(my_fixture_read('darwin-vm_stat'))
      Facter::Util::POSIX.stubs(:sysctl).with('vm.swapusage').returns("vm.swapusage: total = 64.00M  used = 1.00M  free = 63.00M  (encrypted)")

      Facter.collection.internal_loader.load(:memory)
    end

    it "should return the current swap size in MB" do
      Facter.fact(:swapsize_mb).value.should == "64.00"
    end

    it "should return the current swap free in MB" do
      Facter.fact(:swapfree_mb).value.should == "63.00"
    end

    it "should return whether swap is encrypted" do
      Facter.fact(:swapencrypted).value.should == true
    end

    it "should return the memory size in MB" do
      Facter.fact(:memorysize_mb).value.should == "8192.00"
    end

    it "should return the memory free in MB" do
      Facter.fact(:memoryfree_mb).value.should == "138.70"
    end

    after(:each) do
      Facter.clear
    end
  end

  [   "linux",
      "gnu/kfreebsd",
  ].each do |kernel|


    describe "on #{kernel}" do
      before(:each) do
        Facter.clear
        Facter.fact(:kernel).stubs(:value).returns(kernel)

        meminfo_contents = my_fixture_read('linux-proc_meminfo').split("\n")

        File.stubs(:readlines).with("/proc/meminfo").returns(meminfo_contents)

        Facter.collection.internal_loader.load(:memory)
      end

      after(:each) do
        Facter.clear
      end

      it "should return the current memory size in MB" do
        Facter.fact(:memorysize_mb).value.should == "249.91"
      end

      it "should return the current memory free in MB" do
        Facter.fact(:memoryfree_mb).value.should == "196.16"
      end

      it "should return the current swap size in MB" do
        Facter.fact(:swapsize_mb).value.should == "511.99"
      end

      it "should return the current swap free in MB" do
        Facter.fact(:swapfree_mb).value.should == "511.99"
      end
    end
  end

  describe "on AIX" do
    before (:each) do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("AIX")

      Facter::Core::Execution.stubs(:exec).with('swap -l 2>/dev/null').returns(my_fixture_read('aix-swap_l'))
      Facter::Core::Execution.stubs(:exec).with('/usr/bin/svmon -O unit=KB').returns(my_fixture_read('aix-svmon'))

      Facter.collection.internal_loader.load(:memory)
    end

    after(:each) do
      Facter.clear
    end

    describe "when not root" do
      before(:each) do
        Facter.fact(:id).stubs(:value).returns("notroot")
      end

      it "should return nil for swap size" do
        Facter.fact(:swapsize_mb).value.should be_nil
      end

      it "should return nil for swap free" do
        Facter.fact(:swapfree_mb).value.should be_nil
      end
    end

    describe "when root" do
      before(:each) do
        Facter.fact(:id).stubs(:value).returns("root")
      end

      it "should return the current swap size in MB" do
        Facter.fact(:swapsize_mb).value.should == "512.00"
      end

      it "should return the current swap free in MB" do
        Facter.fact(:swapfree_mb).value.should == "508.00"
      end
    end

    it "should return the current memory free in MB" do
      Facter.fact(:memoryfree_mb).value.should == "22284.76"
    end

    it "should return the current memory size in MB" do
      Facter.fact(:memorysize_mb).value.should == "32000.00"
    end

  end


  describe "on OpenBSD" do
    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")

      swapusage = "total: 4080510 512-blocks allocated, 461832 used, 3618678 available"
      Facter::Core::Execution.stubs(:exec).with('swapctl -s').returns(swapusage)

      Facter::Core::Execution.stubs(:exec).with('vmstat').returns(my_fixture_read('openbsd-vmstat'))

      Facter::Util::POSIX.stubs(:sysctl).with('hw.physmem').returns('267321344')
      Facter::Util::POSIX.stubs(:sysctl).with('vm.swapencrypt.enable').returns('1')

      Facter.collection.internal_loader.load(:memory)
    end

    after :each do
      Facter.clear
    end

    it "should return the current swap free in MB" do
      Facter.fact(:swapfree_mb).value.should == "1766.93"
    end

    it "should return the current swap size in MB" do
      Facter.fact(:swapsize_mb).value.should == "1992.44"
    end

    it "should return the current memory free in MB" do
      Facter.fact(:memoryfree_mb).value.should == "176.79"
    end

    it "should return the current memory size in MB" do
      Facter.fact(:memorysize_mb).value.should == "254.94"
    end

    it "should return whether swap is encrypted" do
      Facter.fact(:swapencrypted).value.should == true
    end
  end


  describe "on Solaris" do
    before(:each) do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("SunOS")

      Facter::Core::Execution.stubs(:exec).with('/usr/sbin/prtconf 2>/dev/null').returns(my_fixture_read('solaris-prtconf'))
      Facter::Core::Execution.stubs(:exec).with('vmstat').returns(my_fixture_read('solaris-vmstat'))
    end

    after(:each) do
      Facter.clear
    end

    describe "when single swap exists" do
      before(:each) do
        Facter::Core::Execution.stubs(:exec).with('/usr/sbin/swap -l 2>/dev/null').returns my_fixture_read('solaris-swap_l-single')

        Facter.collection.internal_loader.load(:memory)
      end

      it "should return the current memory size in MB" do
        Facter.fact(:memorysize_mb).value.should == "2048.00"
      end

      it "should return the current memory free in MB" do
        Facter.fact(:memoryfree_mb).value.should == "465.06"
      end

      it "should return the current swap free in MB" do
        Facter.fact(:swapfree_mb).value.should == "1023.99"
      end

      it "should return the current swap size in MB" do
        Facter.fact(:swapsize_mb).value.should == "1023.99"
      end

    end

    describe "when multiple swaps exist" do
      before(:each) do
        Facter::Core::Execution.stubs(:exec).with('/usr/sbin/swap -l 2>/dev/null').returns my_fixture_read('solaris-swap_l-multiple')
        Facter.collection.internal_loader.load(:memory)
      end

      it "should return the current memory size in MB" do
        Facter.fact(:memorysize_mb).value.should == "2048.00"
      end

      it "should return the current memory free in MB" do
        Facter.fact(:memoryfree_mb).value.should == "465.06"
      end

      it "should return the current swap free in MB" do
        Facter.fact(:swapfree_mb).value.should == "2047.98"
      end

      it "should return the current swap size in MB" do
        Facter.fact(:swapsize_mb).value.should == "2047.98"
      end
    end

    describe "when no swap exists" do
      before(:each) do
        Facter::Core::Execution.stubs(:exec).with('/usr/sbin/swap -l 2>/dev/null').returns ""

        Facter.collection.internal_loader.load(:memory)
      end

      it "should return the current memory size in MB" do
        Facter.fact(:memorysize_mb).value.should == "2048.00"
      end

      it "should return the current memory free in MB" do
        Facter.fact(:memoryfree_mb).value.should == "465.06"
      end

      it "should return 0 for the swap free in MB" do
        Facter.fact(:swapfree_mb).value.should == "0.00"
      end

      it "should return 0 for the swap size in MB" do
        Facter.fact(:swapsize_mb).value.should == "0.00"
      end
    end

    describe "when in a SmartOS zone" do
      before(:each) do
        Facter::Core::Execution.stubs(:exec).with('/usr/sbin/swap -l 2>/dev/null').returns my_fixture_read('smartos_zone_swap_l-single')
        Facter.collection.internal_loader.load(:memory)
      end

      it "should return the current swap size in MB" do
        Facter.fact(:swapsize_mb).value.should == "49152.00"
      end

      it "should return the current swap free in MB" do
        Facter.fact(:swapfree_mb).value.should == "33676.06"
      end
    end

  end

    describe "on DragonFly BSD" do
      before :each do
        Facter.clear
        Facter.fact(:kernel).stubs(:value).returns("dragonfly")

        swapusage = "total: 148342k bytes allocated = 0k used, 148342k available"
        Facter::Util::POSIX.stubs(:sysctl).with('hw.pagesize').returns("4096")
        Facter::Util::POSIX.stubs(:sysctl).with('vm.swap_size').returns("128461")
        Facter::Util::POSIX.stubs(:sysctl).with('vm.swap_anon_use').returns("2635")
        Facter::Util::POSIX.stubs(:sysctl).with('vm.swap_cache_use').returns("0")

        Facter::Core::Execution.stubs(:exec).with('vmstat').returns my_fixture_read('dragonfly-vmstat')

        Facter::Util::POSIX.stubs(:sysctl).with("hw.physmem").returns('248512512')

        Facter.collection.internal_loader.load(:memory)
      end

      after :each do
        Facter.clear
      end

      it "should return the current swap free in MB" do
        Facter.fact(:swapfree_mb).value.should == "491.51"
      end

      it "should return the current swap size in MB" do
        Facter.fact(:swapsize_mb).value.should == "501.80"
      end

      it "should return the current memory size in MB" do
        Facter.fact(:memorysize_mb).value.should == "237.00"
      end

      it "should return the current memory free in MB" do
        Facter.fact(:memoryfree_mb).value.should == "13.61"
      end
    end

    describe "on FreeBSD" do
      before(:each) do
        Facter.clear
        Facter.fact(:kernel).stubs(:value).returns("FreeBSD")

        Facter::Core::Execution.stubs(:exec).with('vmstat -H').returns my_fixture_read('freebsd-vmstat')
        Facter::Util::POSIX.stubs(:sysctl).with('hw.physmem').returns '1056276480'
      end

      after(:each) do
        Facter.clear
      end

      describe "with no swap" do
        before(:each) do
          sample_swapinfo = 'Device          1K-blocks     Used    Avail Capacity'

          Facter::Core::Execution.stubs(:exec).with('swapinfo -k').returns sample_swapinfo
          Facter.collection.internal_loader.load(:memory)
        end

        it "should return the current swap free in MB" do
          Facter.fact(:swapfree_mb).value.should == "0.00"
        end

        it "should return the current swap size in MB" do
          Facter.fact(:swapsize_mb).value.should == "0.00"
        end

        it "should return the current memory size in MB" do
          Facter.fact(:memorysize_mb).value.should == "1007.34"
        end

        it "should return the current memory free in MB" do
          Facter.fact(:memoryfree_mb).value.should == "641.25"
        end
      end

      describe "with one swap" do
        before(:each) do
          Facter::Core::Execution.stubs(:exec).with('swapinfo -k').returns my_fixture_read('darwin-swapinfo-single')

          Facter.collection.internal_loader.load(:memory)
        end

        it "should return the current swap free in MB" do
          Facter.fact(:swapfree_mb).value.should == "1023.96"
        end

        it "should return the current swap size in MB" do
          Facter.fact(:swapsize_mb).value.should == "2000.53"
        end

        it "should return the current memory size in MB" do
          Facter.fact(:memorysize_mb).value.should == "1007.34"
        end

        it "should return the current memory free in MB" do
          Facter.fact(:memoryfree_mb).value.should == "641.25"
        end
      end

      describe "with multiple swaps" do
        before(:each) do
          Facter::Core::Execution.stubs(:exec).with('swapinfo -k').returns my_fixture_read('darwin-swapinfo-multiple')

          Facter.collection.internal_loader.load(:memory)
        end

        it "should return the current swap free in MB" do
          Facter.fact(:swapfree_mb).value.should == "2047.93"
        end

        it "should return the current swap size in MB" do
          Facter.fact(:swapsize_mb).value.should == "4977.62"
        end

        it "should return the current memory size in MB" do
          Facter.fact(:memorysize_mb).value.should == "1007.34"
        end

        it "should return the current memory free in MB" do
          Facter.fact(:memoryfree_mb).value.should == "641.25"
        end
      end
    end

    describe "on Windows" do
      before :each do
        Facter.clear
        Facter.fact(:kernel).stubs(:value).returns("windows")
        Facter.collection.internal_loader.load(:memory)
        require 'facter/util/wmi'
      end

      it "should return free memory in MB" do
        os = stubs 'os'
        os.stubs(:FreePhysicalMemory).returns("3415624")
        Facter::Util::WMI.stubs(:execquery).returns([os])

        Facter.fact(:memoryfree_mb).value.should == '3335.57'
      end

      it "should return total memory in MB" do
        computer = stubs 'computer'
        computer.stubs(:TotalPhysicalMemory).returns("4193837056")
        Facter::Util::WMI.stubs(:execquery).returns([computer])

        Facter.fact(:memorysize_mb).value.should == '3999.55'
    end
  end
end
