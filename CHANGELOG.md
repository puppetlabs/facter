## [4.0.41](https://github.com/puppetlabs/facter/tree/4.0.41) (2020-10-01)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.40...4.0.41)

### Fixed

- (FACT-2824) Facter make ec2 metadata requests when on gce [#2113](https://github.com/puppetlabs/facter/pull/2113) ([IrimieBogdan](https://github.com/IrimieBogdan))


## [4.0.40](https://github.com/puppetlabs/facter/tree/4.0.40) (2020-09-30)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.39...4.0.40)

### Added

- (FACT-2774) Extend facter API with resolve. [#2054](https://github.com/puppetlabs/facter/pull/2054) ([IrimieBogdan](https://github.com/IrimieBogdan))

### Fixed

- (FACT-2798) Set color to true, fix Facter.log_exception [#2105](https://github.com/puppetlabs/facter/pull/2105) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- (FACT-2816) - Fix ec2 fact issues when on non ec2 systems [#2106](https://github.com/puppetlabs/facter/pull/2106) ([logicminds](https://github.com/logicminds))
- (FACT-2799) Fix fact loading for nested fact calls [#2108](https://github.com/puppetlabs/facter/pull/2108) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2786) Fix fact caching if fact is defined in multiple groups [#2089](https://github.com/puppetlabs/facter/pull/2089) ([florindragos](https://github.com/florindragos))
- (maint) Fix for blockdevice_*_size legacy fact on Aix and Solaris [#2111](https://github.com/puppetlabs/facter/pull/2111) ([sebastian-miclea](https://github.com/sebastian-miclea))


## [4.0.39](https://github.com/puppetlabs/facter/tree/4.0.39) (2020-09-23)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.38...4.0.39)

### Added

- (FACT-2746) Added cloud resolver [#2082](https://github.com/puppetlabs/facter/pull/2082) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2317) Add Facter.define_fact method [#2102](https://github.com/puppetlabs/facter/pull/2102) ([oanatmaria](https://github.com/oanatmaria))
- FACT(2326) Add Facter.each method [#2100](https://github.com/puppetlabs/facter/pull/2100) ([florindragos](https://github.com/florindragos))
- (FACT-2324) Add loadfacts API method [#2103](https://github.com/puppetlabs/facter/pull/2103) ([sebastian-miclea](https://github.com/sebastian-miclea))

### Fixed

- (FACT-2802) Fix Cloud resolver [#2093](https://github.com/puppetlabs/facter/pull/2093) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- (FACT-2803) Detect hypervisors as amazon if virtwhat detects aws. [#2095](https://github.com/puppetlabs/facter/pull/2095) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2748) Fixed type for blockdevice_*_size [#2098](https://github.com/puppetlabs/facter/pull/2098) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2793) Time limit for Facter::Core::Execute [#2080](https://github.com/puppetlabs/facter/pull/2080) ([oanatmaria](https://github.com/oanatmaria))


## [4.0.38](https://github.com/puppetlabs/facter/tree/4.0.38) (2020-09-16)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.37...4.0.38)

### Added

- (FACT-2319) Added debugonce method [#2085](https://github.com/puppetlabs/facter/pull/2085) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- (FACT-2327) added list method [#2088](https://github.com/puppetlabs/facter/pull/2088) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- (FACT-2320) Added warnonce method [#2084](https://github.com/puppetlabs/facter/pull/2084) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- (FACT-2315) Added warn method to facter api [#2083](https://github.com/puppetlabs/facter/pull/2083) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))

### Fixed

- (FACT-2784) Fixed rhel os release fact [#2086](https://github.com/puppetlabs/facter/pull/2086) ([sebastian-miclea](https://github.com/sebastian-miclea))


## [4.0.37](https://github.com/puppetlabs/facter/tree/4.0.37) (2020-09-09)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.36-fixed...4.0.37)

### Added

- (FACT-1380) Restore --timing option to native facter [#2061](https://github.com/puppetlabs/facter/pull/2061) ([IrimieBogdan](https://github.com/IrimieBogdan))

### Fixed

- (FACT-2781) Fix filesystems on osx [#2065](https://github.com/puppetlabs/facter/pull/2065) ([florindragos](https://github.com/florindragos))
- (FACT-2777) Fix lsbdist facts on ubuntu [#2063](https://github.com/puppetlabs/facter/pull/2063) ([florindragos](https://github.com/florindragos))
- (FACT-2783) Updated how osx mountpoints are calculated [#2072](https://github.com/puppetlabs/facter/pull/2072) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2776) Fix Linux partitions fact [#2076](https://github.com/puppetlabs/facter/pull/2076) ([oanatmaria](https://github.com/oanatmaria))
- (FACT-2785) partitions.<partition_name>.mount has wrong value on sles15-64 [#2077](https://github.com/puppetlabs/facter/pull/2077) ([IrimieBogdan](https://github.com/IrimieBogdan))


## [4.0.36](https://github.com/puppetlabs/facter/tree/4.0.36) (2020-09-02)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.35...4.0.36-fixed)

### Added

- (FACT-2747) Add missing legacy facts on all platforms [#2034](https://github.com/puppetlabs/facter/pull/2034) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2721) Added Solaris virtual fact [#2033](https://github.com/puppetlabs/facter/pull/2033) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2745) Add Linux xen fact [#2040](https://github.com/puppetlabs/facter/pull/2040) ([oanatmaria](https://github.com/oanatmaria))
- (FACT-2740) Add Gce fact [#2035](https://github.com/puppetlabs/facter/pull/2035) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- (FACT-2743) Added LDom fact for solaris [#2041](https://github.com/puppetlabs/facter/pull/2041) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2296) Added fact group for legacy facts [#2047](https://github.com/puppetlabs/facter/pull/2047) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2753) Resolve facts sequentially. [#2050](https://github.com/puppetlabs/facter/pull/2050) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2728) Added hypervisors fact for Solaris [#2045](https://github.com/puppetlabs/facter/pull/2045) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2752) Added serialnumber fact for AIX [#2052](https://github.com/puppetlabs/facter/pull/2052) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2729) Add Solaris is_virtual fact [#2056](https://github.com/puppetlabs/facter/pull/2056) ([oanatmaria](https://github.com/oanatmaria))
- (FACT-2773) Added board_asset_tag fact for linux [#2059](https://github.com/puppetlabs/facter/pull/2059) ([sebastian-miclea](https://github.com/sebastian-miclea))

### Fixed

- (FACT-2454) fix how used memory is calculated [#2038](https://github.com/puppetlabs/facter/pull/2038) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- (FACT-2747-scope6) Allow scope6 to be blocked on all platforms [#2037](https://github.com/puppetlabs/facter/pull/2037) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (maint) Add nil check for ec2 facts. [#2042](https://github.com/puppetlabs/facter/pull/2042) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (maint) Correctly initialise logger. [#2043](https://github.com/puppetlabs/facter/pull/2043) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2747) Add ssh legacy facts. [#2044](https://github.com/puppetlabs/facter/pull/2044) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2561) Fix blocking mechanism [#2046](https://github.com/puppetlabs/facter/pull/2046) ([oanatmaria](https://github.com/oanatmaria))
- (FACT-2741) Fix double quotes for numbers in yaml formatter [#2053](https://github.com/puppetlabs/facter/pull/2053) ([florindragos](https://github.com/florindragos))
- (FACT-2754) Add os.distro release legacy facts [#2055](https://github.com/puppetlabs/facter/pull/2055) ([oanatmaria](https://github.com/oanatmaria))
- (FACT-2771) Fix Solaris kernelmajversion fact [#2057](https://github.com/puppetlabs/facter/pull/2057) ([oanatmaria](https://github.com/oanatmaria))
- (FACT-2457) Display newlines in values [#2058](https://github.com/puppetlabs/facter/pull/2058) ([florindragos](https://github.com/florindragos))


## [4.0.35](https://github.com/puppetlabs/facter/tree/4.0.35) (2020-08-19)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.34...4.0.35)

### Added

- (FACT-2726) Add solaris dmi facts [#2025](https://github.com/puppetlabs/facter/pull/2025) ([florindragos](https://github.com/florindragos))
- (FACT-2722) Add disks fact for Solaris [#2027](https://github.com/puppetlabs/facter/pull/2027) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))

### Fixed

- (FACT-2723) --list-*-groups also displays external facts [#2024](https://github.com/puppetlabs/facter/pull/2024) ([sebastian-miclea](https://github.com/sebastian-miclea))
- (FACT-2742) Exclude net/https when running on jruby FIPS [#2030](https://github.com/puppetlabs/facter/pull/2030) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2737) facter uptime shows host uptime inside docker container [#2031](https://github.com/puppetlabs/facter/pull/2031) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2672) Fix ssh fact output [#2029](https://github.com/puppetlabs/facter/pull/2029) ([oanatmaria](https://github.com/oanatmaria))
- (FACT-2402) Exclude fuseblk from filesystems [#2032](https://github.com/puppetlabs/facter/pull/2032) ([oanatmaria](https://github.com/oanatmaria))


## [4.0.34](https://github.com/puppetlabs/facter/tree/4.0.34) (2020-08-12)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.33...4.0.34)

### Added

- (FACT-2739) Extend os hierarchy to consider multiple os families [#2016](https://github.com/puppetlabs/facter/pull/2016) ([IrimieBogdan](https://github.com/IrimieBogdan))
- Add FreeBSD memory facts [#2020](https://github.com/puppetlabs/facter/pull/2020) ([smortex](https://github.com/smortex))
- Add FreeBSD dmi facts [#2021](https://github.com/puppetlabs/facter/pull/2021) ([smortex](https://github.com/smortex))
- (FACT-2727) add load averages for Solaris [#2023](https://github.com/puppetlabs/facter/pull/2023) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))

### Fixed

- (FACT-2714) Fix dhcp on solaris 10 [#2013](https://github.com/puppetlabs/facter/pull/2013) ([IrimieBogdan](https://github.com/IrimieBogdan))
- (FACT-2732) OracleLinux 7 and Scientific Linux 7 OS facts incorrect in Facter 4.0.30 [#2014](https://github.com/puppetlabs/facter/pull/2014) ([IrimieBogdan](https://github.com/IrimieBogdan))


## [4.0.33](https://github.com/puppetlabs/facter/tree/4.0.33) (2020-08-05)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.32...4.0.33)

### Added
- \(FACT-2040\) Added solaris memory resolver [\#1999](https://github.com/puppetlabs/facter/pull/1999) ([sebastian-miclea](https://github.com/sebastian-miclea))

### Fixed
- \(FACT-2735\) virtual not working on EXADATA baremetal [\#2004](https://github.com/puppetlabs/facter/pull/2004) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2736\) networking facts don't work on EXADATA baremetal [\#2008](https://github.com/puppetlabs/facter/pull/2008) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2724\) Confine blocks behave differently with Facter 4, causing spec tests to suddenly fail [\#2010](https://github.com/puppetlabs/facter/pull/2010) ([IrimieBogdan](https://github.com/IrimieBogdan))

## [4.0.32](https://github.com/puppetlabs/facter/tree/4.0.32) (2020-07-30)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.31...4.0.32)

### Added
- \(FACT-2717\) Block external facts [\#1998](https://github.com/puppetlabs/facter/pull/1998) ([florindragos](https://github.com/florindragos))

### Fixed
- \(FACT-2733\) Fix networking on Fedora 32 [\#2002](https://github.com/puppetlabs/facter/pull/2002) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2734\) Return nil codename if we cannot determine it from /etc/redhat-release [\#2003](https://github.com/puppetlabs/facter/pull/2003) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2699\) Detect augeas from gem if augparse is not available. [\#1993](https://github.com/puppetlabs/facter/pull/1993) ([IrimieBogdan](https://github.com/IrimieBogdan))


## [4.0.31](https://github.com/puppetlabs/facter/tree/4.0.31) (2020-07-29)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.30...4.0.31)

### Added
- \(FACT-2718\) Block custom facts [\#1996](https://github.com/puppetlabs/facter/pull/1996) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2230\) Add Aix memory facts [\#1994](https://github.com/puppetlabs/facter/pull/1994) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2220\) Add Aix disks fact [\#1987](https://github.com/puppetlabs/facter/pull/1987) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2708\) Add man pages [\#1984 ](https://github.com/puppetlabs/facter/pull/1984) ([florindragos](https://github.com/florindragos))

### Fixed
- \(FACT-2710\) Correctly display vmware info [\#1988](https://github.com/puppetlabs/facter/pull/1987) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2702\) Fix system_profiler legacy facts [\#1982](https://github.com/puppetlabs/facter/pull/1982) ([oanatmaria](https://github.com/oanatmaria))
- Handle Time and Symbol in executable facts [\#1977](https://github.com/puppetlabs/facter/pull/1977) ([gimmyxd](https://github.com/gimmyxd))

## [4.0.30](https://github.com/puppetlabs/facter/tree/4.0.30) (2020-07-15)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.29...4.0.30)

### Added
- \(FACT-2690\) Added Hyper-V fact for Linux [\#1968](https://github.com/puppetlabs/facter/pull/1968) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- \(FACT-2694\) Add linux openvz fact [\#1970](https://github.com/puppetlabs/facter/pull/1970) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2656\) Add solaris networking facts [\#1947](https://github.com/puppetlabs/facter/pull/1947) ([sebastian-miclea](https://github.com/sebastian-miclea))
- \(FACT-2689\) Add hypervisors docker fact [\#1950](https://github.com/puppetlabs/facter/pull/1950) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2683\) Added remaining legacy networking facts for OSX [\#1952](https://github.com/puppetlabs/facter/pull/1952) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- \(FACT-2692\) Add hypervisors lxc fact [\#1953](https://github.com/puppetlabs/facter/pull/1953) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2691\) Add kvm fact on linux [\#1955](https://github.com/puppetlabs/facter/pull/1955) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2697\) Add Xen fact [\#1957](https://github.com/puppetlabs/facter/pull/1957) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2695\) implementation for virtualbox hypervisor fact [\#1956](https://github.com/puppetlabs/facter/pull/1956) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- \(FACT-2693\) Add systemd_nspawn fact [\#1958](https://github.com/puppetlabs/facter/pull/1958) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2696\) Add vmware fact [\#1963](https://github.com/puppetlabs/facter/pull/1963) ([IrimieBogdan](https://github.com/IrimieBogdan))

### Fixed
- \(FACT-2673\) Fix mountpoints logic for osx [\#1971](https://github.com/puppetlabs/facter/pull/1971) ([oanatmaria](https://github.com/oanatmaria))
- \(maint\) Silent solaris_zones facts on FreeBSD [\#1954](https://github.com/puppetlabs/facter/pull/1954) ([smortex](https://github.com/smortex))

## [4.0.29](https://github.com/puppetlabs/facter/tree/4.0.29) (2020-07-01)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.28...4.0.29)

### Added
- \(FACT-2218\) virtual fact for OSX [\#1945](https://github.com/puppetlabs/facter/pull/1945) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2232\) Add Aix networking facts [\#1937](https://github.com/puppetlabs/facter/pull/1937) ([oanatmaria](https://github.com/oanatmaria))

### Fixed
- \(FACT-2676\) fix os identifier for opensuse-leap [\#1944](https://github.com/puppetlabs/facter/pull/1944) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- FACT-2679 Get DHCP for all interfaces on OSX [\#1940](https://github.com/puppetlabs/facter/pull/1940) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))

## [4.0.28](https://github.com/puppetlabs/facter/tree/4.0.28) (2020-06-25)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.27...4.0.28)

### Fixed
- \(maint\) Fix aio_agent_version on non AIO node [\#1938](https://github.com/puppetlabs/facter/pull/1938) ([smortex](https://github.com/smortex))

## [4.0.27](https://github.com/puppetlabs/facter/tree/4.0.27) (2020-06-24)

[Full Changelog](https://github.com/puppetlabs/facter/compare/4.0.26...4.0.27)

### Added
- \(FACT-2212\) Networking facts for OSX [\#1929](https://github.com/puppetlabs/facter/pull/1929) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- \(maint\) Add FreeBSD disks and partitions facts [\#553](https://github.com/puppetlabs/facter-ng/pull/553) ([smortex](https://github.com/smortex))
- \(FACT-2638\) Use puppet AIO VERSION file to specify AIO version [\#549](https://github.com/puppetlabs/facter-ng/pull/549) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2654\) Add ec2 facts for Windows [\#546](https://github.com/puppetlabs/facter-ng/pull/546) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2620\) Add EC2 facts for linux [\#544](https://github.com/puppetlabs/facter-ng/pull/544) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2619\) External facts cache [\#541](https://github.com/puppetlabs/facter-ng/pull/541) ([florindragos](https://github.com/florindragos))
- Add support for processors facts on \*BSD [\#489](https://github.com/puppetlabs/facter-ng/pull/489) ([smortex](https://github.com/smortex))

### Fixed
- \(FACT-2668\) Networking fact on linux should have logic for selecting IPs [\#1928](https://github.com/puppetlabs/facter/pull/1928) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2678\) Facter sometimes pollutes the calling processes environment (race condition) [\#1932](https://github.com/puppetlabs/facter/pull/1932) ([IrimieBogdan](https://github.com/IrimieBogdan))

## [4.0.26](https://github.com/puppetlabs/facter-ng/tree/4.0.26) (2020-06-11)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.25...4.0.26)

### Added

- \(FACT-2608\) Add is\_virtual fact [\#535](https://github.com/puppetlabs/facter-ng/pull/535) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2609\) Add lspci resolver [\#534](https://github.com/puppetlabs/facter-ng/pull/534) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2245\) Add xen resolver [\#532](https://github.com/puppetlabs/facter-ng/pull/532) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2607\) Add Openvz detector [\#531](https://github.com/puppetlabs/facter-ng/pull/531) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2600\) Run acceptance tests on Windows [\#519](https://github.com/puppetlabs/facter-ng/pull/519) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))

### Fixed

- \(FACT-2651\) Fix --list-cache-groups when there are multiple arguments before it [\#545](https://github.com/puppetlabs/facter-ng/pull/545) ([IrimieBogdan](https://github.com/IrimieBogdan))
- FACT-2650 Fix bug when loading external facts [\#543](https://github.com/puppetlabs/facter-ng/pull/543) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- Use proper encoding [\#539](https://github.com/puppetlabs/facter-ng/pull/539) ([faucct](https://github.com/faucct))
- \(FACT-2635\) Incorrect output for non existing fact [\#536](https://github.com/puppetlabs/facter-ng/pull/536) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.25](https://github.com/puppetlabs/facter-ng/tree/4.0.25) (2020-05-29)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.24...4.0.25)

### Fixed

- \(FACT-2636\) Set external as fact\_type for environment variable facts. [\#537](https://github.com/puppetlabs/facter-ng/pull/537) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.24](https://github.com/puppetlabs/facter-ng/tree/4.0.24) (2020-05-26)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.23...4.0.24)

### Added

- \(FACT-2605\) Add vmware resolver [\#525](https://github.com/puppetlabs/facter-ng/pull/525) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2604\) Add virt-what resolver [\#523](https://github.com/puppetlabs/facter-ng/pull/523) ([oanatmaria](https://github.com/oanatmaria))



## [4.0.23](https://github.com/puppetlabs/facter-ng/tree/4.0.23) (2020-05-22)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.22...4.0.23)

### Fixed

- \(FACT-2632\) Log error message if we encounter exceptions while loading custom facts files [\#528](https://github.com/puppetlabs/facter-ng/pull/528) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2631\) Trace is not working as expected [\#527](https://github.com/puppetlabs/facter-ng/pull/527) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.22](https://github.com/puppetlabs/facter-ng/tree/4.0.22) (2020-05-20)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.21...4.0.22)

### Added

- \(FACT-2603\) Detect virtual on GCE vms [\#521](https://github.com/puppetlabs/facter-ng/pull/521) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2602\) Add docker/Lxc resolver for Linux [\#520](https://github.com/puppetlabs/facter-ng/pull/520) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2615\) Add Solaris mountpoints fact [\#515](https://github.com/puppetlabs/facter-ng/pull/515) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2532\) Add Aix nim\_type fact [\#513](https://github.com/puppetlabs/facter-ng/pull/513) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2183\) Add Solaris's uptime legacy facts [\#511](https://github.com/puppetlabs/facter-ng/pull/511) ([oanatmaria](https://github.com/oanatmaria))

### Fixed

- \(FACT-2617\) Fix for tests/external\_facts/external\_fact\_stderr\_messages\_output\_to\_stderr.rb [\#522](https://github.com/puppetlabs/facter-ng/pull/522) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2523\) Fix for tests/external\_facts/non\_root\_users\_default\_external\_fact\_directory.rb [\#518](https://github.com/puppetlabs/facter-ng/pull/518) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2522\) Fix for tests/external\_facts/fact\_directory\_precedence.rb [\#517](https://github.com/puppetlabs/facter-ng/pull/517) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2521\) Fix for tests/external\_facts/external\_fact\_overrides\_custom\_fact\_with\_10000\_weight\_or\_less.rb [\#514](https://github.com/puppetlabs/facter-ng/pull/514) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2525\) Fix for tests/options/color.rb [\#512](https://github.com/puppetlabs/facter-ng/pull/512) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.21](https://github.com/puppetlabs/facter-ng/tree/4.0.21) (2020-05-13)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.20...4.0.21)

### Added

- \(FACT-2599\) Run GitHub Actions on Ubuntu 16 and Osx 10 [\#497](https://github.com/puppetlabs/facter-ng/pull/497) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- \(FACT-2247\) Add networking fact for linux [\#496](https://github.com/puppetlabs/facter-ng/pull/496) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2515\) Define custom fact groups in facter.conf [\#491](https://github.com/puppetlabs/facter-ng/pull/491) ([florindragos](https://github.com/florindragos))
- \(FACT-2557\) Add rake task for generating list of facts for specified OS [\#488](https://github.com/puppetlabs/facter-ng/pull/488) ([IrimieBogdan](https://github.com/IrimieBogdan))
- Add os.release facts on FreeBSD [\#485](https://github.com/puppetlabs/facter-ng/pull/485) ([smortex](https://github.com/smortex))
- \(FACT-2235\) Add Aix processors fact [\#483](https://github.com/puppetlabs/facter-ng/pull/483) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2569\) Run acceptance tests on Ubuntu GitHub actions [\#477](https://github.com/puppetlabs/facter-ng/pull/477) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- \(FACT-2553\) Quote special string in YAML format [\#471](https://github.com/puppetlabs/facter-ng/pull/471) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2517\) Open3 wrapper for executing system calls [\#469](https://github.com/puppetlabs/facter-ng/pull/469) ([oanatmaria](https://github.com/oanatmaria))

### Fixed

- \(FACT-2533\) Fix for tests/facts/partitions.rb [\#507](https://github.com/puppetlabs/facter-ng/pull/507) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2531\) Fix for tests/facts/validate\_file\_system\_size\_bytes.rb [\#500](https://github.com/puppetlabs/facter-ng/pull/500) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2582\) Date and Time in external YAML fact is not loaded [\#499](https://github.com/puppetlabs/facter-ng/pull/499) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2556\) Refactor existing facts to use the new OS hierarchy [\#486](https://github.com/puppetlabs/facter-ng/pull/486) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.20](https://github.com/puppetlabs/facter-ng/tree/4.0.20) (2020-05-06)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.19...4.0.20)

### Added

- Add \*BSD kernelversion and kernelmajversion facts [\#462](https://github.com/puppetlabs/facter-ng/pull/462) ([smortex](https://github.com/smortex))
- Fix os.family fact on \*BSD [\#461](https://github.com/puppetlabs/facter-ng/pull/461) ([smortex](https://github.com/smortex))
- Add support for \*BSD load averages [\#460](https://github.com/puppetlabs/facter-ng/pull/460) ([smortex](https://github.com/smortex))

### Fixed

- \(FACT-2590\) No facts are displayed on Redhat 5 and Centos6 [\#484](https://github.com/puppetlabs/facter-ng/pull/484) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2530\) Fix for tests/facts/os\_processors\_and\_kernel.rb [\#449](https://github.com/puppetlabs/facter-ng/pull/449) ([oanatmaria](https://github.com/oanatmaria))



## [4.0.19](https://github.com/puppetlabs/facter-ng/tree/4.0.19) (2020-04-29)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.18...4.0.19)

### Added

- \(FACT-2555\)Create OS hierarchy and mechanism for loading it [\#470](https://github.com/puppetlabs/facter-ng/pull/470) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2552\) Add Solaris processors facts [\#451](https://github.com/puppetlabs/facter-ng/pull/451) ([oanatmaria](https://github.com/oanatmaria))
- \(Fact 2486\) Add facts cache [\#430](https://github.com/puppetlabs/facter-ng/pull/430) ([florindragos](https://github.com/florindragos))

### Fixed

- \(FACT-2585\) Mountpoints fact returns ASCI-8BIT instead of UTF-8 in some cases [\#472](https://github.com/puppetlabs/facter-ng/pull/472) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2570\) Use Facter options to store custom and external facts [\#467](https://github.com/puppetlabs/facter-ng/pull/467) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2565\) Debian development versions causes fatal error when resolving os.release [\#466](https://github.com/puppetlabs/facter-ng/pull/466) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))



## [4.0.18](https://github.com/puppetlabs/facter-ng/tree/4.0.18) (2020-04-24)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.17...4.0.18)

### Added

- \(FACT-2564\) Add support for zpool\_featureflags and fix zpool\_version [\#443](https://github.com/puppetlabs/facter-ng/pull/443) ([smortex](https://github.com/smortex))

### Fixed

- \(FACT-2553\) remove double backslashes from windows path [\#456](https://github.com/puppetlabs/facter-ng/pull/456) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2559\) Fix Facter.debugging? call when Facter not fully loaded [\#455](https://github.com/puppetlabs/facter-ng/pull/455) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))



## [4.0.17](https://github.com/puppetlabs/facter-ng/tree/4.0.17) (2020-04-21)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.16...4.0.17)

### Fixed

- \(FACT-2562\) Correctly load custom and external fact directories [\#458](https://github.com/puppetlabs/facter-ng/pull/458) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.16](https://github.com/puppetlabs/facter-ng/tree/4.0.16) (2020-04-15)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.15...4.0.16)

### Added

- \(FACT-2233\) Add AIX partitons fact [\#433](https://github.com/puppetlabs/facter-ng/pull/433) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2330\) Add ssh fact for Windows OpenSSH feature [\#424](https://github.com/puppetlabs/facter-ng/pull/424) ([oanatmaria](https://github.com/oanatmaria))

### Fixed

- \(FACT-2528\) Fix for tests/facts/ssh\_key.rb [\#442](https://github.com/puppetlabs/facter-ng/pull/442) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2538\) Don't save core and legacy facts in collection if they have no value [\#441](https://github.com/puppetlabs/facter-ng/pull/441) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.15](https://github.com/puppetlabs/facter-ng/tree/4.0.15) (2020-04-08)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.14...4.0.15)

### Added

- \(FACT-2541\) Add TYPE for legacy facts [\#439](https://github.com/puppetlabs/facter-ng/pull/439) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2535\) Allow interpolation of Facter.fact\('fact\_name'\) [\#435](https://github.com/puppetlabs/facter-ng/pull/435) ([sebastian-miclea](https://github.com/sebastian-miclea))
- \(FACT-2477\) Collect facts from alternative sources [\#422](https://github.com/puppetlabs/facter-ng/pull/422) ([oanatmaria](https://github.com/oanatmaria))

### Fixed

- \(FACT-2513\) Updated how option aliases are displayed [\#434](https://github.com/puppetlabs/facter-ng/pull/434) ([sebastian-miclea](https://github.com/sebastian-miclea))
- \(FACT-2499\) Facts with aliases are resolved only once [\#429](https://github.com/puppetlabs/facter-ng/pull/429) ([IrimieBogdan](https://github.com/IrimieBogdan))



## [4.0.14](https://github.com/puppetlabs/facter-ng/tree/4.0.14) (2020-04-01)

[Full Changelog](https://github.com/puppetlabs/facter-ng/compare/4.0.13...4.0.14)

### Added

- \(FACT-2512\) Handle Raspbian as Debian [\#421](https://github.com/puppetlabs/facter-ng/pull/421) ([mlove-au](https://github.com/mlove-au))
- \(FACT-2231\) Add AIX mountpoints fact [\#398](https://github.com/puppetlabs/facter-ng/pull/398) ([oanatmaria](https://github.com/oanatmaria))
- \(FACT-2471\) Add Linux partitions fact [\#393](https://github.com/puppetlabs/facter-ng/pull/393) ([oanatmaria](https://github.com/oanatmaria))
- Debugger tool [\#391](https://github.com/puppetlabs/facter-ng/pull/391) ([sebastian-miclea](https://github.com/sebastian-miclea))
- \(FACT-2435\) Expose :expand as an option to execute command [\#342](https://github.com/puppetlabs/facter-ng/pull/342) ([florindragos](https://github.com/florindragos))

### Fixed

- \(FACT-2511\) Remove file logger [\#425](https://github.com/puppetlabs/facter-ng/pull/425) ([IrimieBogdan](https://github.com/IrimieBogdan))
- \(FACT-2498\) Internal fact loader should only load facts once [\#420](https://github.com/puppetlabs/facter-ng/pull/420) ([IrimieBogdan](https://github.com/IrimieBogdan))
- Avoid exceptions for zone facts on FreeBSD [\#412](https://github.com/puppetlabs/facter-ng/pull/412) ([smortex](https://github.com/smortex))
- \(FACT-2475\) Fix os.release on Debian [\#410](https://github.com/puppetlabs/facter-ng/pull/410) ([oanatmaria](https://github.com/oanatmaria))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*