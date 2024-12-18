#!/bin/bash

# Define the logger function name in a variable
externalLogger="./logging-and-output-function.sh"

# Check if logger.sh exists, and source it if it does
if [[ -f "${externalLogger}" ]]; then
    source "${externalLogger}"
else
    # Fallback minimalistic logger function
    logMessage() {
        local level="${2:-INFO}"
        echo "[$level] $1"
    }
fi

# Function to handle error from trap
handleError() {

    logMessage "Failed to set up SSH (${1})" "ERROR"
    exit 1

}

# Trap errors and pass the error message from the last failed command
trap 'handleError "$(caller 0)"' ERR


# Enable DEBUG messages if needed
debug=true

# Example log messages
logMessage "This is an informational message." "INFO"
logMessage "This is a warning message." "WARNING"
logMessage "This is an error message." "ERROR"
logMessage "This is a debug message." "DEBUG"
logMessage "This is an undefined message."

thisFunctionWillFail