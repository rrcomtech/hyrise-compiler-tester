#!/bin/bash

hyrise_url="https://github.com/hyrise/hyrise.git"
nix_package=$1
c_compiler=$2
cxx_compiler=$3

temp_dir="temp-hyrise-$nix_package"
debug_compilation_directory="cmake-debug-$nix_package"
release_compilation_directory="cmake-release-$nix_package"

# Clone Hyrise
nix-shell -p git --run "git clone $hyrise_url --recursive --depth 1 --branch master $temp_dir"
cd "$temp_dir"

pwd
ls

mkdir $debug_compilation_directory $release_compilation_directory

echo
echo "Using $nix_package to compile Hyrise"
echo

# Replace clang with the nix package
nix-shell -p gnused --pure --run "sed -i 's/clang/$nix_package/g' resources/nix/default.nix"

# Compile Hyrise
nix-shell resources/nix --pure --run "\
	cd $debug_compilation_directory && \
	cmake -GNinja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=$c_compiler -DCMAKE_CXX_COMPILER=$cxx_compiler .. && ninja"
res_debug=$?

nix-shell resources/nix --pure --run "\
	cd $release_compilation_directory && \
	cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=$c_compiler -DCMAKE_CXX_COMPILER=$cxx_compiler .. && ninja"
res_release=$?

cd ..

output="|$nixpackage|$res_debug|$res_release|"
echo $output >> "results.md"
rm -rf $temp_dir

