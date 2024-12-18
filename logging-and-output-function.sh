#!/bin/bash

# Determine the calling script's name and directory
CALLING_SCRIPT="${BASH_SOURCE[1]}"
CALLING_SCRIPT_NAME=$(basename "$CALLING_SCRIPT" .sh)
CALLING_SCRIPT_DIR=$(dirname "$(realpath "$CALLING_SCRIPT")")

# Determine the log directory
LOG_DIR="${LOG_PATH:-$CALLING_SCRIPT_DIR}"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Set the log file path
LOG_FILE="$LOG_DIR/$CALLING_SCRIPT_NAME.log"

# Enable or disable DEBUG messages
DEBUG=false

# Helper function to log/write messages
log_message() {

    local message="$1"
    local type="${2^^}" # Convert to uppercase (Bash 4+)

    # Default to INFO if no type is provided
    [ -z "$type" ] && type="INFO"

    # Timestamp for the log entry
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Valid log levels
    local valid_levels=("INFO" "WARNING" "ERROR" "DEBUG")
    if [[ ! " ${valid_levels[*]} " =~ " $type " ]]; then
        type="INFO" # Default to INFO for invalid types
    fi

    # Define padding for alignment
    local max_label_length=7
    local padding_length=$((max_label_length - ${#type}))
    local padding=""
    [ $padding_length -gt 0 ] && padding=$(printf ' %.0s' $(seq 1 $padding_length))

    # Construct the formatted message
    local formatted_message="[$timestamp] [$type]$padding $message"

    # Determine the output color based on the log type
    local color_reset="\e[0m"
    local color
    case "$type" in
        INFO)    color="\e[32m" ;; # Green
        WARNING) color="\e[33m" ;; # Yellow
        ERROR)   color="\e[31m" ;; # Red
        DEBUG)   color="\e[36m" ;; # Cyan
        *)       color="\e[37m" ;; # White
    esac

    # Print to console
    if [ "$type" = "DEBUG" ] && ! $DEBUG; then
        return # Skip debug messages if DEBUG is disabled
    fi
    echo -e "${color}${formatted_message}${color_reset}"

    # Append to the log file
    echo "$formatted_message" >> "$LOG_FILE"
}