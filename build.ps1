# Intended for AppVeyor CI
# You may try to use it to build locally,
# but your milage may vary.

#$ErrorActionPreference = 'Stop';
#-- Performing Test HAS_MSGHDR_FLAGS
#-- Performing Test HAS_MSGHDR_FLAGS - Failed
#-- Check size of socklen_t
#-- Check size of socklen_t - failed
#The running command stopped because the preference variable "ErrorActionPreference" or common parameter is set to Stop: CMake Warning (dev) in Resources/CMakeLists.txt:


Write-Host Build start...

if ($isWindows)
{
  # Windows 10?
  
  Write-Host Building for Windows...
  
  # Based off of https://github.com/Conticop/OpenSpades-assets/blob/main/build-openspades.ps1
  
  $RepoRoot = "" + (Get-Location)
  Write-Host Repository root: $RepoRoot

  vcpkg/bootstrap-vcpkg.bat -disableMetrics

  vcpkg/vcpkg install "@vcpkg_x86-windows.txt"

  cmake -A Win32 -D "CMAKE_BUILD_TYPE=MinSizeRel" -D "CMAKE_TOOLCHAIN_FILE=$RepoRoot/vcpkg/scripts/buildsystems/vcpkg.cmake" -D "VCPKG_TARGET_TRIPLET=x86-windows-static" "-S$RepoRoot" "-B$RepoRoot/build"

  cmake --build "$RepoRoot/build" --config MinSizeRel --parallel 8
}
elseif ($isLinux)
{
  # Linux
  
  Write-Host Building for GNU/Linux...
 
  sudo apt-get install pkg-config libglew-dev libcurl3-openssl-dev libsdl2-dev libsdl2-image-dev libalut-dev xdg-utils libfreetype6-dev libopus-dev libopusfile-dev cmake imagemagick libjpeg-dev libxinerama-dev libxft-dev -y
  
  mkdir build
  cd build
  
  cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel
  make -j 16
}
elseif ($isOSX)
{
  # We are currently not building for Mac on AppVeyor
  
  # It's kind of a pain anyways,
  # and most users don't play on Mac,
  # Developers on Mac usually have experience building on such
  # Supposedly the binary grabbed from AV doesn't work anyways
  
  Write-Host Building for MacOS...
  
  $RepoRoot = "" + (Get-Location)
  
  brew install pkg-config
  vcpkg/bootstrap-vcpkg.sh -disableMetrics
  vcpkg/vcpkg install "@vcpkg_x86_64-darwin.txt"
  
  cmake -G Ninja .. -D CMAKE_BUILD_TYPE=MinSizeRel -D CMAKE_OSX_ARCHITECTURES=x86_64 -D CMAKE_TOOLCHAIN_FILE=../vcpkg/scripts/buildsystems/vcpkg.cmake -D VCPKG_TARGET_TRIPLET=x64-osx "-S$RepoRoot" "-B$RepoRoot/build"
  Push-Directory build
  ninja
}
else
{
  # Unknown OS
  Write-Host Unknown OS! Aborting...
  return -1
}
