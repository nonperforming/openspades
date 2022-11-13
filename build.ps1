# Intended for AppVeyor CI
# You may try to use it to build locally,
# but your milage may vary.

# TODO: Need help with this
# Parameters:
# Defaults to OpenSpades if no argument is given
# O - OpenSpades
# P - OpenSpades+
# N - NucetoSpades
# Z - ZeroSpades
# C - Custom (provide Git url)
# L - Local

#region AppVeyor CI Failure
#$ErrorActionPreference = 'Stop'
#-- Performing Test HAS_MSGHDR_FLAGS
#-- Performing Test HAS_MSGHDR_FLAGS - Failed
#-- Check size of socklen_t
#-- Check size of socklen_t - failed
#The running command stopped because the preference variable "ErrorActionPreference" or common parameter is set to Stop: CMake Warning (dev) in Resources/CMakeLists.txt:
#
#Note: does not actually affect build, probably
#endregion

#region Windows
function BuildWindows
{
  # Based off of https://github.com/Conticop/OpenSpades-assets/blob/main/build-openspades.ps1
  
  Write-Host "Building for Windows..."
  $RepoRoot = "" + (Get-Location)

  try
  {
    Write-Host "Installing dependencies using VCPkg"
    vcpkg/bootstrap-vcpkg.bat -disableMetrics
    vcpkg/vcpkg install "@vcpkg_x86-windows.txt"
  }
  catch
  {
    ErrorDependencies
  }

  Write-Host "Configuring build using CMake"
  try { cmake -A Win32 -D "CMAKE_BUILD_TYPE=MinSizeRel" -D "CMAKE_TOOLCHAIN_FILE=$RepoRoot/vcpkg/scripts/buildsystems/vcpkg.cmake" -D "VCPKG_TARGET_TRIPLET=x86-windows-static" "-S$RepoRoot" "-B$RepoRoot/build" }
  catch { ErrorCMake }
  
  Write-Host "Building $OpenSpadesFlavorName"
  try { cmake --build "$RepoRoot/build" --config MinSizeRel --parallel 16 }
  catch { throw ErrorBuild } 
  
  Write-Host "Zipping binary"
  7z a Windows.zip build/bin/MinSizeRel -r
  
  BuildSuccess
}
#endregion



#region Linux check distro
function BuildLinux
{
  Write-Host "Building for GNU/Linux..."
  
  $Distro = lsb_release -i
  $Distro = $Distro.substring(16)
  
  switch ($Distro)
  {
    "Ubuntu" { BuildUbuntu; break}
	  "Debian" { BuildDebian; break}
	  "Arch" { BuildArch; break}	
	  "Manjaro" { BuildArch; break}
	  default { ErrorUnknownDistro; break}
  }
}
#endregion

#region Debian
function BuildDebian
{
  
}
#endregion

#region Ubuntu
function BuildUbuntu
{
  Write-Host "Building for Ubuntu..."
  
  Write-Host "Updating packages and installing dependencies using apt-get"
  try
  {
    sudo apt-get update
    sudo apt-get install ninja-build pkg-config libglew-dev libcurl3-openssl-dev libsdl2-dev libsdl2-image-dev libalut-dev xdg-utils libfreetype6-dev libopus-dev libopusfile-dev cmake imagemagick libjpeg-dev libxinerama-dev libxft-dev -y
    sudo apt-get upgrade -y
  }
  catch
  {
    Write-Host "Installing and updating dependencies failed"
	ErrorDependencies
  }
  
  Write-Host "Creating build directory"
  mkdir build
  Push-Location build
  
  Write-Host "Configuring build using CMake"
  try { cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-O2" }
  catch { ErrorCMake }
  
  Write-Host "Building using Ninja"
  try { ninja }
  catch { ErrorBuild }
  
  Write-Host "Zipping binary"
  7z a Linux.zip bin -r
  Write-Host "Zipping resources"
  7z a Resources.zip Resources -r
  
  BuildSuccess
}
#endregion

#region Arch/Manjaro
function BuildArch
{
  
}
#endregion



#region Mac OS
function BuildMacOS
{
  Write-Host "Building for MacOS..."
  
  Write-Host "Setting variable"
  $RepoRoot = "" + (Get-Location)
  
  Write-Host "Installing dependencies using Homebrew and VCPkg"
  brew install ninja wget
  vcpkg/bootstrap-vcpkg.sh -disableMetrics
  vcpkg/vcpkg install "@vcpkg_x86_64-darwin.txt"
  
  Write-Host "Configuring using CMake"
  try { cmake -G Ninja .. -D CMAKE_BUILD_TYPE=MinSizeRel -D CMAKE_OSX_ARCHITECTURES=x86_64 -D CMAKE_TOOLCHAIN_FILE=../vcpkg/scripts/buildsystems/vcpkg.cmake -D VCPKG_TARGET_TRIPLET=x64-osx "-S$RepoRoot" "-B$RepoRoot/build" }
  catch { throw "CMake failed" }
  
  Write-Host "Building using Ninja"
  Push-Location build
  try { ninja }
  catch { throw "Build failed" }
  
  Write-Host "Zipping binary"
  7z a MacOS.zip bin/OpenSpades.app -r
  
  BuildSuccess
}
#endregion



#region Success
function BuildSuccess
{
  Write-Host "Build finished"
  exit 0
}
#endregion

#region Errors
function ErrorDependencies
{
  throw "Failed updating or installing dependencies"
  exit 417
}

function ErrorUnknown
{
  throw "Unknown OS - cannot continue"
  exit 404
}

function ErrorUnknownDistro
{
  throw "Unknown GNU/Linux Distro ($Distro) - cannot continue"
  exit 404
}

function ErrorCMake
{
  throw "Error generating build files with CMake"
  exit 400
}

function ErrorBuild
{
  throw "Error building"
  exit 400
}
#endregion

#region Warnings
function WarningPullFailed
{
  #TODO: throw or write-error
  #or write-host???????
  #how does powershell work anyways????
  Write-Host "Failed pulling latest changes from Git repository\nProceeding anyways"
}
#endregion


#region Pick the correct build script to run
# TODO: How does this work? Help needed
#param
#(
#  [Parameter()]
#  [String] $OpenSpadesFlavor, 
#  [Parameter()]
#  [String] $URL,
#  [Parameter()]
#  [String] $DirectoryName
#)
#
#$OpenSpadesFlavorName
#
#switch ( $OpenSpadesFlavor )
#{
#  "C" { Write-Host "Building OpenSpades (custom)"; $OpenSpadesFlavorName = "Custom"; break;}
#  "O" { Write-Host "Building OpenSpades"; $URL = "https://github.com/yvt/openspades.git"; $OpenSpadesFlavorName = "OpenSpades"; $DirectoryName = "OpenSpades"; break;}
#  "P" { Write-Host "Building OpenSpades+"; $URL = "https://github.com/nonperforming/openspadesplus.git"; $OpenSpadesFlavorName = "OpenSpadesPlus"; $DirectoryName = "OpenSpadesPlus"; break;}
#}
#
#Write-Host "Cloning/pulling changes from Git repository [$URL] - ($OpenSpadesFlavorName)"
#
#if (Test-Path "$DirectoryName")
#{
#  Write-Host "Repository already exists on drive!"
#  
#  Push-Location $DirectoryName
#  
#  try
#  {
#    git pull
#  }
#  catch
#  {
#    WarningPullFailed
#  }
#
#}
#else
#{
#  Write-Host "Repository does not exist on drive! Cloning repository..."
#  
#  git clone $URL $DirectoryName;
#  Push-Location $DirectoryName
#}
#
if ($isWindows)
{
  BuildWindows
}
elseif ($isLinux)
{
  BuildLinux
}
elseif ($isMacOS)
{
  BuildMacOS
}
else
{
  ErrorUnknown
}
#endregion
