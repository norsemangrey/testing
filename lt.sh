#!/bin/bash

# Define the logger function name in a variable
EXTERNAL_LOGGER="./logging-and-output-function.sh"

# Check if logger.sh exists, and source it if it does
if [[ -f "${EXTERNAL_LOGGER}" ]]; then
    source "${EXTERNAL_LOGGER}"
else
    # Fallback minimalistic logger function
    log_message() {
        local level="${2:-INFO}"
        echo "[$level] $1"
    }
fi

# Enable DEBUG messages if needed
DEBUG=true

# Example log messages
log_message "This is an informational message." "INFO"
log_message "This is a warning message." "WARNING"
log_message "This is an error message." "ERROR"
log_message "This is a debug message." "DEBUG"
log_message "This is an undefined message."