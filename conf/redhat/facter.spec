%{!?ruby_sitelibdir: %define ruby_sitelibdir %(ruby -rrbconfig -e 'puts Object.const_get(defined?(RbConfig) ? :RbConfig : :Config)::CONFIG["sitelibdir"]')}

Summary: Ruby module for collecting simple facts about a host operating system
Name: facter
Version: 2.0.0
#Release: 1%{?dist}
Release: 0.1rc4%{?dist}
License: Apache 2.0
Group: System Environment/Base
URL: http://www.puppetlabs.com/puppet/related-projects/%{name}
Source0: http://puppetlabs.com/downloads/%{name}/%{name}-%{version}rc4.tar.gz
#Source0: http://puppetlabs.com/downloads/%{name}/%{name}-%{version}.tar.gz
Source1: http://puppetlabs.com/downloads/%{name}/%{name}-%{version}rc4.tar.gz.asc
#Source1: http://puppetlabs.com/downloads/%{name}/%{name}-%{version}.tar.gz.asc

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires: ruby >= 1.8.5
Requires: which
# dmidecode and pciutils are not available on all arches
%ifarch %ix86 x86_64 ia64
Requires: dmidecode
Requires: pciutils
%endif
Requires: ruby(abi) = 1.8
BuildRequires: ruby >= 1.8.5

%description
Ruby module for collecting simple facts about a host Operating
system. Some of the facts are preconfigured, such as the hostname and the
operating system. Additional facts can be added through simple Ruby scripts

%prep
#%setup -q  -n %{name}-%{version}
%setup -q  -n %{name}-%{version}rc4

%build

%install
rm -rf %{buildroot}
ruby install.rb --destdir=%{buildroot} --quick --no-rdoc

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_bindir}/facter
%{ruby_sitelibdir}/facter.rb
%{ruby_sitelibdir}/facter
%doc CHANGELOG INSTALL LICENSE README.md


%changelog
* Thu May 24 2012 Moses Mendoza <moses@puppetlabs.com> - 2.0.0-0.1rc4
- Update for 2.0.0rc4 release

* Tue May 22 2012 Moses Mendoza <moses@puppetlabs.com> - 2.0.0-0.1rc3
- Update for 2.0.0rc3 release

* Thu May 17 2012 Moses Mendoza <moses@puppetlabs.com> - 2.0.0-0.1rc2
- Update for 2.0.0rc2 release

* Tue May 15 2012 Matthaus Litteken <matthaus@puppetlabs.com> - 2.0.0-0.1rc1
- Facter 2.0.0rc1 release

* Thu May 10 2012 Matthaus Litteken <matthaus@puppetlabs.com> - 1.6.9-0.1rc1
- Update for 1.6.9rc1

* Mon Apr 30 2012 Moses Mendoza <moses@puppetlabs.com> - 1.6.8-1
- Update for 1.6.8, spec for arch-specific build, req ruby 1.8.5

* Thu Feb 23 2012 Michael Stahnke <stahnma@puppetlabs.com> - 1.6.6-1
- Update for 1.6.6

* Wed Jan 25 2012 Matthaus Litteken <matthaus@puppetlabs.com> - 1.6.5-1
- Update to 1.6.5

* Wed Nov 30 2011 Matthaus Litteken <matthaus@puppetlabs.com> - 1.6.4-0.1rc1
- 1.6.4 rc1

* Mon Oct 31 2011 Michael Stahnke <stahnma@puppetlabs.com> - 1.6.3-0.1rc1
- 1.6.3 rc1

* Mon Oct 10 2011 Michael Stahnke <stahnma@puppetlabs.com> -  1.6.2-1
- Update to 1.6.2

* Mon Oct 03 2011 Michael Stahnke <stahnma@puppetlabs.com> -  1.6.2-0.1rc1
- Updates for 1.6.2-0.1rc1

* Thu Jun 23 2011 Michael Stahnke <stahnma@puppetlabs.com> - 1.6.0-1
- Update to 1.6.0

* Sat Aug 28 2010 Todd Zullinger <tmz@pobox.com> - 1.5.8-1
- Update to 1.5.8

* Fri Sep 25 2009 Todd Zullinger <tmz@pobox.com> - 1.5.7-1
- Update to 1.5.7
- Update #508037 patch from upstream ticket

* Wed Aug 12 2009 Jeroen van Meeuwen <j.van.meeuwen@ogd.nl> - 1.5.5-3
- Fix #508037 or upstream #2355

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.5-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Fri May 22 2009 Todd Zullinger <tmz@pobox.com> - 1.5.5-1
- Update to 1.5.5
- Drop upstreamed libperms patch

* Sat Feb 28 2009 Todd Zullinger <tmz@pobox.com> - 1.5.4-1
- New version
- Use upstream install script

* Tue Feb 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Tue Sep 09 2008 Todd Zullinger <tmz@pobox.com> - 1.5.2-1
- New version
- Simplify spec file checking for Fedora and RHEL versions

* Mon Sep  8 2008 David Lutterkort <dlutter@redhat.com> - 1.5.1-1
- New version

* Thu Jul 17 2008 David Lutterkort <dlutter@redhat.com> - 1.5.0-3
- Change 'mkdir' in install to 'mkdir -p'

* Thu Jul 17 2008 David Lutterkort <dlutter@redhat.com> - 1.5.0-2
- Remove files that were listed twice in files section

* Mon May 19 2008 James Turnbull <james@lovedthanlosty.net> - 1.5.0-1
- New version
- Added util and plist files

* Mon Sep 24 2007 David Lutterkort <dlutter@redhat.com> - 1.3.8-1
- Update license tag
- Copy all of lib/ into ruby_sitelibdir

* Thu Mar 29 2007 David Lutterkort <dlutter@redhat.com> - 1.3.7-1
- New version

* Fri Jan 19 2007 David Lutterkort <dlutter@redhat.com> - 1.3.6-1
- New version

* Thu Jan 18 2007 David Lutterkort <dlutter@redhat.com> - 1.3.5-3
- require which; facter is very unhappy without it

* Mon Nov 20 2006 David Lutterkort <dlutter@redhat.com> - 1.3.5-2
- Make require ruby(abi) and buildarch: noarch conditional for fedora 5 or
  later to allow building on older fedora releases

* Tue Oct 10 2006 David Lutterkort <dlutter@redhat.com> - 1.3.5-1
- New version

* Tue Sep 26 2006 David Lutterkort <dlutter@redhat.com> - 1.3.4-1
- New version

* Wed Sep 13 2006 David Lutterkort <dlutter@redhat.com> - 1.3.3-2
- Rebuilt for FC6

* Wed Jun 28 2006 David Lutterkort <dlutter@redhat.com> - 1.3.3-1
- Rebuilt

* Fri Jun 19 2006 Luke Kanies <luke@madstop.com> - 1.3.0-1
- Fixed spec file to work again with the extra memory and processor files.
- Require ruby(abi). Build as noarch

* Fri Jun 9 2006 Luke Kanies <luke@madstop.com> - 1.3.0-1
- Added memory.rb and processor.rb

* Mon Apr 17 2006 David Lutterkort <dlutter@redhat.com> - 1.1.4-4
- Rebuilt with changed upstream tarball

* Tue Mar 21 2006 David Lutterkort <dlutter@redhat.com> - 1.1.4-3
- Do not rely on install.rb, it will be deleted upstream

* Mon Mar 13 2006 David Lutterkort <dlutter@redhat.com> - 1.1.4-2
- Commented out noarch; requires fix for bz184199

* Mon Mar  6 2006 David Lutterkort <dlutter@redhat.com> - 1.1.4-1
- Removed unused macros

* Mon Feb  6 2006 David Lutterkort <dlutter@redhat.com> - 1.1.1-2
- Fix BuildRoot. Add dist to release tag

* Wed Jan 11 2006 David Lutterkort <dlutter@redhat.com> - 1.1.1-1
- Initial build.
