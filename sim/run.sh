#!/bin/bash
# Brendan Lynskey 2025
# Run all LFSR testbenches
set -e
cd "$(dirname "$0")"
make -j1 all
echo "All LFSR tests complete."
