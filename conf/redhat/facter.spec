%define sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')

Summary: Ruby module for collecting simple facts about a host operating system
Name: facter
Version: 1.1.4
Release: 2%{?dist}
License: GPL
Group: System Environment/Base
URL: http://reductivelabs.com/projects/facter
Source0: http://reductivelabs.com/downloads/facter/%{name}-%{version}.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
# It's not possible to build ruby noarch packages currently
# See bz184199
#BuildArchitectures: noarch

Requires: ruby >= 1.8.1
BuildRequires: ruby >= 1.8.1

%description 
Ruby module for collecting simple facts about a host Operating
system. Some of the facts are preconfigured, such as the hostname and the
operating system. Additional facts can be added through simple Ruby scripts

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT
DESTDIR=$RPM_BUILD_ROOT ruby install.rb --no-tests
chmod a-x $RPM_BUILD_ROOT%{sitelibdir}/*.rb

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_bindir}/facter
%{sitelibdir}/facter.rb
%doc CHANGELOG COPYING INSTALL LICENSE README


%changelog
* Mon Mar 13 2006 David Lutterkort <dlutter@redhat.com> - 1.1.4-2
- Commented out noarch; requires fix for bz184199

* Mon Mar  6 2006 David Lutterkort <dlutter@redhat.com> - 1.1.4-1
- Removed unused macros

* Mon Feb  6 2006 David Lutterkort <dlutter@redhat.com> - 1.1.1-2
- Fix BuildRoot. Add dist to release tag

* Wed Jan 11 2006 David Lutterkort <dlutter@redhat.com> - 1.1.1-1
- Initial build.
