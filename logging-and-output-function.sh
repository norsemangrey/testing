#!/bin/bash

# Determine the log directory (check for env called LOG_PATH else use local)
logDirectory="${LOG_PATH:-$(dirname "$(realpath "${BASH_SOURCE[1]}")")}"

# Set the log file path
logFile="${logDirectory}/$(basename "${BASH_SOURCE[1]}" .sh).log"

# Ensure the log directory exists
mkdir -p "${logDirectory}"

# Enable or disable debug messages
#debug=false

# Helper function to log/write messages
logMessage() {

    local message="${1}"
    local type="${2^^}" # Convert to uppercase (Bash 4+)

    # Default to INFO if no type is provided
    [ -z "$type" ] && type="INFO"

    # Timestamp for the log entry
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Set valid log levels
    local validLevels=("INFO" "WARNING" "ERROR" "DEBUG")

    # Default to INFO for invalid types
    if [[ ! " ${validLevels[*]} " =~ " $type " ]]; then
        type="INFO"
    fi

    # Define padding for alignment
    local maxLabelLength=7
    local paddingLength=$((maxLabelLength - ${#type}))
    local padding=""

    # Set padding
    [ $paddingLength -gt 0 ] && padding=$(printf ' %.0s' $(seq 1 $paddingLength))

    # Construct the formatted message
    local formattedMessage="[$timestamp] [$type]$padding $message"

    # Determine the output color based on the log type
    local colorReset="\e[0m"
    local color
    case "$type" in
        INFO)    color="\e[32m" ;; # Green
        WARNING) color="\e[33m" ;; # Yellow
        ERROR)   color="\e[31m" ;; # Red
        DEBUG)   color="\e[36m" ;; # Cyan
        *)       color="\e[37m" ;; # White
    esac

    # Skip debug messages if debug is disabled
    if [ "$type" = "DEBUG" ] && ! $debug; then
        return
    fi

    # Print to console
    echo -e "${color}${formattedMessage}${colorReset}"

    # Append to the log file
    echo "$formattedMessage" >> "$logFile"

}