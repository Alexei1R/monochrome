#!/bin/bash
./scripts/colors.sh
# Define the paths to the setup and configure scripts
SETUP_SCRIPT="./scripts/setup.sh"
CONFIGURE_SCRIPT="./configs/configure.sh"

# Check if setup script exists and is executable
if [ -x "$SETUP_SCRIPT" ]; then
    echo "${CNT}Running setup script..."
    "$SETUP_SCRIPT"
else
    echo "${CER}Setup script '$SETUP_SCRIPT' does not exist or is not executable."
    exit 1
fi

# Check if configure script exists and is executable
if [ -x "$CONFIGURE_SCRIPT" ]; then
    echo "${CNT}Running configure script..."
    "$CONFIGURE_SCRIPT"
else
    echo "${CER}Configure script '$CONFIGURE_SCRIPT' does not exist or is not executable."
    exit 1
fi


