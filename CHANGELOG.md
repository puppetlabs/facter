

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
