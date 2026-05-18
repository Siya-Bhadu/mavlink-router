#!/usr/bin/env bash

set -euo pipefail

# Install dependencies (Debian/Ubuntu)
sudo apt update
sudo apt install -y \
    git \
    meson \
    ninja-build \
    build-essential \
    pkg-config

# Clone repository
git clone https://github.com/mavlink-router/mavlink-router.git

cd mavlink-router

# Initialize submodules
git submodule update --init --recursive

# Configure build
meson setup build .

# Compile
ninja -C build

# Install
sudo ninja -C build install

echo "MAVLink Router installed successfully."