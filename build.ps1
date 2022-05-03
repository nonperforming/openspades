# Intended for AppVeyor CI
# You may try to use it to build locally,
# but your milage may vary.

#$ErrorActionPreference = 'Stop';
#-- Performing Test HAS_MSGHDR_FLAGS
#-- Performing Test HAS_MSGHDR_FLAGS - Failed
#-- Check size of socklen_t
#-- Check size of socklen_t - failed
#The running command stopped because the preference variable "ErrorActionPreference" or common parameter is set to Stop: CMake Warning (dev) in Resources/CMakeLists.txt:

Write-Host "Build start..."

#region Windows
function BuildWindows
{
  Write-Host "Building for Windows..."
  
  # Based off of https://github.com/Conticop/OpenSpades-assets/blob/main/build-openspades.ps1
  
  Write-Host "Setting variables"
  $RepoRoot = "" + (Get-Location)
  Write-Host Repository root: $RepoRoot

  Write-Host "Installing dependencies using VCPkg"
  vcpkg/bootstrap-vcpkg.bat -disableMetrics
  vcpkg/vcpkg install "@vcpkg_x86-windows.txt"

  Write-Host "Configuring build using CMake"
  try { cmake -A Win32 -D "CMAKE_BUILD_TYPE=MinSizeRel" -D "CMAKE_TOOLCHAIN_FILE=$RepoRoot/vcpkg/scripts/buildsystems/vcpkg.cmake" -D "VCPKG_TARGET_TRIPLET=x86-windows-static" "-S$RepoRoot" "-B$RepoRoot/build" }
  catch { throw "CMake failed" }
  
  Write-Host "Building OpenSpades+"
  try { cmake --build "$RepoRoot/build" --config MinSizeRel --parallel 16 }
  catch { throw "Build failed" } 
  
  Write-Host "Zipping binary"
  7z a Windows.zip build/bin/MinSizeRel -r
}
#endregion

#region Linux
function BuildLinux
{
  Write-Host "Building for GNU/Linux..."
 
  Write-Host "Updating packages and installing dependencies using apt-get"
  sudo apt-get update
  sudo apt-get install ninja-build pkg-config libglew-dev libcurl3-openssl-dev libsdl2-dev libsdl2-image-dev libalut-dev xdg-utils libfreetype6-dev libopus-dev libopusfile-dev cmake imagemagick libjpeg-dev libxinerama-dev libxft-dev -y
  sudo apt-get upgrade
  
  Write-Host "Creating build directory"
  mkdir build
  Push-Location build
  
  Write-Host "Configuring build using CMake"
  try { cmake .. -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel}
  catch { throw "CMake failed" }
  
  Write-Host "Building using Ninja"
  try { make -j 16 }
  catch { throw "Build failed" }
  
  Write-Host "Zipping binary"
  7z a Linux.zip bin -r
  Write-Host "Zipping resources"
  7z a Resources.zip Resources -r
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
}
#endregion

#region Pick the correct build script to run
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
  # Unknown OS
  throw "Unknown OS - cannot continue"
}
#endregion

Write-Host "Build success"
