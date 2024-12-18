#!/bin/bash

# Initialize log file path based on the calling script's directory
LOG_DIR=$(dirname "$(realpath "$0")")
LOG_FILE="$LOG_DIR/log.txt"

# Enable or disable DEBUG messages
DEBUG=false

# Helper function to log/write messages
log_message() {

    local MESSAGE="$1"
    local TYPE="${2:-INFO}"

    # Timestamp for the log entry
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    # Convert type to uppercase and calculate padding
    local LABEL=$(echo "$TYPE" | awk '{print toupper($0)}')
    local MAX_LABEL_LENGTH=7
    local PADDING_LENGTH=$((MAX_LABEL_LENGTH - ${#LABEL}))
    local PADDING=""
    [ $PADDING_LENGTH -gt 0 ] && PADDING=$(printf ' %.0s' $(seq 1 $PADDING_LENGTH))

    # Construct formatted message
    local FORMATTED_MESSAGE="[$TIMESTAMP] [$LABEL]$PADDING $MESSAGE"

    # Output message with color based on type
    case "$LABEL" in
        INFO)
            echo -e "\e[32m$FORMATTED_MESSAGE\e[0m" # Green
            ;;
        WARNING)
            echo -e "\e[33m$FORMATTED_MESSAGE\e[0m" # Yellow
            ;;
        ERROR)
            echo -e "\e[31m$FORMATTED_MESSAGE\e[0m" # Red
            ;;
        DEBUG)
            $DEBUG && echo -e "\e[36m$FORMATTED_MESSAGE\e[0m" # Cyan
            ;;
        *)
            echo -e "$FORMATTED_MESSAGE" # Default color
            ;;
    esac

    # Append to the log file
    echo "$FORMATTED_MESSAGE" >> "$LOG_FILE"

}