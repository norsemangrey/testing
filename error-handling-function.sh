#!/bin/bash

# Get the calling script general error message
generalErrorMessage="${1}"

# Define the error file
errorFile="/tmp/last-error.txt"

# Redirect all stderr to the error file
exec 2>"${errorFile}"

# Function to handle error from trap
handleError() {

    # Determine the calling script's name and directory
    local callingScript="${BASH_SOURCE[1]}"

    # Get the error message passed from the trap
    local errorMessage="${1}"

    # Capture the error message and remove the script name prefix
    local error=$(cat "${errorFile}" | sed "s|${callingScript}: ||g")

    # Source external logger
    source "./logging-and-output-function.sh"

    # Log the error without the script name prefix
    logMessage "${errorMessage} (${error})" "ERROR"

    # Exit the script with a non-zero status
    exit 1

}

# Trap errors and pass the error from the last failed command
# Get and pass general error message from caller script or pass default
trap 'handleError "${generalErrorMessage-Script failed}"' ERR