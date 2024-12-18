#!/bin/bash

# Source the logger script
source ./logging-and-output-function.sh

# Enable DEBUG messages if needed
DEBUG=true

# Example log messages
log_message "This is an informational message." "INFO"
log_message "This is a warning message." "WARNING"
log_message "This is an error message." "ERROR"
log_message "This is a debug message." "DEBUG"