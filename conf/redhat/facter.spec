%{!?ruby_sitelibdir: %define ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}

%define has_ruby_abi 0%{?fedora:%fedora} >= 5 || 0%{?rhel:%rhel} >= 5
%define has_ruby_noarch %has_ruby_abi

Summary: Ruby module for collecting simple facts about a host operating system
Name: facter
Version: 1.3.5
Release: 2%{?dist}
License: GPL
Group: System Environment/Base
URL: http://reductivelabs.com/projects/facter
Source0: http://reductivelabs.com/downloads/facter/%{name}-%{version}.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
%if %has_ruby_noarch
BuildArchitectures: noarch
%endif

Requires: ruby >= 1.8.1
%if %has_ruby_abi
Requires: ruby(abi) = 1.8
%endif
BuildRequires: ruby >= 1.8.1

%description 
Ruby module for collecting simple facts about a host Operating
system. Some of the facts are preconfigured, such as the hostname and the
operating system. Additional facts can be added through simple Ruby scripts

%prep
%setup -q

%build
sed -i -e 's@^#!.*$@#! /usr/bin/ruby@' bin/facter

%install
rm -rf %{buildroot}
mkdir %{buildroot}

%{__install} -d -m0755 %{buildroot}%{ruby_sitelibdir}
%{__install} -d -m0755 %{buildroot}%{ruby_sitelibdir}/facter
%{__install} -d -m0755 %{buildroot}%{_bindir}
%{__install} -d -m0755 %{buildroot}%{_docdir}/%{name}-%{version}

%{__install} -p -m0644 lib/*.rb %{buildroot}%{ruby_sitelibdir}
%{__install} -p -m0644 lib/facter/*.rb %{buildroot}%{ruby_sitelibdir}/facter
%{__install} -p -m0755 bin/facter %{buildroot}%{_bindir}

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_bindir}/facter
%{ruby_sitelibdir}/facter.rb
%{ruby_sitelibdir}/facter
%doc CHANGELOG COPYING INSTALL LICENSE README


%changelog
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
