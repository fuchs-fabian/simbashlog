#!/usr/bin/env bash

# If you primarily use 'zsh' (Z shell) but have 'bash' installed, the above shebang should work.
# If not, you can set the shebang to #!/bin/bash

# Specify the path to the 'simbashlog.bash' script
source ../src/simbashlog.bash

# Alternatively, if 'simbashlog' is linked to '/bin/simbashlog' via a symbolic link, you can simply use the following:
# source /bin/simbashlog

# Adjust the logging behavior
ENABLE_LOG_FILE=true
ENABLE_JSON_LOG_FILE=true # Default: false
ENABLE_LOG_TO_SYSTEM=true # Default: false

LOG_DIR="/tmp/simbashlogs/"

ENABLE_SIMPLE_LOG_DIR_STRUCTURE=true # Default: false
ENABLE_COMBINED_LOG_FILES=false

LOG_LEVEL=7                    # Default: 6
LOG_LEVEL_FOR_SYSTEM_LOGGING=3 # Default: 4

ENABLE_EXITING_SCRIPT_IF_AT_LEAST_ERROR_IS_LOGGED=false

ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING=true
SHOW_CURRENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING="path"
ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING=false

ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS=false

SIMBASHLOG_NOTIFIER="simbashlog-example-notifier" # This notifier does not exist -> Supported notifiers: https://github.com/fuchs-fabian/simbashlog-notifiers
SIMBASHLOG_NOTIFIER_CONFIG_PATH=""

ENABLE_SUMMARY_ON_EXIT=true # Default: false

# Logging functions
log_emerg "EMERG message"

log_alert "ALERT message"

log_crit "CRIT message"

log_error "ERROR message"

log_warn "WARN message"

log_notice "NOTICE message"

log_info "INFO message"

log_debug "DEBUG message"
