#!/bin/bash

# Set external logger- and error handling script paths
externalLogger="./logging-and-output-function.sh"
externalErrorHandler="./error-handling-function.sh"

# Source external logger and error handler
source "${externalLogger}"
source "${externalErrorHandler}" "Failed to set up SSH"

# Verify if logger function exists and sett fallback
if [[ $(type -t logMessage) != function ]]; then

    # Fallback minimalistic logger function
    logMessage() {

        local level="${2:-INFO}"
        echo "[$level] $1"

    }

fi

# Enable DEBUG messages if needed
debug=true

# Example log messages
logMessage "This is an informational message." "INFO"
logMessage "This is a warning message." "WARNING"
logMessage "This is an error message." "ERROR"
logMessage "This is a debug message." "DEBUG"
logMessage "This is an undefined message."

thisFunctionWillFail