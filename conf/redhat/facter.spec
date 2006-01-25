%define rb_ver %(ruby -rrbconfig -e 'puts Config::CONFIG["ruby_version"]')
%define rubylibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')
%define _pbuild %{_builddir}/%{name}-%{version}

Summary: Facter collects Operating system facts.
Name: facter
Version: 1.1.1
Release: 1
License: GPL
Group: System Environment/Base
URL: http://reductivelabs.com/projects/facter
Vendor: Reductive Labs
Source0: %{name}-%{version}.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArchitectures: noarch

Requires: ruby >= 1.8.1
BuildRequires: ruby >= 1.8.1

%description
Facter is a module for collecting simple facts about a host Operating system.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT
DESTDIR=$RPM_BUILD_ROOT ruby install.rb --no-tests

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{_bindir}/facter
%{rubylibdir}/facter.rb
%doc CHANGELOG COPYING INSTALL LICENSE README


%changelog
* Wed Jan 11 2006 David Lutterkort <dlutter@redhat.com> - 
- Initial build.

