#!/bin/bash
#
# Script to build an "old style" not flat pkg out of the facter repository.
#
# Author: Nigel Kersten (nigelk@google.com)
#
# Last Updated: 2008-07-31
#
# Copyright 2008 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License


INSTALLRB="install.rb"
BINDIR="/usr/bin"
SITELIBDIR="/usr/lib/ruby/site_ruby/1.8"
PACKAGEMAKER="/Developer/usr/bin/packagemaker"
PROTO_PLIST="PackageInfo.plist"
PREFLIGHT="preflight"


function find_installer() {
  # we walk up three directories to make this executable from the root,
  # root/conf or root/conf/osx
  if [ -f "./${INSTALLRB}" ]; then
    installer="$(pwd)/${INSTALLRB}"
  elif [ -f "../${INSTALLRB}" ]; then
    installer="$(pwd)/../${INSTALLRB}"
  elif [ -f "../../${INSTALLRB}" ]; then
    installer="$(pwd)/../../${INSTALLRB}"
  else
    installer=""
  fi
}

function find_facter_root() {
  facter_root=$(dirname "${installer}")
}

function install_facter() {
  echo "Installing Facter to ${pkgroot}"
  cd "$facter_root"
  ./"${INSTALLRB}" --destdir="${pkgroot}" --bindir="${BINDIR}" --sitelibdir="${SITELIBDIR}"
  chown -R root:admin "${pkgroot}"
}

function install_docs() {
  echo "Installing docs to ${pkgroot}"
  docdir="${pkgroot}/usr/share/doc/facter" 
  mkdir -p "${docdir}"
  for docfile in ChangeLog COPYING LICENSE README README.rst TODO; do
    install -m 0644 "${facter_root}/${docfile}" "${docdir}"
  done
  chown -R root:wheel "${docdir}"
  chmod 0755 "${docdir}"
}

function get_facter_version() {
  facter_version=$(RUBYLIB="${pkgroot}/${SITELIBDIR}:${RUBYLIB}" ruby -e "require 'facter'; puts Facter.version")
}

function prepare_package() {
  # As we can't specify to follow symlinks from the command line, we have
  # to go through the hassle of creating an Info.plist file for packagemaker
  # to look at for package creation and substitue the version strings out.
  # Major/Minor versions can only be integers, so we have "1" and "50" for
  # facter version 1.5
  # Note too that for 10.5 compatibility this Info.plist *must* be set to
  # follow symlinks.
  VER1=$(echo ${facter_version} | awk -F "." '{print $1}')
  VER2=$(echo ${facter_version} | awk -F "." '{print $2}')
  VER3=$(echo ${facter_version} | awk -F "." '{print $3}')
  major_version="${VER1}"
  minor_version="${VER2}${VER3}"
  cp "${facter_root}/conf/osx/${PROTO_PLIST}" "${pkgtemp}"
  sed -i '' "s/{SHORTVERSION}/${facter_version}/g" "${pkgtemp}/${PROTO_PLIST}"
  sed -i '' "s/{MAJORVERSION}/${major_version}/g" "${pkgtemp}/${PROTO_PLIST}"
  sed -i '' "s/{MINORVERSION}/${minor_version}/g" "${pkgtemp}/${PROTO_PLIST}"

  # We need to create a preflight script to remove traces of previous
  # facter installs due to limitations in Apple's pkg format.
  mkdir "${pkgtemp}/scripts"
  cp "${facter_root}/conf/osx/${PREFLIGHT}" "${pkgtemp}/scripts"

  # substitute in the sitelibdir specified above on the assumption that this
  # is where any previous facter install exists that should be cleaned out.
  sed -i '' "s|{SITELIBDIR}|${SITELIBDIR}|g" "${pkgtemp}/scripts/${PREFLIGHT}"
  chmod 0755 "${pkgtemp}/scripts/${PREFLIGHT}"
}

function create_package() {
  rm -fr "$(pwd)/facter-${facter_version}.pkg"
  echo "Building package"
  echo "Note that packagemaker is reknowned for spurious errors. Don't panic."
  "${PACKAGEMAKER}" --root "${pkgroot}" \
                    --info "${pkgtemp}/${PROTO_PLIST}" \
                    --scripts ${pkgtemp}/scripts \
                    --out "$(pwd)/facter-${facter_version}.pkg"
  if [ $? -ne 0 ]; then
    echo "There was a problem building the package."
    cleanup_and_exit 1
    exit 1
  else
    echo "The package has been built at:"
    echo "$(pwd)/facter-${facter_version}.pkg"
  fi
}

function cleanup_and_exit() {
  if [ -d "${pkgroot}" ]; then
    rm -fr "${pkgroot}"
  fi
  if [ -d "${pkgtemp}" ]; then
    rm -fr "${pkgtemp}"
  fi
  exit $1
}

# Program entry point
function main() {

  if [ $(whoami) != "root" ]; then
    echo "This script needs to be run as root via su or sudo."
    cleanup_and_exit 1
  fi

  find_installer

  if [ ! "${installer}" ]; then
    echo "Unable to find ${INSTALLRB}"
    cleanup_and_exit 1
  fi

  find_facter_root

  if [ ! "${facter_root}" ]; then
    echo "Unable to find facter repository root."
    cleanup_and_exit 1
  fi

  pkgroot=$(mktemp -d -t facterpkg)

  if [ ! "${pkgroot}" ]; then
    echo "Unable to create temporary package root."
    cleanup_and_exit 1
  fi

  pkgtemp=$(mktemp -d -t factertmp)

  if [ ! "${pkgtemp}" ]; then
    echo "Unable to create temporary package root."
    cleanup_and_exit 1
  fi

  install_facter
  get_facter_version

  if [ ! "${facter_version}" ]; then
    echo "Unable to retrieve facter version"
    cleanup_and_exit 1
  fi

  prepare_package
  create_package

  cleanup_and_exit 0
}

main "$@"
