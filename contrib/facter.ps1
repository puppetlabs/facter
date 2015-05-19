### Set variables from command line
# $arch => Choose 32 or 64-bit build
# $cores => Set the number of cores to use for parallel builds
# $buildSource => Choose whether to download pre-built libraries or build from source
param (
[int] $arch=64,
[int] $cores=2,
[bool] $buildSource=$FALSE,
[string] $facterRef='origin/master',
[string] $facterFork='git://github.com/puppetlabs/facter'
)

$ErrorActionPreference = 'Stop'

# Ensure TEMP directory is set and exists. Git.install can fail otherwise.
try {
    if (!(Test-Path $env:TEMP)) { throw }
} catch {
    $env:TEMP = Join-Path $env:SystemDrive 'temp'
    echo "TEMP not correct, setting to $env:TEMP"
}
if (!(Test-Path $env:TEMP)) {
    mkdir -Path $env:TEMP
    echo "TEMP dir $env:TEMP created"
}

if ($env:Path -eq $null) {
    echo "Path is null?"
}

# Starting from a base Windows Server 2008r2 or 2012r2 installation, install required tools, setup the PATH, and download and build software.
# This script can be run directly from the web using "iex ((new-object net.webclient).DownloadString('<url_to_raw>'))"

### Configuration
## Setup the working directory
$sourceDir=$pwd

echo $arch
echo $cores
echo $buildSource


$mingwVerNum = "4.8.3"
$mingwVerChoco = $mingwVerNum
$mingwThreads = "win32"
if ($arch -eq 64) {
  $mingwExceptions = "seh"
  $mingwArch = "x86_64"
} else {
  $mingwExceptions = "sjlj"
  $mingwArch = "i686"
}
$mingwVer = "${mingwArch}_mingw-w64_${mingwVerNum}_${mingwThreads}_${mingwExceptions}"

$boostVer = "boost_1_57_0"
$boostPkg = "${boostVer}-${mingwVer}"

$yamlCppVer = "yaml-cpp-0.5.1"
$yamlPkg = "${yamlCppVer}-${mingwVer}"

### Setup, build, and install
## Install Chocolatey, then use it to install required tools.
Function Install-Choco ($pkg, $ver, $opts = "") {
    echo "Installing $pkg $ver from https://www.myget.org/F/puppetlabs"
    try {
        choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts
    } catch {
        echo "Error: $_, trying again."
        choco install -y $pkg -version $ver -source https://www.myget.org/F/puppetlabs -debug $opts
    }
}

if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}
Install-Choco 7zip.commandline 9.20.0.20150210
Install-Choco cmake 3.1.0
Install-Choco git.install 1.9.5.20150320

# For MinGW, we expect specific project defaults
# - win32 threads, for Windows Server 2003 support
# - seh exceptions on 64-bit, to work around an obscure bug loading Ruby in Facter
# These are the defaults on our myget feed.
if ($arch -eq 64) {
  Install-Choco ruby 2.1.6
  Install-Choco mingw-w64 $mingwVerChoco
} else {
  Install-Choco ruby 2.1.6 @('-x86')
  Install-Choco mingw-w32 $mingwVerChoco @('-x86')
}
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
if ($arch -eq 32) {
  $env:PATH = "C:\tools\mingw32\bin;" + $env:PATH
}
$env:PATH += [Environment]::GetFolderPath('ProgramFilesX86') + "\Git\cmd"
echo $env:PATH
cd $sourceDir

## Download facter and setup build directories
git clone $facterFork facter
cd facter
git checkout $facterRef
git submodule update --init --recursive
mkdir -Force release
cd release
$buildDir=$pwd
$toolsDir="${sourceDir}\deps"
mkdir -Force $toolsDir
cd $toolsDir

if ($buildSource) {
  ## Download, build, and install Boost
  (New-Object net.webclient).DownloadFile("http://downloads.sourceforge.net/boost/$boostVer.7z", "$toolsDir\$boostVer.7z")
  & 7za x "${boostVer}.7z" | FIND /V "ing "
  cd $boostVer

  .\bootstrap mingw
  $args = @(
    'toolset=gcc',
    "--build-type=minimal",
    "install",
    "--with-program_options",
    "--with-system",
    "--with-filesystem",
    "--with-date_time",
    "--with-thread",
    "--with-regex",
    "--with-log",
    "--with-locale",
    "--with-chrono",
    "--prefix=`"$toolsDir\$boostPkg`"",
    "boost.locale.iconv=off"
    "-j$cores"
  )
  .\b2 $args
  cd $toolsDir

  ## Download, build, and install yaml-cpp
  (New-Object net.webclient).DownloadFile("https://yaml-cpp.googlecode.com/files/${yamlCppVer}.tar.gz", "$toolsDir\${yamlCppVer}.tar.gz")
  & 7za x "${yamlCppVer}.tar.gz"
  & 7za x "${yamlCppVer}.tar" | FIND /V "ing "
  cd $yamlCppVer
  mkdir build
  cd build

  $args = @(
    '-G',
    "MinGW Makefiles",
    "-DBOOST_ROOT=`"$toolsDir\$boostPkg`"",
    "-DCMAKE_INSTALL_PREFIX=`"$toolsDir\$yamlPkg`"",
    ".."
  )
  cmake $args
  mingw32-make install -j $cores
} else {
  ## Download and unpack Boost from a pre-built package in S3
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${boostPkg}.7z", "$toolsDir\${boostPkg}.7z")
  & 7za x "${boostPkg}.7z" | FIND /V "ing "

  ## Download and unpack yaml-cpp from a pre-built package in S3
  (New-Object net.webclient).DownloadFile("https://s3.amazonaws.com/kylo-pl-bucket/${yamlPkg}.7z", "$toolsDir\${yamlPkg}.7z")
  & 7za x "${yamlPkg}.7z" | FIND /V "ing "
}

## Build Facter
cd $buildDir
$args = @(
  '-G',
  "MinGW Makefiles",
  "-DBOOST_ROOT=`"$toolsDir\$boostPkg`"",
  "-DBOOST_STATIC=ON",
  "-DYAMLCPP_ROOT=`"$toolsDir\$yamlPkg`"",
  ".."
)
cmake $args
mingw32-make -j $cores

## Write out the version that was just built.
git describe --long | Out-File -FilePath 'bin/VERSION' -Encoding ASCII -Force

## Test the results.
ctest -V 2>&1 | c++filt
