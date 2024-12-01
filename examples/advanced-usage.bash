#!/usr/bin/env bash

# If you primarily use 'zsh' (Z shell) but have 'bash' installed, the above shebang should work.
# If not, you can set the shebang to #!/bin/bash

ENABLE_TRAP_FOR_DEBUG=true # Default: false -> not recommended for production
ENABLE_TRAP_FOR_EXIT=true

# Specify the path to the 'simbashlog.bash' script
source ../src/simbashlog.bash

# Alternatively, if 'simbashlog' is linked to '/bin/simbashlog' via a symbolic link, you can simply use the following:
# source /bin/simbashlog

# Adjust the logging behavior
ENABLE_LOG_FILE=true
ENABLE_JSON_LOG_FILE=true # Default: false
ENABLE_LOG_TO_SYSTEM=false

LOG_DIR="/tmp/simbashlogs/"

ENABLE_SIMPLE_LOG_DIR_STRUCTURE=false
ENABLE_COMBINED_LOG_FILES=false

LOG_LEVEL=6
LOG_LEVEL_FOR_SYSTEM_LOGGING=4

FACILITY_NAME_FOR_SYSTEM_LOGGING="user"

ENABLE_EXITING_SCRIPT_IF_AT_LEAST_ERROR_IS_LOGGED=false

ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING=true
SHOW_CURRENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING="path"
#PARENT_SCRIPT_NAME=""
ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING=false

ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS=false
LOG_POPUP_NOTIFICATION_WINDOW_WIDTH=500
LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT=100

SIMBASHLOG_NOTIFIER="simbashlog-example-notifier" # This notifier does not exist -> Supported notifiers: https://github.com/fuchs-fabian/simbashlog-notifiers
SIMBASHLOG_NOTIFIER_CONFIG_PATH=""

ENABLE_SUMMARY_ON_EXIT=true # Default: false

# Logging functionalities in different ways
log_emerg "EMERG message"
log emerg "EMERG message2"
log 0 "EMERG message3"

log_alert "ALERT message"
log alert "ALERT message2"
log 1 "ALERT message3"

log_crit "CRIT message"
log crit "CRIT message2"
log 2 "CRIT message3"

log_error "ERROR message"
log error "ERROR message2"
log 3 "ERROR message3"

log_warn "WARN message"
log warn "WARN message2"
log 4 "WARN message3"

log_notice "NOTICE message"
log notice "NOTICE message2"
log 5 "NOTICE message3"

log_info "INFO message"
log info "INFO message2"
log 6 "INFO message3"

log_debug "DEBUG message"
log debug "DEBUG message2"
log 7 "DEBUG message3"

# 'simbashlog' meta variables
print_var_with_current_value "CONST_SIMBASHLOG_VERSION"
print_var_with_current_value "CONST_SIMBASHLOG_NAME"
print_var_with_current_value "CONST_SIMBASHLOG_GITHUB_LINK"
print_var_with_current_value "CONST_SIMBASHLOG_PAYPAL_DONATE_LINK"
print_var_with_current_value "CONST_SIMBASHLOG_NOTIFIERS_GITHUB_LINK"
print_var_with_current_value "CONST_SIMBASHLOG_LOG_DIR"
print_var_with_current_value "CONST_SIMBASHLOG_REQUIRED_EXTERNAL_PACKAGE_FOR_JSON_LOGGING"

# Immutable variables
print_var_with_current_value "CONST_CURRENT_PID"
print_var_with_current_value "CONST_SCRIPT_NAME_WITH_CURRENT_PATH"
print_var_with_current_value "CONST_SIMPLE_SCRIPT_NAME"
print_var_with_current_value "CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION"
print_var_with_current_value "CONST_ABSOLUTE_SCRIPT_NAME"
print_var_with_current_value "CONST_ABSOLUTE_SCRIPT_DIR"

# Special 'simbashlog' functions
echo "'get_severity_name 3':"
get_severity_name 3

echo "'get_severity_code error':"
get_severity_code error

echo "'print_severities':"
print_severities

echo "'print_all_log_counters':"
print_all_log_counters

echo "'print_all_log_files':"
print_all_log_files

#trap "echo \"'Hello simbashlog user'\"" EXIT
