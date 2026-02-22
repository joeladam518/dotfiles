# -*- shell-script -*-
# shellcheck shell=bash
# Desktop Functions

# Import the global bash functions
if [ -f "${BASHRC_DIR}/shared/functions.sh" ]; then
    . "${BASHRC_DIR}/shared/functions.sh"
fi

# Import the shared desktop/server functions
if [ -f "${BASHRC_DIR}/shared/debian_functions.sh" ]; then
    . "${BASHRC_DIR}/shared/debian_functions.sh"
fi

# Import the shared dev functions
if [ -f "${BASHRC_DIR}/shared/dev_functions.sh" ]; then
    . "${BASHRC_DIR}/shared/dev_functions.sh"
fi
