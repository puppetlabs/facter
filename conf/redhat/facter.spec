%define rubylibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')
%define _pbuild %{_builddir}/%{name}-%{version}

Summary: A fact-collection library
Name: facter
Version: 1.1.1
Release: 1
License: GPL
Group: System Environment/Base

URL: http://reductivelabs.com/projects/facter/
Source: http://reductivelabs.com/downloads/facter/%{name}-%{version}.tgz

Vendor: Reductive Labs
Packager: Duane Griffin <d.griffin@psenterprise.com>

Requires: ruby >= 1.8.1
Requires: facter >= 1.1
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArchitectures: noarch

%description
Facter provides a cross-platform library for collecting simple facts about
about your systems and making them available via either the command line or
a Ruby library.  You can create multiple ways to retrieve a given fact and it
will return the first valid value it finds.

%prep
%setup -q

%install
%{__rm} -rf %{buildroot}
%{__install} -d -m0755 %{buildroot}%{_bindir}
%{__install} -d -m0755 %{buildroot}%{rubylibdir}
%{__install} -d -m0755 %{buildroot}%{_docdir}/%{name}-%{version}
%{__install} -Dp -m0755 %{_pbuild}/bin/* %{buildroot}%{_bindir}/
%{__install} -Dp -m0644 %{_pbuild}/lib/facter.rb %{buildroot}%{rubylibdir}/facter.rb

%files
%defattr(-, root, root, 0755)
%{_sbindir}/facter
%{rubylibdir}/*
%{_localstatedir}/facter
%config %{_initrddir}/facter
%doc CHANGELOG COPYING LICENSE README TODO

%clean
%{__rm} -rf %{buildroot}

%changelog
* Tue Jan 17 2006 Luke Kanies <luke@reductivelabs.com> - 1.1.1
- Created
