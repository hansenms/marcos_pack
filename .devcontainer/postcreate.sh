#!/bin/bash

# Make sure submodules are initialized
git submodule update --init --recursive

# Install pre-commit hooks
pre-commit install

# Allocame memory file for the MaRCoS server
fallocate -l 516KiB /tmp/marcos_server_mem

# Copy the local config for simulation to the client folder
cp local_config.py marcos_client/

