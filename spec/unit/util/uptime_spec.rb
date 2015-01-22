#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/uptime'
require 'facter/util/posix'

describe Facter::Util::Uptime do

  describe ".get_uptime_seconds_unix", :unless => Facter::Util::Config.is_windows? do
    describe "when /proc/uptime is available" do
      before do
        uptime_file = my_fixture("ubuntu_proc_uptime")
        Facter::Util::Uptime.stubs(:uptime_file).returns("\"#{uptime_file}\"")
      end

      it "should return the uptime in seconds as an integer" do
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 5097686
      end

    end

    describe "when /proc/uptime is not available" do
      before :each do
        @nonexistent_file = '/non/existent/file'
        File.exists?(@nonexistent_file).should == false
        Facter::Util::Uptime.stubs(:uptime_file).returns(@nonexistent_file)
      end

      it "should use 'sysctl -n kern.boottime' on OpenBSD" do
        Facter::Util::POSIX.stubs(:sysctl).returns(my_fixture_read("sysctl_kern_boottime_openbsd"))
        Time.stubs(:now).returns Time.utc(2011,12,9,22,11,46) # one hour later
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
      end

      it "should use 'sysctl -n kern.boottime' on Darwin, etc." do
        Facter::Util::POSIX.stubs(:sysctl).returns(my_fixture_read("sysctl_kern_boottime_darwin"))
        Time.stubs(:now).returns Time.utc(2011,10,30,22,52,27) # one hour later
        Facter::Util::Uptime.get_uptime_seconds_unix.should == 60 * 60
      end

      describe "nor is 'sysctl kern.boottime'" do
        before :each do
          Facter::Util::Uptime.stubs(:uptime_proc_uptime).returns(false)
          Facter::Util::Uptime.stubs(:uptime_sysctl).returns(false)
          Facter.fact(:kernel).stubs(:value).returns('SunOS')
        end

        describe "should use 'uptime' command" do
          # Note about uptime variations.
          # Solaris (I have examined 5.6, 5.7, 5.8, 5.9, 5.10 & 5.11) and HP-UX (11.00, 11.11, 11.23, 11.31) have time
          #   right justified at at 8 characters, and two spaces before 'up'.
          # Solaris differs from all other Unices (and Linux) in that the plural/singular case of minutes/hours/days are
          #   written min(s)/hr(s)/day(s) instead of min/mins/hr/hrs etc., e.g. 1 min(s), 2 min(s) as opposed to
          #   1 min, 2 mins, etc.
          # The coreutils package can be installed in Solaris, which brings in a GNU version of uptime. The output
          #   from this binary differs in that is is missing the comma after "day(s)"
          # Some versions of uptime in Solaris may also include a '-' character in the minutes field.
          # AIX (4.3.3, 5.2, 5.3, 6.1) differs from other SysV Unices in that times are padded with a leading 0 in the
          #   hour column where necessary, and have AM/PM in uppercase, and there are three spaces before 'up'.
          # Tru64 (4.0, 5.1) differs from other SysV Unices in that times are in 24 hour format, and there are no
          #   leading spaces.
          # Linux (RHEL, uptime version 2.0.7) differs from the SysV Unices in that only minutes before the first hour
          #   are written as 1 min, 2 min, 3 min etc. and after that full hours are rendered 1:00 or 21:00.  Time of
          #   day was written 5:37pm and right-justified at 8 characters, with 2 spaces before 'up'.  A figure in
          #   whole days was written as 3 days, 0 min.
          # By version 2.0.17 the time of day was rewritten in 24hr time with seconds, right-justified at 9 characters.
          # By version 3.2.7 one of the spaces before 'up' had been removed.
          test_cases = [
            ['  4:42pm  up 1 min(s),  0 users,  load average: 0.95, 0.25, 0.09',                                         1*60],
            ['13:16  up 58 mins,  2 users,  load average: 0.00, 0.02, 0.05',                                            58*60],
            ['13:18  up 1 hr,  1 user,  load average: 0.58, 0.23, 0.14',                                      1*60*60        ],
            [' 10:14pm  up 3 hr(s),  0 users,  load average: 0.00, 0.00, 0.00',                               3*60*60        ],
            ['14:18  up 2 hrs,  0 users,  load average: 0.33, 0.27, 0.29',                                    2*60*60        ],
            ['  9:01pm  up  1:47,  0 users,  load average: 0.00, 0.00, 0.00',                                 1*60*60 + 47*60],
            ['13:19  up  1:01,  1 user,  load average: 0.10, 0.26, 0.21',                                     1*60*60 +  1*60],
            ['10:49  up 22:31,  0 users,  load average: 0.26, 0.34, 0.27',                                   22*60*60 + 31*60],
            ['12:18  up 1 day,  0 users,  load average: 0.74, 0.20, 0.10',                      1*24*60*60                   ],
            ['  2:48pm  up 1 day(s),  0 users,  load average: 0.21, 0.20, 0.17',                1*24*60*60                   ],
            ['12:18  up 2 days,  0 users,  load average: 0.50, 0.27, 0.16',                     2*24*60*60                   ],
            ['  1:56pm  up 25 day(s),  2 users,  load average: 0.59, 0.56, 0.50',              25*24*60*60                   ],
            ['  1:29pm  up 485 days,  0 users,  load average: 0.00, 0.01, 0.01',              485*24*60*60                   ],
            [' 18:11:24  up 69 days, 0 min,  0 users,  load average: 0.00, 0.00, 0.00',        69*24*60*60                   ],
            ['12:19  up 1 day, 1 min,  0 users,  load average: 0.07, 0.16, 0.13',               1*24*60*60            +  1*60],
            ['  3:23pm  up 25 day(s), 27 min(s),  2 users,  load average: 0.49, 0.45, 0.46',   25*24*60*60            + 27*60],
            ['  02:42PM   up 1 day, 39 mins,  0 users,  load average: 1.49, 1.74, 1.80',        1*24*60*60            + 39*60],
            [' 18:13:13  up 245 days, 44 min,  1 user,  load average: 0.00, 0.00, 0.00',      245*24*60*60            + 44*60],
            ['  6:09pm  up 350 days, 2 min,  1 user,  load average: 0.02, 0.03, 0.00',        350*24*60*60            +  2*60],
            ['  1:07pm  up 174 day(s), 16 hr(s),  0 users,  load average: 0.05, 0.04, 0.03',  174*24*60*60 + 16*60*60        ],
            ['  02:34PM   up 621 days, 18 hrs,  0 users,  load average: 2.67, 2.52, 2.56',    621*24*60*60 + 18*60*60        ],
            ['  3:30am  up 108 days, 1 hr,  31 users,  load average: 0.39, 0.40, 0.41',       108*24*60*60 +  1*60*60        ],
            ['13:18  up 1 day, 1 hr,  0 users,  load average: 0.78, 0.33, 0.18',                1*24*60*60 +  1*60*60        ],
            ['14:18  up 1 day, 2 hrs,  0 users,  load average: 1.17, 0.48, 0.41',               1*24*60*60 +  2*60*60        ],
            ['15:56  up 152 days, 17 hrs,  0 users,  load average: 0.01, 0.06, 0.07',         152*24*60*60 + 17*60*60        ],
            ['  5:37pm  up 25 days, 21:00,  0 users,  load average: 0.01, 0.02, 0.00',         25*24*60*60 + 21*60*60        ],
            ['  8:59pm  up 94 day(s),  3:17,  46 users,  load average: 0.66, 0.67, 0.70',      94*24*60*60 +  3*60*60 + 17*60],
            ['  3:01pm  up 4496 day(s), 21:19,  32 users,  load average: 0.61, 0.62, 0.62',  4496*24*60*60 + 21*60*60 + 19*60],
            ['  02:42PM   up 41 days,   2:38,  0 users,  load average: 0.38, 0.70, 0.55',      41*24*60*60 +  2*60*60 + 38*60],
            [' 18:13:29  up 25 days, 21:36,  0 users,  load average: 0.00, 0.00, 0.00',        25*24*60*60 + 21*60*60 + 36*60],
            [' 13:36:05 up 118 days,  1:15,  1 user,  load average: 0.00, 0.00, 0.00',        118*24*60*60 +  1*60*60 + 15*60],
            ['10:27am  up 1 day  7:26,  1 user,  load average: 0.00, 0.00, 0.00',               1*24*60*60 +  7*60*60 + 26*60],
            ['22:45pm up 0:-6, 1 user, load average: 0.00, 0.00, 0.00',                                                  6*60],
            ['22:45pm up 1 day 0:-6, 1 user, load average: 0.00, 0.00, 0.00',                   1*24*60*60 +             6*60]
          ]

          test_cases.each do |uptime, expected|
            it "should return #{expected} for #{uptime}" do
              Facter::Core::Execution.stubs(:execute).with('uptime 2>/dev/null', {:on_fail => nil}).returns(uptime)
              Facter.fact(:uptime_seconds).value.should == expected
            end
          end

          describe "nor is 'uptime' command" do
            before :each do
              Facter::Core::Execution.stubs(:execute).with('uptime 2>/dev/null', {:on_fail => nil}).returns(nil)
            end

            it "should return nil" do
              Facter::Util::Uptime.get_uptime_seconds_unix.should == nil
            end
          end
        end
      end
    end
  end

  describe ".get_uptime_seconds_win", :if => Facter::Util::Config.is_windows? do
    it "should return a postive value" do
      Facter::Util::Uptime.get_uptime_seconds_win.should > 0
    end
  end
end
