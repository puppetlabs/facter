

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
