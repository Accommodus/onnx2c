#!/usr/bin/env bash
set -euo pipefail

BUILD_TYPE="${1:-Release}"

if [[ "$BUILD_TYPE" != "Debug" && "$BUILD_TYPE" != "Release" ]]; then
  echo "Usage: $0 [Debug|Release]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Build type: $BUILD_TYPE"

# Install dependencies
sudo apt-get update
sudo apt-get install -y libprotobuf-dev protobuf-compiler

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" ..

# Build targets
make

# Run tests
make test
