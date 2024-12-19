#!/bin/bash

# Determine the calling script's name and directory
callingScript="${BASH_SOURCE[1]}"

# Get general error message from caller script
errorMessage="${1:-Scrip failed}"

# Source external logger
source "./logging-and-output-function.sh"

# Define the error file
errorFile="/tmp/last-error.txt"

# Redirect all stderr to the error file
exec 2>"${errorFile}"

# Function to handle error from trap
handleError() {

    # Capture the error message and remove the script name prefix
    error=$(cat "${errorFile}" | sed "s|^\./${callingScript}: ||")

    # Log the error without the script name prefix
    logMessage "${errorMessage} (${error})" "ERROR"

    # Exit the script with a non-zero status
    exit 1

}

# Trap errors and pass the error message from the last failed command
trap 'handleError' ERR