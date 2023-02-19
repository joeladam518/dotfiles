# -*- shell-script -*-
# shellcheck shell=bash
# Desktop Functions

# Import the global bash functions
if [ -f "${BASHRC_DIR}/shared/.bash_functions" ]; then
    . "${BASHRC_DIR}/shared/.bash_functions"
fi

# Import the shared desktop/server functions
if [ -f "${BASHRC_DIR}/shared/.bash_debian_functions" ]; then
    . "${BASHRC_DIR}/shared/.bash_debian_functions"
fi

# Import the shared dev functions
if [ -f "${BASHRC_DIR}/shared/.bash_dev_functions" ]; then
    . "${BASHRC_DIR}/shared/.bash_dev_functions"
fi
