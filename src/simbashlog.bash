#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#      _           _               _     _              #
#     (_)         | |             | |   | |             #
#  ___ _ _ __ ___ | |__   __ _ ___| |__ | | ___   __ _  #
# / __| | '_ ` _ \| '_ \ / _` / __| '_ \| |/ _ \ / _` | #
# \__ \ | | | | | | |_) | (_| \__ \ | | | | (_) | (_| | #
# |___/_|_| |_| |_|_.__/ \__,_|___/_| |_|_|\___/ \__, | #
#                                                 __/ | #
#                                                |___/  #
#                                                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# DISCLAIMER:
# Not POSIX conform!
#
#
# DESCRIPTION:
# This script makes it very simple to log your bash scripts and get notified about the log messages.
# It is best that you source this script first with:
#
# ```bash
# source <path>/simbashlog.bash
# ```
#
# `<path>` should be replaced by the actual path where 'simbashlog' is located.
#
# This script can also be called with arguments so that it can also be used by other programming languages such as Python..
#
# e.g.:
# ```bash
# ./simbashlog.bash -a json -s error --message "An error occured" --notifier example-simbashlog-notifier.py
# ```
#
# To summarize briefly:
# Logging is possible in `.log`, `.json` and in the system.
# `.json` logging can lead to loss of performance and is only possible if the `jq` package is installed!
# But, if a notifier is used, it is still best if json logging is active, as this makes it easier to generate the messages.
# It is also possible to use popups for logging if the `yad` or `zenity` package is installed.

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░                 LICENSE                  ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# https://github.com/fuchs-fabian/simbashlog/blob/main/LICENSE

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░                METADATA                  ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

declare -rx CONST_SIMBASHLOG_VERSION="1.1.0"
declare -rx CONST_SIMBASHLOG_NAME="simbashlog"
declare -rx CONST_SIMBASHLOG_GITHUB_LINK="https://github.com/fuchs-fabian/simbashlog"
declare -rx CONST_SIMBASHLOG_PAYPAL_DONATE_LINK="https://www.paypal.com/donate/?hosted_button_id=4G9X8TDNYYNKG"
declare -rx CONST_SIMBASHLOG_NOTIFIERS_GITHUB_LINK="https://github.com/fuchs-fabian/simbashlog-notifiers"
declare -rx CONST_SIMBASHLOG_LOG_DIR="/tmp/simbashlogs/"
declare -rx CONST_SIMBASHLOG_REQUIRED_EXTERNAL_PACKAGE_FOR_JSON_LOGGING="jq"

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░                 DONATE                   ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

function _show_donate_message {
    echo -e "\t┌───────────────────────────────────────────────────────────────────────────────────────┐"
    echo -e "\t│     If you like '$CONST_SIMBASHLOG_NAME', please give it a star and consider donating.            │"
    echo -e "\t│  \u2B50 GitHub:            $CONST_SIMBASHLOG_GITHUB_LINK                     │"
    echo -e "\t│  \u2764\uFE0F  Donate via PayPal: $CONST_SIMBASHLOG_PAYPAL_DONATE_LINK  │"
    echo -e "\t└───────────────────────────────────────────────────────────────────────────────────────┘"
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░          ELEMENTS FOR COMMENTS           ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# | single | double |
# |--------|--------|
# | ─      | ═      |
# | │      | ║      |
# | ┌      | ╔      |
# | └      | ╚      |
# | ┐      | ╗      |
# | ┘      | ╝      |
# | ├      | ╠      |
# | ┤      | ╣      |
# | ┬      | ╦      |
# | ┴      | ╩      |
# | ┼      | ╬      |

# ░
# ▓

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░                 DECLARE                  ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# declare ...
#
# | Option | Description                                                                                                                                    |
# |--------|------------------------------------------------------------------------------------------------------------------------------------------------|
# | `-a`   | Declares a variable as an indexed array.                                                                                                       |
# | `-A`   | Declares a variable as an associative array.                                                                                                   |
# | `-f`   | Lists the names and definitions of functions.                                                                                                  |
# | `-F`   | Lists only the names of functions without their definitions.                                                                                   |
# | `-g`   | Declares a global variable within a function (for Bash 4.2 and later).                                                                         |
# | `-i`   | Declares a variable as an integer. Arithmetic operations can be performed directly on the variable.                                            |
# | `-I`   | Available in some Bash versions, sets the default content for the function stack (rarely used).                                                |
# | `-l`   | Converts the variable to lowercase when its value is assigned.                                                                                 |
# | `-n`   | Declares a nameref, a reference to another variable. The referenced variable takes the value of the referencing variable.                      |
# | `-r`   | Declares a variable as readonly. The value of the variable cannot be changed after its declaration.                                            |
# | `-t`   | Marks the variable to trigger the DEBUG trap or RETURN trap when the function exits (used for debugging, rarely used).                         |
# | `-u`   | Converts the variable to uppercase when its value is assigned.                                                                                 |
# | `-x`   | Exports the variable so that it is available in subprocesses.                                                                                  |
# | `-p`   | Returns the attributes and values of declared variables. If no variable is specified, it returns all declared variables with their attributes. |

# ```bash
# declare -rx CONST_MY_CONSTANT="This is a constant"
# ```
#
# Is equivalent to:
#
# ```bash
# readonly CONST_MY_CONSTANT="This is a constant"
# export CONST_MY_CONSTANT
# ```

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░         VARIABLES FOR THE USER           ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║             IMMUTABLE VARIABLES            ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

declare -rx CONST_CURRENT_PID="${$}"

declare -rx CONST_SCRIPT_NAME_WITH_CURRENT_PATH="$0"

CONST_SIMPLE_SCRIPT_NAME="$(basename "$CONST_SCRIPT_NAME_WITH_CURRENT_PATH")"
declare -rx CONST_SIMPLE_SCRIPT_NAME

declare -rx CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION="${CONST_SIMPLE_SCRIPT_NAME%.*}"

CONST_ABSOLUTE_SCRIPT_NAME="$(realpath "$CONST_SCRIPT_NAME_WITH_CURRENT_PATH")"
declare -rx CONST_ABSOLUTE_SCRIPT_NAME

CONST_ABSOLUTE_SCRIPT_DIR="$(dirname "$CONST_ABSOLUTE_SCRIPT_NAME")/"
declare -rx CONST_ABSOLUTE_SCRIPT_DIR

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║              MUTABLE VARIABLES             ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# [INFO] The following variables can be overwritten.

# ┌─────────────────────┬──────────────────────┐
# │               BEFORE SOURCING              │
# └─────────────────────┴──────────────────────┘

# true:     Enables the trap for 'DEBUG'.
#
# This logs all commands as debug messages before they are executed.
# It is not recommended under any circumstances if the script is to be used in production.
declare -xr ENABLE_TRAP_FOR_DEBUG="${ENABLE_TRAP_FOR_DEBUG:=false}"

# true:     Enables the trap for 'EXIT'.
#
# If it is desired to use a separate trap for exit in a script that sources simbashlog, this should be set to false.
# Otherwise it can lead to unexpected problems.
declare -xr ENABLE_TRAP_FOR_EXIT="${ENABLE_TRAP_FOR_EXIT:=true}"

# ┌─────────────────────┬──────────────────────┐
# │         BEFORE AND AFTER SOURCING          │
# └─────────────────────┴──────────────────────┘

# [INFO] The following variables can be overwritten before or after sourcing.

# true:     Enables creation of `.log` files for logging.
declare -x ENABLE_LOG_FILE="${ENABLE_LOG_FILE:=true}"

# true:     Enables creation of `.json` files for logging.
declare -x ENABLE_JSON_LOG_FILE="${ENABLE_JSON_LOG_FILE:=false}"

# true:     Enables logging with `logger` to system.
declare -x ENABLE_LOG_TO_SYSTEM="${ENABLE_LOG_TO_SYSTEM:=false}"

# Location where the log files are to be stored.
#
# Default structure:
#
# Script 1: `/bin/script1.sh`
# Script 2: `/home/test/script1.sh`
# Script 3: `/home/test/script2.sh`
#
# /tmp/simbashlogs/ -> `LOG_DIR`
# │
# ├── bin/
# │    │
# │    └── script1/ -> log-files
# │
# └── home/test/
#      │
#      ├── script1/ -> log-files
#      │
#      └── script2/ -> log-files
declare -x LOG_DIR="${LOG_DIR:="$CONST_SIMBASHLOG_LOG_DIR"}"

# Simplifies the structure where the log files are to be stored in the `LOG_DIR`.
#
# Attention:    For scripts with the same name, the messages are written to the same log files.
# Tip:          If this is to be used, adjust `LOG_DIR`.
#
# Simplified structure:
#
# Script 1: `/bin/script1.sh`
# Script 2: `/home/test/script1.sh`
# Script 3: `/home/test/script2.sh`
#
# /tmp/simbashlogs/ -> `LOG_DIR`
# │
# ├── script1/ -> log-files
# │
# └── script2/ -> log-files
declare -x ENABLE_SIMPLE_LOG_DIR_STRUCTURE="${ENABLE_SIMPLE_LOG_DIR_STRUCTURE:=true}"

# Combines the log messages in the `LOG_DIR`: Files, with all log messages and files for each severity.
#
# The files for the severities are only created if something has also been logged at this level.
#
# /tmp/simbashlogs/ -> `LOG_DIR`
# │
# ├── combined.log          -> `ENABLE_LOG_FILE=true`
# ├── combined_log.json     -> `ENABLE_JSON_LOG_FILE=true`
# │
# │
# ├── emerg.log             -> `ENABLE_LOG_FILE=true`
# ├── emerg_log.json        -> `ENABLE_JSON_LOG_FILE=true`
# │
# ├── alert.log             -> `ENABLE_LOG_FILE=true`
# ├── alert_log.json        -> `ENABLE_JSON_LOG_FILE=true`
# │
# ├── crit.log              -> `ENABLE_LOG_FILE=true`
# ├── crit_log.json         -> `ENABLE_JSON_LOG_FILE=true`
# │
# ├── error.log             -> `ENABLE_LOG_FILE=true`
# ├── error_log.json        -> `ENABLE_JSON_LOG_FILE=true`
# │
# ├── warn.log              -> `ENABLE_LOG_FILE=true`
# ├── warn_log.json         -> `ENABLE_JSON_LOG_FILE=true`
# │
# ├── notice.log            -> `ENABLE_LOG_FILE=true`
# ├── notice_log.json       -> `ENABLE_JSON_LOG_FILE=true`
# │
# ├── info.log              -> `ENABLE_LOG_FILE=true`
# ├── info_log.json         -> `ENABLE_JSON_LOG_FILE=true`
# │
# ├── debug.log             -> `ENABLE_LOG_FILE=true`
# └── debug_log.json        -> `ENABLE_JSON_LOG_FILE=true`
declare -x ENABLE_COMBINED_LOG_FILES="${ENABLE_COMBINED_LOG_FILES:=false}"

# The log level controls the severity of messages that will be logged.
# Messages at the specified level and all levels with a lower numerical code (i.e., more severe) will be logged.
#
# Log levels (RFC 5424) and the corresponding messages:
#
# | Log level | Severity      | Logged Messages                                                                               |
# |-----------|---------------|-----------------------------------------------------------------------------------------------|
# | `0`       | Emergency     | Only Emergency messages will be logged.                                                       |
# | `1`       | Alert         | Emergency and Alert messages will be logged.                                                  |
# | `2`       | Critical      | Emergency, Alert and Critical messages will be logged.                                        |
# | `3`       | Error         | Emergency, Alert, Critical and Error messages will be logged.                                 |
# | `4`       | Warning       | Emergency, Alert, Critical, Error and Warning messages will be logged.                        |
# | `5`       | Notice        | Emergency, Alert, Critical, Error, Warning and Notice messages will be logged.                |
# | `6`       | Informational | Emergency, Alert, Critical, Error, Warning, Notice and Informational messages will be logged. |
# | `7`       | Debug         | All messages, including Debug-level, will be logged.                                          |
declare -x LOG_LEVEL="${LOG_LEVEL:=6}"
declare -x LOG_LEVEL_FOR_SYSTEM_LOGGING="${LOG_LEVEL_FOR_SYSTEM_LOGGING:=4}"

# Valid Facility Names (from the `logger` man page)
#
# | Valid Facility Name | Additional Information                                                        |
# |---------------------|-------------------------------------------------------------------------------|
# | `auth`              |                                                                               |
# | `authpriv`          | For security information of a sensitive nature                                |
# | `cron`              |                                                                               |
# |                     |                                                                               |
# | `daemon`            |                                                                               |
# | `ftp`               |                                                                               |
# | `kern`              | Cannot be generated from userspace process, automatically converted to `user` |
# |                     |                                                                               |
# | `lpr`               |                                                                               |
# | `mail`              |                                                                               |
# | `news`              |                                                                               |
# | `syslog`            |                                                                               |
# | `user`              |                                                                               |
# | `uucp`              |                                                                               |
# | `local0`            |                                                                               |
# | `local1`            |                                                                               |
# | `local2`            |                                                                               |
# | `local3`            |                                                                               |
# | `local4`            |                                                                               |
# | `local5`            |                                                                               |
# | `local6`            |                                                                               |
# | `local7`            |                                                                               |
# | `security`          | Deprecated synonym for `auth`                                                 |
declare -x FACILITY_NAME_FOR_SYSTEM_LOGGING="${FACILITY_NAME_FOR_SYSTEM_LOGGING:="user"}"

# true:     The script will exit if any message of severity Error (3) or higher (i.e., lower numerical code) is logged.
declare -x ENABLE_EXITING_SCRIPT_IF_AT_LEAST_ERROR_IS_LOGGED="${ENABLE_EXITING_SCRIPT_IF_AT_LEAST_ERROR_IS_LOGGED:=false}"

# true:     `<date> - [<level>] - <message>`
# false:    `[<level>] - <message>`
declare -x ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING="${ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING:=false}"

# "path":                           `CONST_SCRIPT_NAME_WITH_CURRENT_PATH`
# "simple":                         `CONST_SIMPLE_SCRIPT_NAME`
# "simple_without_file_extension":  `CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION`
# "absolute":                       `CONST_ABSOLUTE_SCRIPT_NAME`
#
# Example: `[<script name>] - [<level>] - <message>`
#   If the script is located at `/home/user/scripts/myscript.sh` and is executed with different methods:
#     - "path": If executed as `/home/user/scripts/myscript.sh`, the output will be `/home/user/scripts/myscript.sh`.
#               If executed as `./myscript.sh` from the script's directory, the output will be `./myscript.sh`.
#     - "simple": `myscript.sh`
#     - "simple_without_file_extension": `myscript`
#     - "absolute": `/home/user/scripts/myscript.sh`
declare -x SHOW_CURRENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING="${SHOW_CURRENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING:="path"}"

# If set (-> not "" or defined in the script, that sources 'simbashlog'), this value will be used in the folder structure for log file organization.
# The log data will first be written in a folder named after the parent script's directory, before falling back to the default log directory structure.
#
# Default behavior:
# The command retrieves the full command-line arguments of the parent process that invoked the current script.
# It then removes any instances of "/bin/bash" and leading "bash " from the command string to clean up the path.
# The result is the absolute path of the parent script, excluding the shell invocation details.
#
# The `realpath` command is used to convert this path to its absolute form.
# If `realpath` fails (e.g., if the path does not exist), an empty string is used.
: "${PARENT_SCRIPT_NAME:="$(realpath "$(ps -o args= -p $PPID | sed -e 's:/bin/bash::g' -e 's:^[[:space:]]*bash ::g')" 2>/dev/null || echo "")"}"
declare -x PARENT_SCRIPT_NAME

# true:   Parent script name is included in the console output.
#          Note: This is only used if `PARENT_SCRIPT_NAME` is not empty.
#
# Example: `[<parent script name> -> <script name>] - [<level>] - <message>`
declare -x ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING="${ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING:=false}"

# This flag controls whether GUI popups are used for logging notifications.
# When set to true:
#   - If `yad` (Yet Another Dialog) is installed, it will be used to display the notifications.
#   - If `yad` is not installed, but `zenity` is available, `zenity` will be used as a fallback.
#   - If neither `yad` nor `zenity` is installed, no GUI output will be displayed.
# When set to false, no GUI popups will be used for logging notifications, regardless of whether `yad` or `zenity` is installed.
declare -x ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS="${ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS:=false}"

# IMPORTANT:
# - If the script is called with arguments, the parent script name is the name used for the logic!
# - If the parent script name is empty, the script name is used for the log actions except for console outputs.

# These settings control the dimensions of the popup window that displays log notifications to the user.
declare -x LOG_POPUP_NOTIFICATION_WINDOW_WIDTH="${LOG_POPUP_NOTIFICATION_WINDOW_WIDTH:=500}"
declare -x LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT="${LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT:=100}"

# This parameter defines the name of the script that acts as the notifier.
# It must accept the following arguments:
# --config: The path to the configuration file.
# --pid: The process ID.
# --log-level: A number specifying the desired log level.
# --message: The message to be displayed. Only used when script is called with arguments.
# --log-file: The `*.log`` file.
# --json-log-file: The `*_log.json` log file
#
# The notifier sends notifications based on the methods defined in the notifier script.
# If `SIMBASHLOG_NOTIFIER` is empty, no notifications will be sent.
declare -x SIMBASHLOG_NOTIFIER="${SIMBASHLOG_NOTIFIER:=""}"

# This parameter defines the configuration file for the notifier.
declare -x SIMBASHLOG_NOTIFIER_CONFIG_PATH="${SIMBASHLOG_NOTIFIER_CONFIG_PATH:=""}"

# This flag controls whether the script should display a summary on exit.
declare -x ENABLE_SUMMARY_ON_EXIT="${ENABLE_SUMMARY_ON_EXIT:=false}"

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░            SHELL BEHAVIOR - SET          ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# set ...
#
# | Option         | Description                                                      | Usefulness                                                                          |
# |----------------|------------------------------------------------------------------|-------------------------------------------------------------------------------------|
# | `-u`           | Causes the script to throw an error and                          | Prevents the use of uninitialized variables, which can lead to unexpected behavior. |
# |                | exit if an uninitialized variable is used.                       |                                                                                     |
# | `-o pipefail`  | Causes the script to fail if any command in a pipeline fails.    | Ensures that errors in a pipeline are not ignored.                                  |
# | `-e`           | Causes the script to exit immediately if                         | Prevents the script from continuing after a critical error.                         |
# |                | any command exits with a non-zero status.                        |                                                                                     |
# | `-x`           | Prints each command and its arguments to the console             | Useful for debugging to trace the commands and the flow of the script.              |
# |                | before executing it.                                             |                                                                                     |
# | `-v`           | Prints each line of the script, including blank lines            | Tracks the detailed flow of the script, including comments and blank lines.         |
# |                | and comments, before executing it.                               |                                                                                     |
# | `+e`/`+x`      | Disables the corresponding option (`-e`, `-x`, `-u`, `-v`).      | Temporarily turns off specific `set` options.                                       |
# | `-o`           | Shows the current status of all options (enabled or disabled).   | Checks which `set` options are currently active.                                    |
# | `-o ignoreeof` | Prevents the script from exiting when `Ctrl+D` (EOF) is pressed. | Prevents accidental script termination by `Ctrl+D`.                                 |
# | `-o noclobber` | Prevents files from being overwritten by redirection (`> file`). | Prevents accidental overwriting of files.                                           |
# |                | If the file exists, it will result in an error.                  |                                                                                     |

set -uo pipefail

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░               COLOR UTILS                ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                ANSI COLORS                 ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124#file-bash-colors-md
#
# |          | regular  | bold     | underline  | background | high_intensity | bold_high_intensity | high_intensity_background |
# |----------|----------|----------|------------|------------|----------------|---------------------|---------------------------|
# | black    | \e[0;30m | \e[1;30m | \e[4;30m   | \e[40m     | \e[0;90m       | \e[1;90m            | \e[0;100m                 |
# | red      | \e[0;31m | \e[1;31m | \e[4;31m   | \e[41m     | \e[0;91m       | \e[1;91m            | \e[0;101m                 |
# | green    | \e[0;32m | \e[1;32m | \e[4;32m   | \e[42m     | \e[0;92m       | \e[1;92m            | \e[0;102m                 |
# | yellow   | \e[0;33m | \e[1;33m | \e[4;33m   | \e[43m     | \e[0;93m       | \e[1;93m            | \e[0;103m                 |
# | blue     | \e[0;34m | \e[1;34m | \e[4;34m   | \e[44m     | \e[0;94m       | \e[1;94m            | \e[0;104m                 |
# | purple   | \e[0;35m | \e[1;35m | \e[4;35m   | \e[45m     | \e[0;95m       | \e[1;95m            | \e[0;105m                 |
# | cyan     | \e[0;36m | \e[1;36m | \e[4;36m   | \e[46m     | \e[0;96m       | \e[1;96m            | \e[0;106m                 |
# | white    | \e[0;37m | \e[1;37m | \e[4;37m   | \e[47m     | \e[0;97m       | \e[1;97m            | \e[0;107m                 |
# | reset    | \e[0m    | -        | -          | -          | -              | -                   | -                         |

declare -Arx CONST_ANSI_COLORS=(
    [black, regular]='\e[0;30m'
    [black, bold]='\e[1;30m'
    [black, underline]='\e[4;30m'
    [black, background]='\e[40m'
    [black, high_intensity]='\e[0;90m'
    [black, bold_high_intensity]='\e[1;90m'
    [black, high_intensity_background]='\e[0;100m'

    [red, regular]='\e[0;31m'
    [red, bold]='\e[1;31m'
    [red, underline]='\e[4;31m'
    [red, background]='\e[41m'
    [red, high_intensity]='\e[0;91m'
    [red, bold_high_intensity]='\e[1;91m'
    [red, high_intensity_background]='\e[0;101m'

    [green, regular]='\e[0;32m'
    [green, bold]='\e[1;32m'
    [green, underline]='\e[4;32m'
    [green, background]='\e[42m'
    [green, high_intensity]='\e[0;92m'
    [green, bold_high_intensity]='\e[1;92m'
    [green, high_intensity_background]='\e[0;102m'

    [yellow, regular]='\e[0;33m'
    [yellow, bold]='\e[1;33m'
    [yellow, underline]='\e[4;33m'
    [yellow, background]='\e[43m'
    [yellow, high_intensity]='\e[0;93m'
    [yellow, bold_high_intensity]='\e[1;93m'
    [yellow, high_intensity_background]='\e[0;103m'

    [blue, regular]='\e[0;34m'
    [blue, bold]='\e[1;34m'
    [blue, underline]='\e[4;34m'
    [blue, background]='\e[44m'
    [blue, high_intensity]='\e[0;94m'
    [blue, bold_high_intensity]='\e[1;94m'
    [blue, high_intensity_background]='\e[0;104m'

    [purple, regular]='\e[0;35m'
    [purple, bold]='\e[1;35m'
    [purple, underline]='\e[4;35m'
    [purple, background]='\e[45m'
    [purple, high_intensity]='\e[0;95m'
    [purple, bold_high_intensity]='\e[1;95m'
    [purple, high_intensity_background]='\e[0;105m'

    [cyan, regular]='\e[0;36m'
    [cyan, bold]='\e[1;36m'
    [cyan, underline]='\e[4;36m'
    [cyan, background]='\e[46m'
    [cyan, high_intensity]='\e[0;96m'
    [cyan, bold_high_intensity]='\e[1;96m'
    [cyan, high_intensity_background]='\e[0;106m'

    [white, regular]='\e[0;37m'
    [white, bold]='\e[1;37m'
    [white, underline]='\e[4;37m'
    [white, background]='\e[47m'
    [white, high_intensity]='\e[0;97m'
    [white, bold_high_intensity]='\e[1;97m'
    [white, high_intensity_background]='\e[0;107m'

    [reset, regular]='\e[0m'
)

declare -rx CONST_COLOR_CODE_FOR_RESETTING_FOREGROUND_AND_BACKGROUND="${CONST_ANSI_COLORS[reset, regular]}${CONST_ANSI_COLORS[reset, regular]}"

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                  STDERR                    ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# Prints an error message to stderr, with optional severity-based coloring.
#
# Parameters:
#   $1 - The error message to be printed. This is a required parameter.
#   $2 - (Optional) The severity of the message. Can be "error" or "warn".
#        If "error", the message is printed in red and bold.
#        If "warn", the message is printed in yellow and bold.
#        If not provided or any other value, the message is printed without color.
#
# Example:
#   print_stderr "An unexpected error occurred." "error"
#   print_stderr "This is a warning." "warn"
#   print_stderr "This is a regular stderr message without color."
function print_stderr {
    local stderr_message="${1:-}"
    local severity="${2:-}"

    if [[ -z "$stderr_message" ]]; then
        echo "[!] The stderr message to be printed is empty!" >&2
        ENABLE_SUMMARY_ON_EXIT=false
        exit 1
    fi

    local message

    case "$severity" in
    error)
        message="${CONST_ANSI_COLORS[red, bold]}${stderr_message}"
        ;;
    warn)
        message="${CONST_ANSI_COLORS[yellow, bold]}${stderr_message}"
        ;;
    *)
        echo "$stderr_message" >&2
        return 0
        ;;
    esac

    echo -e "${CONST_COLOR_CODE_FOR_RESETTING_FOREGROUND_AND_BACKGROUND}${message}${CONST_COLOR_CODE_FOR_RESETTING_FOREGROUND_AND_BACKGROUND}" >&2
    return 0
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░       VALIDATION OF VARIABLE TYPES       ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║           SIMPLE VARIABLE TYPES            ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │               RAW VARIABLES                │
# └─────────────────────┴──────────────────────┘

# Checks if the specified variable is empty.
#
# Parameters:
#   $1 - The value to check (variable or string).
#
# Returns:
#   0 if the variable is empty or unset.
#   1 if the variable has a non-empty value.
#
# Example:
#   my_var=""
#   if is_var_empty "$my_var"; then
#       echo "Is empty."
#   else
#       echo "Is not empty."
#   fi
function is_var_empty {
    if [[ -z "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Works like `is_var_empty`, but negates the output.
function is_var_not_empty {
    ! is_var_empty "$1"
}

# Checks if the specified variable is equal to another variable.
#
# Parameters:
#   $1 - The first variable to compare (string).
#   $2 - The second variable to compare (string).
#
# Returns:
#   0 if the variables are equal.
#   1 if the variables are not equal.
#
# Example:
#   var1="value"
#   var2="value"
#   if is_var_equal "$var1" "$var2"; then
#       echo "Variables are equal."
#   else
#       echo "Variables are not equal."
#   fi
function is_var_equal {
    if [[ "$1" == "$2" ]]; then
        return 0
    else
        return 1
    fi
}

# Works like `is_var_equal`, but negates the output.
function is_var_not_equal {
    ! is_var_equal "$1" "$2"
}

# ┌─────────────────────┬──────────────────────┐
# │                 BOOLEANS                   │
# └─────────────────────┴──────────────────────┘

# Checks if the specified value is a boolean (either "true" or "false").
#
# Parameters:
#   $1 - The value to check (string).
#
# Returns:
#   0 if the value is "true" or "false".
#   1 if the value is neither "true" nor "false".
#
# Example:
#   value=true
#   if is_boolean "$value"; then
#       echo "Value is a boolean."
#   else
#       echo "Value is not a boolean."
#   fi
function is_boolean {
    case "$1" in
    true | false)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

# Works like `is_boolean`, but negates the output.
function is_not_boolean {
    ! is_boolean "$1"
}

# Checks if the specified boolean value is "true".
#
# Parameters:
#   $1 - The value to check (string).
#
# Returns:
#   0 if the value is "true".
#   1 if the value is not "true".
#
# Example:
#   value="true"
#   if is_true "$value"; then
#       echo "Value is true."
#   else
#       echo "Value is not true."
#   fi
function is_true {
    if is_boolean "$1"; then
        if is_var_equal "$1" "true"; then
            return 0
        fi
    fi
    return 1
}

# Works like `is_true`, but with "false".
function is_false {
    if is_boolean "$1"; then
        if is_var_equal "$1" "false"; then
            return 0
        fi
    fi
    return 1
}

# ┌─────────────────────┬──────────────────────┐
# │              NUMERIC VARIABLES             │
# └─────────────────────┴──────────────────────┘

# Checks if the specified value is numeric (consists only of digits).
#
# Parameters:
#   $1 - The value to check (string).
#
# Returns:
#   0 if the value is numeric.
#   1 if the value is not numeric.
#
# Example:
#   value="123"
#   if is_numeric "$value"; then
#       echo "Value is numeric."
#   else
#       echo "Value is not numeric."
#   fi
function is_numeric {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Works like `is_numeric`, but negates the output.
function is_not_numeric {
    ! is_numeric "$1"
}

function _print_stderr_for_not_numeric {
    print_stderr "'$1' is not a numeric value." "warn"
}

# Checks if the specified numeric value is smaller than another numeric value.
#
# Parameters:
#   $1 - The value to check (string).
#   $2 - The value to compare against (string).
#
# Returns:
#   0 if the value is numeric and smaller than the compared value.
#   1 if a parameter is not numeric, or if the value is not smaller than the compared value.
#
# Example:
#   value="5"
#   compared_value="10"
#   if is_less "$value" "$compared_value"; then
#       echo "Value is smaller."
#   else
#       echo "Value is not smaller."
#   fi
function is_less {
    local value="$1"
    local compared_value="$2"

    if is_not_numeric "$value"; then
        _print_stderr_for_not_numeric "$value"
        return 1
    fi

    if is_not_numeric "$compared_value"; then
        _print_stderr_for_not_numeric "$compared_value"
        return 1
    fi

    if ((value < compared_value)); then
        return 0
    else
        return 1
    fi
}

# Works like `is_less`, but also returns true if the values are equal.
function is_less_or_equal {
    local value="$1"
    local compared_value="$2"

    if is_not_numeric "$value"; then
        _print_stderr_for_not_numeric "$value"
        return 1
    fi

    if is_not_numeric "$compared_value"; then
        _print_stderr_for_not_numeric "$compared_value"
        return 1
    fi

    if ((value <= compared_value)); then
        return 0
    else
        return 1
    fi
}

# Works like `is_less`, but checks if the value is bigger than the compared value.
function is_greater {
    local value="$1"
    local compared_value="$2"

    if is_not_numeric "$value"; then
        _print_stderr_for_not_numeric "$value"
        return 1
    fi

    if is_not_numeric "$compared_value"; then
        _print_stderr_for_not_numeric "$compared_value"
        return 1
    fi

    if ((value > compared_value)); then
        return 0
    else
        return 1
    fi
}

# Works like `is_greater`, but also returns true if the values are equal.
function is_greater_or_equal {
    local value="$1"
    local compared_value="$2"

    if is_not_numeric "$value"; then
        _print_stderr_for_not_numeric "$value"
        return 1
    fi

    if is_not_numeric "$compared_value"; then
        _print_stderr_for_not_numeric "$compared_value"
        return 1
    fi

    if ((value >= compared_value)); then
        return 0
    else
        return 1
    fi
}

# Checks if the specified numeric value is greater than zero.
#
# Parameters:
#   $1 - The value to check (string).
#
# Returns:
#   0 if the value is numeric and greater than zero.
#   1 if the value is not numeric, or if it is numeric but not greater than zero.
#
# Example:
#   value="5"
#   if is_numeric_and_greater_than_zero "$value"; then
#       echo "Value is numeric and greater than zero."
#   else
#       echo "Value is not numeric or not greater than zero."
#   fi
function is_numeric_and_greater_than_zero {
    local value="$1"

    if is_numeric "$value"; then
        if ((value > 0)); then
            return 0
        else
            return 1
        fi
    else
        _print_stderr_for_not_numeric "$value"
        return 1
    fi
}

# Checks if the specified numeric value is within a given range, inclusive.
#
# Parameters:
#   $1 - The value to check (string).
#   $2 - The minimum value of the range (string), inclusive.
#   $3 - The maximum value of the range (string), inclusive.
#
# Returns:
#   0 if the value is numeric and falls within the specified range (inclusive).
#   1 if a parameter is not numeric, or if it does not fall within the specified range.
#
# Example:
#   value="5"
#   min="1"
#   max="10"
#   if is_numeric_in_range "$value" "$min" "$max"; then
#       echo "Value is numeric and within the range."
#   else
#       echo "Value is either not numeric or not within the range."
#   fi
function is_numeric_in_range {
    local value="$1"
    local min="${2:-}" # inclusive
    local max="${3:-}" # inclusive

    local message_part_for_empty_var=": Is empty! 'is_numeric_in_range' aborted!"

    if is_var_empty "$min"; then
        print_stderr "'min'$message_part_for_empty_var" "warn"
        return 1
    fi

    if is_var_empty "$max"; then
        print_stderr "'max'$message_part_for_empty_var" "warn"
        return 1
    fi

    if is_not_numeric "$value"; then
        _print_stderr_for_not_numeric "$value"
        return 1
    fi

    if is_not_numeric "$min"; then
        _print_stderr_for_not_numeric "$min"
        return 1
    fi

    if is_not_numeric "$max"; then
        _print_stderr_for_not_numeric "$max"
        return 1
    fi

    if ((value >= min && value <= max)); then
        return 0
    else
        return 1
    fi
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║          ADVANCED VARIABLE TYPES           ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │               INDEXED ARRAYS               │
# └─────────────────────┴──────────────────────┘

# Checks if the specified variable is an indexed array.
#
# Parameters:
#   $1 - The name of the indexed array to check (string).
#
# Returns:
#   0 if the variable is declared as an indexed array (i.e., `declare -a`).
#   1 if the variable is not an indexed array or does not exist.
#
# Example:
#   my_array=("element1" "element2")
#   if is_indexed_array "my_array"; then
#       echo "The variable is an indexed array."
#   else
#       echo "The variable is not an indexed array."
#   fi
function is_indexed_array {
    local indexed_array_name="$1"

    if [[ "$(declare -p "$indexed_array_name" 2>/dev/null)" =~ "declare -a" ]]; then
        return 0
    else
        print_stderr "'$indexed_array_name' was not declared as an indexed ('declare -a $indexed_array_name' or '$indexed_array_name=()') array or does not exist." "warn"
        return 1
    fi
}

# ┌─────────────────────┬──────────────────────┐
# │              ASSOCIATIVE ARRAYS            │
# └─────────────────────┴──────────────────────┘

# Checks if the specified variable is an associative array.
#
# Parameters:
#   $1 - The name of the associative array to check (string).
#
# Returns:
#   0 if the variable is declared as an associative array. (i.e., `declare -A`).
#   1 if the variable is not an associative array or it does not exist.
#
# Example:
#   declare -A my_assoc_array
#   if is_assoc_array "my_assoc_array"; then
#       echo "Is an associative array."
#   else
#       echo "Is not an associative array."
#   fi
function is_assoc_array {
    local assoc_array_name="$1"

    if [[ "$(declare -p "$assoc_array_name" 2>/dev/null)" =~ "declare -A" ]]; then
        return 0
    else
        print_stderr "'$assoc_array_name' was not declared as an associative ('declare -A $assoc_array_name') array or does not exist." "warn"
        return 1
    fi
}

# Checks if the specified associative array contains a key.
#
# Parameters:
#   $1 - The name of the associative array to check (string).
#   $2 - The key to check for (string).
#
# Returns:
#   0 if the key exists in the associative array.
#   1 if the key does not exist in the associative array or if the variable is not an associative array.
#
# Example:
#   declare -A my_assoc_array=( ["key1"]="value1" ["key2"]="value2" )
#   if contains_key_in_assoc_array "my_assoc_array" "key1"; then
#       echo "The key exists in the associative array."
#   else
#       echo "The key does not exist in the associative array."
#   fi
function contains_key_in_assoc_array {
    local assoc_array_name="$1"
    local key="$2"

    local -n array_for_key_check="$assoc_array_name"

    if is_assoc_array "$assoc_array_name"; then
        if [[ -v array_for_key_check["$key"] ]]; then
            return 0
        fi
    fi
    return 1
}

# Works like `contains_key_in_assoc_array`, but returns true if the key does not exist in the associative array.
function contains_not_key_in_assoc_array {
    local assoc_array_name="$1"
    local key="$2"

    local -n array_for_key_check="$assoc_array_name"

    if is_assoc_array "$assoc_array_name"; then
        if [[ ! -v array_for_key_check["$key"] ]]; then
            return 0
        fi
    fi
    return 1
}

# ┌─────────────────────┬──────────────────────┐
# │                  ARRAYS                    │
# └─────────────────────┴──────────────────────┘

# Checks if the specified variable is an array (indexed or associative).
#
# Parameters:
#   $1 - The name of the variable to check (string).
#
# Returns:
#   0 if the variable is a valid array.
#   1 if the variable is not an array or if it is not a valid array.
#
# Example:
#   # Indexed array example
#   declare -a my_indexed_array=("element1" "element2")
#   if is_array "my_indexed_array"; then
#       echo "The variable is an indexed array."
#   else
#       echo "The variable is not an indexed array."
#   fi
#
#   # Associative array example
#   declare -A my_assoc_array=( ["key1"]="value1" ["key2"]="value2" )
#   if is_array "my_assoc_array"; then
#       echo "The variable is an associative array."
#   else
#       echo "The variable is not an associative array."
#   fi
function is_array {
    local array_name="$1"

    if is_indexed_array "$array_name" 2>/dev/null || is_assoc_array "$array_name" 2>/dev/null; then
        return 0
    else
        print_stderr "'$array_name' was not declared as an indexed ('declare -a $array_name' or '$array_name=()') or associative ('declare -A $array_name') array or does not exist." "warn"
        return 1
    fi
}

# Checks if the specified array is empty.
#
# Parameters:
#   $1 - The name of the variable to check (string).
#
# Returns:
#   0 if the array is empty.
#   1 if the array is not empty or if the provided variable is not a valid array.
#
# Example:
#   # Indexed array example
#   declare -a my_indexed_array=()
#   if is_array_empty "my_indexed_array"; then
#       echo "The indexed array is empty."
#   else
#       echo "The indexed array is not empty or is not a valid array."
#   fi
#
#   # Associative array example
#   declare -A my_assoc_array=()
#   if is_array_empty "my_assoc_array"; then
#       echo "The associative array is empty."
#   else
#       echo "The associative array is not empty or is not a valid array."
#   fi
function is_array_empty {
    local array_name="$1"
    local -n array="$array_name"

    if is_array "$array_name"; then
        if [[ ${#array[@]} -eq 0 ]]; then
            return 0
        fi
    fi
    return 1
}

# Works like `is_array_empty`, but returns 0 if the array is not empty.
function is_array_not_empty {
    local array_name="$1"
    local -n array="$array_name"

    if is_array "$array_name"; then
        if [[ ${#array[@]} -gt 0 ]]; then
            return 0
        fi
    fi
    return 1
}

# ┌─────────────────────┬──────────────────────┐
# │                   LISTS                    │
# └─────────────────────┴──────────────────────┘

# This function is essentially a renamed version of the `is_array_empty` function but checks whether it is an indexed array.
# It behaves the same way and takes the same parameters.
function is_list_empty {
    local list_name="$1"

    if is_indexed_array "$list_name"; then
        is_array_empty "$list_name" 2>/dev/null
    fi
}

# This function is essentially a renamed version of the `is_array_not_empty` function but checks whether it is an indexed array.
# It behaves the same way and takes the same parameters.
function is_list_not_empty {
    local list_name="$1"

    if is_indexed_array "$list_name"; then
        is_array_not_empty "$list_name" 2>/dev/null
    fi
}

# ┌─────────────────────┬──────────────────────┐
# │                DICTIONARIES                │
# └─────────────────────┴──────────────────────┘

# This function is essentially a renamed version of the `contains_key_in_assoc_array` function.
function contains_key_in_dict {
    contains_key_in_assoc_array "$1" "$2"
}

# This function is essentially a renamed version of the `contains_not_key_in_assoc_array` function.
function contains_not_key_in_dict {
    contains_not_key_in_assoc_array "$1" "$2"
}

# This function is essentially a renamed version of the `is_array_empty` function but checks whether it is an associative array.
# It behaves the same way and takes the same parameters.
function is_dict_empty {
    local dict_name="$1"

    if is_assoc_array "$dict_name"; then
        is_array_empty "$dict_name" 2>/dev/null
    fi
}

# This function is essentially a renamed version of the `is_array_not_empty` function but checks whether it is an associative array.
# It behaves the same way and takes the same parameters.
function is_dict_not_empty {
    local dict_name="$1"

    if is_assoc_array "$dict_name"; then
        is_array_not_empty "$dict_name" 2>/dev/null
    fi
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║            PATH VARIABLE TYPES             ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │                   PATHS                    │
# └─────────────────────┴──────────────────────┘

# Checks if the specified path exists.
#
# Parameters:
#   $1 - The path to check (string).
#
# Returns:
#   0 if the path exists.
#   1 if the path does not exist.
#
# Example:
#   if path_exists "/path/to/file"; then
#       echo "The path exists."
#   else
#       echo "The path does not exist."
#   fi
function path_exists {
    if [[ -e "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Works like `path_exists`, but negates the output.
function path_not_exists {
    ! path_exists "$1"
}

# Checks if the specified path contains a slash.
#
# Parameters:
#   $1 - The path to check (string).
#
# Returns:
#   0 if the path contains a slash.
#   1 if the path does not contain a slash.
#
# Example:
#   if path_contains_slash "/path/to/file"; then
#       echo "The path contains a slash."
#   else
#       echo "The path does not contain a slash."
#   fi
function path_contains_slash {
    if is_var_not_empty "$1" && [[ "$1" == */* ]]; then
        return 0
    fi
    return 1
}

# Works like `path_contains_slash`, but negates the output.
function path_not_contains_slash {
    ! path_contains_slash "$1"
}

# Checks if the specified path starts with a slash.
#
# Parameters:
#   $1 - The path to check (string).
#
# Returns:
#   0 if the path starts with a slash.
#   1 if the path does not start with a slash.
#
# Example:
#   if path_starts_with_slash "/path/to/file"; then
#       echo "The path starts with a slash."
#   else
#       echo "The path does not start with a slash."
#   fi
function path_starts_with_slash {
    if is_var_not_empty "$1" && [[ "$1" == /* ]]; then
        return 0
    fi
    return 1
}

# Works like `path_starts_with_slash`, but negates the output.
function path_not_starts_with_slash {
    ! path_starts_with_slash "$1"
}

# This function is essentially a renamed version of the `path_starts_with_slash` function.
function path_is_absolute {
    path_starts_with_slash "$1"
}

# Works like `path_is_absolute`, but negates the output.
function path_is_not_absolute {
    ! path_is_absolute "$1"
}

# This function is essentially a renamed version of the `path_not_starts_with_slash` function.
function path_is_relative {
    path_not_starts_with_slash "$1"
}

# Works like `path_is_relative`, but negates the output.
function path_is_not_relative {
    ! path_is_relative "$1"
}

# Checks if the specified path ends with a slash.
#
# Parameters:
#   $1 - The path to check (string).
#
# Returns:
#   0 if the path ends with a slash.
#   1 if the path does not end with a slash.
#
# Example:
#   if path_ends_with_slash "/path/to/directory/"; then
#       echo "The path ends with a slash."
#   else
#       echo "The path does not end with a slash."
#   fi
function path_ends_with_slash {
    if is_var_not_empty "$1" && [[ "$1" == */ ]]; then
        return 0
    fi
    return 1
}

# Works like `path_ends_with_slash`, but negates the output.
function path_not_ends_with_slash {
    ! path_ends_with_slash "$1"
}

# ┌─────────────────────┬──────────────────────┐
# │                DIRECTORIES                 │
# └─────────────────────┴──────────────────────┘

# Checks if the specified directory exists.
#
# Parameters:
#   $1 - The path to the directory (string).
#
# Returns:
#   0 if the directory exists.
#   1 if the directory does not exist.
#
# Example:
#   if directory_exists "/path/to/directory"; then
#       echo "The directory exists."
#   else
#       echo "The directory does not exist."
#   fi
function directory_exists {
    if [[ -d "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Works like `directory_exists`, but negates the output.
function directory_not_exists {
    ! directory_exists "$1"
}

# ┌─────────────────────┬──────────────────────┐
# │                   FILES                    │
# └─────────────────────┴──────────────────────┘

# Checks if the specified file exists.
#
# Parameters:
#   $1 - The path to the file (string).
#
# Returns:
#   0 if the file exists.
#   1 if the file does not exist.
#
# Example:
#   if file_exists "/path/to/file"; then
#       echo "The file exists."
#   else
#       echo "The file does not exist."
#   fi
function file_exists {
    if [[ -f "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Works like `file_exists`, but negates the output.
function file_not_exists {
    ! file_exists "$1"
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░         GENERAL HELPER FUNCTIONS         ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║    FUNCTIONS FOR SIMPLE VARIABLE TYPES     ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │            STRING CONVERSIONS              │
# └─────────────────────┴──────────────────────┘

# Prints the name of the specified variable and its current value.
#
# Parameters:
#   $1 - The name of the variable to print (string).
#
# Example:
#   my_var="value"
#   print_var_with_current_value "my_var"
#   # Output: 'my_var': 'value'
function print_var_with_current_value {
    local var_name="$1"
    local -n current_value="$var_name"
    echo "'${var_name}': '${current_value}'"
}

# Converts the specified string to uppercase.
#
# Parameters:
#   $1 - The string to be converted to uppercase (string).
#
# Returns:
#   The input string converted to uppercase.
#
# Example:
#   result=$(to_uppercase "123 abc! @#$")
#   echo "$result"  # Output: 123 ABC! @#$
function to_uppercase {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Works like `to_uppercase`, but converts the string to lowercase.
function to_lowercase {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║   FUNCTIONS FOR ADVANCED VARIABLE TYPES    ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │               INDEXED ARRAYS               │
# └─────────────────────┴──────────────────────┘

# Adds an item to the specified indexed array.
#
# Parameters:
#   $1 - The name of the indexed array to which the item should be added (string).
#   $2 - The item to add to the indexed array (string).
#
# Returns:
#   0 if the item is successfully added to the indexed array.
#   1 if the variable is not an indexed array, the item is empty, or an error occurs.
#
# Example:
#   declare -a my_array=("apple" "banana")
#   add_item_to_indexed_array "my_array" "cherry"
#   echo "${my_array[@]}"
#   # Output: apple banana cherry
function add_item_to_indexed_array {
    local indexed_array_name="$1"
    local item="$2"

    local -n indexed_array_for_item="$indexed_array_name"

    if is_indexed_array "$indexed_array_name"; then
        if is_var_not_empty "$item"; then
            indexed_array_for_item+=("$item")
            return 0
        else
            print_stderr "The item to add is empty." "warn"
        fi
    fi
    return 1
}

# Adds a unique item to the specified indexed array.
#
# Parameters:
#   $1 - The name of the indexed array to which the unique item should be added (string).
#   $2 - The item to add to the indexed array (string).
#
# Returns:
#   0 if the item is successfully added to the indexed array or if the item already exists in the array.
#   1 if the variable is not an indexed array, the item is empty, or an error occurs.
#
# Example:
#   declare -a my_array=("apple" "banana")
#   add_unique_item_to_indexed_array "my_array" "banana"
#   echo "${my_array[@]}"
#   # Output: apple banana
function add_unique_item_to_indexed_array {
    local indexed_array_name="$1"
    local item="$2"

    local -n indexed_array_for_unique_item="$indexed_array_name"

    if is_indexed_array "$indexed_array_name"; then
        if is_var_not_empty "$item"; then
            for existing_item in "${indexed_array_for_unique_item[@]}"; do
                if is_var_equal "$existing_item" "$item"; then
                    return 0
                fi
            done
            indexed_array_for_unique_item+=("$item")
            return 0
        else
            print_stderr "The item to add is empty." "warn"
        fi
    fi
    return 1
}

# Prints all items of the specified indexed array if it is not empty.
# If the array is empty, prints an empty line.
#
# Parameters:
#   $1 - The name of the indexed array whose items should be printed (string).
#
# Returns:
#   0 if the function executed successfully (regardless of whether the array is empty or not).
#   1 if the specified variable is not an indexed array or does not exist.
#
# Example:
#   declare -a colors=("red" "green" "blue")
#   print_indexed_array "colors"
#   # Output:
#   # red
#   # green
#   # blue
function print_indexed_array {
    local indexed_array_name="$1"

    local -n indexed_array_of_items="$indexed_array_name"

    if is_indexed_array "$indexed_array_name"; then
        if is_array_not_empty "$indexed_array_name"; then
            for item in "${indexed_array_of_items[@]}"; do
                echo "$item"
            done
        else
            echo ""
        fi
        return 0
    fi
    return 1
}

# ┌─────────────────────┬──────────────────────┐
# │              ASSOCIATIVE ARRAYS            │
# └─────────────────────┴──────────────────────┘

# Adds a key-value pair to the specified associative array.
#
# Parameters:
#   $1 - The name of the associative array to which the key-value pair should be added (string).
#   $2 - The key to add to the associative array (string).
#   $3 - The value to associate with the key in the associative array (string).
#
# Returns:
#   0 if the key-value pair is successfully added to the associative array.
#   1 if the variable is not an associative array, the key or value is empty, or an error occurs.
#
# Example:
#   declare -A color_codes
#   add_key_value_pair_to_assoc_array "color_codes" "red" "#FF0000"
function add_key_value_pair_to_assoc_array {
    local assoc_array_name="$1"
    local key="$2"
    local value="$3"

    local -n array_for_new_key_value="$assoc_array_name"

    local message_for_add_process_aborted="Add process aborted."

    if is_assoc_array "$assoc_array_name"; then
        if is_var_not_empty "$key" && is_var_not_empty "$value"; then
            if contains_not_key_in_assoc_array "$assoc_array_name" "$key"; then
                # shellcheck disable=SC2034
                array_for_new_key_value["$key"]="$value"
                return 0
            else
                print_stderr "$message_for_add_process_aborted Key '$key' already exists in '$assoc_array_name'." "warn"
            fi
        else
            print_stderr "$message_for_add_process_aborted Key ('$key') and value ('$value') must both be non-empty." "warn"
        fi
    fi
    return 1
}

# Updates the value associated with a given key in the specified associative array.
#
# Parameters:
#   $1 - The name of the associative array to update (string).
#   $2 - The key whose associated value should be updated (string).
#   $3 - The new value to associate with the key in the associative array (string).
#
# Returns:
#   0 if the key-value pair is successfully updated in the associative array.
#   1 if the variable is not an associative array, the key or value is empty, the key does not exist, or an error occurs.
#
# Example:
#   declare -A color_codes=([red]="#FF0000" [green]="#00FF00" [blue]="#0000FF")
#   update_key_value_pair_in_assoc_array "color_codes" "green" "#00FFFF"
#   echo "${color_codes[green]}"
#   # Output: #00FFFF
function update_key_value_pair_in_assoc_array {
    local assoc_array_name="$1"
    local key="$2"
    local value="$3"

    local -n array_for_update="$assoc_array_name"

    local message_for_update_process_aborted="Update process aborted."

    if is_assoc_array "$assoc_array_name"; then
        if is_var_not_empty "$key" && is_var_not_empty "$value"; then
            if contains_key_in_assoc_array "$assoc_array_name" "$key"; then
                # shellcheck disable=SC2034
                array_for_update["$key"]="$value"
                return 0
            else
                print_stderr "$message_for_update_process_aborted Key '$key' does not exist in '$assoc_array_name'." "warn"
            fi
        else
            print_stderr "$message_for_update_process_aborted Key ('$key') and value ('$value') must both be non-empty." "warn"
        fi
    fi
    return 1
}

# Adds a key-value pair to the specified associative array or updates the value if the key already exists.
#
# Parameters:
#   $1 - The name of the associative array to update (string).
#   $2 - The key to add or update in the associative array (string).
#   $3 - The value to associate with the key in the associative array (string).
#
# Returns:
#   0 if the key-value pair is successfully added or updated in the associative array.
#   1 if the variable is not an associative array, the key or value is empty, or an error occurs.
#
# Example:
#   declare -A color_codes
#   add_or_update_key_value_pair_in_assoc_array "color_codes" "green" "#00FF00"
#   add_or_update_key_value_pair_in_assoc_array "color_codes" "green" "#00FFFF"
#   echo "${color_codes[green]}"
#   # Output: #00FFFF
function add_or_update_key_value_pair_in_assoc_array {
    local assoc_array_name="$1"
    local key="$2"
    local value="$3"

    local -n array_for_add_or_update="$assoc_array_name"

    local message_for_add_or_update_process_aborted="Add or update process aborted."

    if is_assoc_array "$assoc_array_name"; then
        if is_var_not_empty "$key" && is_var_not_empty "$value"; then
            # shellcheck disable=SC2034
            array_for_add_or_update["$key"]="$value"
            return 0
        else
            print_stderr "$message_for_add_or_update_process_aborted Key ('$key') and value ('$value') must both be non-empty." "warn"
        fi
    fi
    return 1
}

# Deletes the key-value pair associated with a given key from the specified associative array.
#
# Parameters:
#   $1 - The name of the associative array to update (string).
#   $2 - The key whose associated value should be deleted (string).
#
# Returns:
#   0 if the key-value pair is successfully deleted from the associative array.
#   1 if the variable is not an associative array, the key is empty, the key does not exist, or an error occurs.
#
# Example:
#   declare -A color_codes=([red]="#FF0000" [green]="#00FF00" [blue]="#0000FF")
#   delete_key_value_pair_by_key_from_assoc_array "color_codes" "green"
#   echo "${color_codes[green]}"
function delete_key_value_pair_by_key_from_assoc_array {
    local assoc_array_name="$1"
    local key="$2"

    # shellcheck disable=SC2034
    local -n array_for_removal="$assoc_array_name"

    local message_for_removal_process_aborted="Deletion process aborted."

    if is_assoc_array "$assoc_array_name"; then
        if is_var_not_empty "$key"; then
            if contains_key_in_assoc_array "$assoc_array_name" "$key"; then
                unset "array_for_removal[\"$key\"]"
                return 0
            else
                print_stderr "$message_for_removal_process_aborted Key '$key' does not exist in '$assoc_array_name'." "warn"
            fi
        else
            print_stderr "$message_for_removal_process_aborted Key ('$key') must be non-empty." "warn"
        fi
    fi
    return 1
}

# Retrieves the key associated with a given value in an associative array.
# If multiple keys have the same value, only the first matching key is returned.
#
# Parameters:
#   $1 - The name of the associative array to search within (string).
#   $2 - The value to search for in the associative array.
#
# Returns:
#   0 if the function successfully found the key and printed it, or if the value is not found but no errors occurred.
#   1 if the specified variable is not an associative array or does not exist.
#
# Example:
#   declare -A color_codes=([red]="#FF0000" [green]="#00FF00" [blue]="#0000FF")
#   get_key_by_value_from_assoc_array "color_codes" "#00FF00"
#   # Output:
#   # green
function get_key_by_value_from_assoc_array {
    local assoc_array_name="$1"
    local search_value="$2"

    local -n array_for_key="$assoc_array_name"

    if is_assoc_array "$assoc_array_name"; then
        for key in "${!array_for_key[@]}"; do
            if is_var_equal "${array_for_key[$key]}" "$search_value"; then
                echo "$key"
                return 0
            fi
        done
        echo ""
        return 0
    fi
    return 1
}

# Retrieves the value associated with a given key from an associative array.
# If the key does not exist, prints an empty string.
#
# Parameters:
#   $1 - The name of the associative array to search within (string).
#   $2 - The key whose associated value is to be retrieved (string).
#
# Returns:
#   0 if the function successfully retrieved and printed the value, or if the key does not exist but no errors occurred.
#   1 if the specified variable is not an associative array or does not exist.
#
# Example:
#   declare -A color_codes=([red]="#FF0000" [green]="#00FF00" [blue]="#0000FF")
#   get_value_by_key_from_assoc_array "color_codes" "green"
#   # Output:
#   # #00FF00
function get_value_by_key_from_assoc_array {
    local assoc_array_name="$1"
    local search_key="$2"

    local -n array_for_value="$assoc_array_name"

    if is_assoc_array "$assoc_array_name"; then
        if contains_key_in_assoc_array "$assoc_array_name" "$search_key"; then
            echo "${array_for_value[$search_key]}"
        else
            echo ""
        fi
        return 0
    fi
    return 1
}

# Prints the contents of an associative array, sorted by its values in descending order (if possible).
# Each key-value pair is printed on a new line in the format "key: value".
#
# Parameters:
#   $1 - The name of the associative array to be printed (string).
#
# Returns:
#   0 if the function executed successfully and the associative array was printed.
#   1 if the specified variable is not an associative array or does not exist.
#
# Example:
#   declare -A scores=([Alice]=90 [Bob]=75 [Charlie]=85)
#   print_assoc_array "scores"
#   # Output:
#   # Alice: 90
#   # Charlie: 85
#   # Bob: 75
function print_assoc_array {
    local assoc_array_name="$1"

    local -n array="$assoc_array_name"

    if is_assoc_array "$assoc_array_name"; then
        local sorted_keys
        sorted_keys=$(for key in "${!array[@]}"; do
            echo "$key ${array[$key]}"
        done | sort -k2 -nr | awk '{print $1}')

        for key in $sorted_keys; do
            echo "$key: ${array[$key]}"
        done

        return 0
    fi

    return 1
}

# ┌─────────────────────┬──────────────────────┐
# │                   LISTS                    │
# └─────────────────────┴──────────────────────┘

# This function is essentially a renamed version of the `add_item_to_indexed_array` function.
function add_item_to_list {
    add_item_to_indexed_array "$@"
}

# This function is essentially a renamed version of the `add_unique_item_to_indexed_array` function.
function add_unique_item_to_list {
    add_unique_item_to_indexed_array "$@"
}

# This function is essentially a renamed version of the `print_indexed_array` function.
function print_list {
    print_indexed_array "$@"
}

# ┌─────────────────────┬──────────────────────┐
# │                DICTIONARIES                │
# └─────────────────────┴──────────────────────┘

# This function is essentially a renamed version of the `add_key_value_pair_to_assoc_array` function.
function add_key_value_pair_to_dict {
    add_key_value_pair_to_assoc_array "$@"
}

# This function is essentially a renamed version of the `update_key_value_pair_in_assoc_array` function.
function update_key_value_pair_in_dict {
    update_key_value_pair_in_assoc_array "$@"
}

# This function is essentially a renamed version of the `add_or_update_key_value_pair_in_assoc_array` function.
function add_or_update_key_value_pair_in_dict {
    add_or_update_key_value_pair_in_assoc_array "$@"
}

# This function is essentially a renamed version of the `delete_key_value_pair_by_key_from_assoc_array` function.
function delete_key_value_pair_by_key_from_dict {
    delete_key_value_pair_by_key_from_assoc_array "$@"
}

# This function is essentially a renamed version of the `get_key_by_value_from_assoc_array` function.
function get_key_by_value_from_dict {
    get_key_by_value_from_assoc_array "$@"
}

# This function is essentially a renamed version of the `get_value_by_key_from_assoc_array` function.
function get_value_by_key_from_dict {
    get_value_by_key_from_assoc_array "$@"
}

# This function is essentially a renamed version of the `print_assoc_array` function.
function print_dict {
    print_assoc_array "$@"
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║     FUNCTIONS FOR PATH VARIABLE TYPES      ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │                   PATHS                    │
# └─────────────────────┴──────────────────────┘

# Normalizes the specified file path by reducing multiple consecutive slashes to a single slash.
#
# Parameters:
#   $1 - The file path to be normalized (string).
#
# Returns:
#   The normalized file path with multiple consecutive slashes replaced by a single slash.
#
# Example:
#   result=$(normalize_path "/path//to///file")
#   echo "$result"  # Output: /path/to/file
function normalize_path {
    echo "$1" | sed -E 's#/{2,}#/#g'
}

# ┌─────────────────────┬──────────────────────┐
# │                   FILES                    │
# └─────────────────────┴──────────────────────┘

# Extracts the basename without file extensions from a file path.
#
# Parameters:
#   $1 - The file path from which to extract the basename (string).
#
# Returns:
#   The basename without file extensions.
#
# Example:
#   result=$(extract_basename_without_file_extensions_from_file "/path/to/file.txt.txt")
#   echo "$result"  # Output: file
function extract_basename_without_file_extensions_from_file {
    local file="$1"

    if is_var_empty "$file"; then
        print_stderr "File path is empty." "warn"
        return 1
    fi

    local basename_without_file_extensions
    basename_without_file_extensions="$(basename "$file")"

    while [[ "$basename_without_file_extensions" == *.* ]]; do
        basename_without_file_extensions="${basename_without_file_extensions%.*}"
    done

    echo "$basename_without_file_extensions"
}

# Appends a line of text to a specified file, creating the file and necessary directories if they do not exist.
#
# Usage:
#   write_line_to_file "/tmp/test/test.txt" "Test Text"
#   # This will append "Test Text" to the file located at '/tmp/test/test.txt'.
#   # If the directory '/tmp/test/' does not exist, it will be created.
#   # If the file does not exist, it will be created.
function write_line_to_file {
    local file="$1"
    local line="$2"

    if path_not_exists "$file"; then
        local dir_for_file
        dir_for_file="$(dirname "$file")"

        if directory_not_exists "$dir_for_file"; then
            mkdir -p "$dir_for_file" || {
                print_stderr "Unable to create directory '$dir_for_file'" "error"
                ENABLE_SUMMARY_ON_EXIT=false
                exit 1
            }
        fi

        touch "$file" || {
            print_stderr "Unable to create file '$file'" "error"
            ENABLE_SUMMARY_ON_EXIT=false
            exit 1
        }
    fi

    # Append the line to the file
    echo "$line" >>"$file" || {
        print_stderr "Unable to write to file '$file'" "error"
        ENABLE_SUMMARY_ON_EXIT=false
        exit 1
    }
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║          ADDITIONAL HELP FUNCTIONS         ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# Prints all available functions in the current script.
#
# Usage:
#   print_available_functions
function print_available_functions {
    for func in $(declare -F | awk '{print $3}'); do
        if [[ ! "$func" =~ ^_ ]]; then
            echo "$func"
        fi
    done
}

# Checks if the specified package is installed.
#
# Parameters:
#   $1 - The name of the package to check (string).
#
# Returns:
#   0 if the package is installed.
#   1 if the package is not installed.
#
# Example:
#   if is_package_installed "yad"; then
#       echo "The package 'yad' is installed."
#   else
#       echo "The package 'yad' is not installed."
#   fi
function is_package_installed {
    local package_name="$1"
    if is_var_not_empty "$package_name"; then
        if command -v "$package_name" &>/dev/null; then
            return 0
        fi
    else
        print_stderr "Package name is empty." "warn"
    fi
    return 1
}

# ┌─────────────────────┬──────────────────────┐
# │                POPUP TOOLS                 │
# └─────────────────────┴──────────────────────┘

function get_available_popup_tool {
    local popup_tools=("yad" "zenity")

    local tool_found=""

    for tool in "${popup_tools[@]}"; do
        if is_package_installed "$tool"; then
            tool_found="$tool" # Set the name of the found tool
            break              # No need to check further
        fi
    done

    # Return the first found tool or empty if none found
    echo "$tool_found"
}

# ┌─────────────────────┬──────────────────────┐
# │                   COLORS                   │
# └─────────────────────┴──────────────────────┘

# Retrieves the ANSI color code for a specified color and style.
#
# Usage:
#   get_color_code "red" "bold"
#   # This will retrieve the ANSI color code for red text in bold style.
function get_color_code {
    local color="$1"
    local style="${2:-regular}"

    local color_code="${CONST_ANSI_COLORS[${color}, ${style}]}"

    if is_var_empty "$color_code"; then
        print_stderr "Color ('$color') or style ('$style') not found!" "warn"
        return 1
    fi

    echo "$color_code"
}

# Prints the given text to the console with the specified color and style.
#
# Usage:
#   print_colored_text "Hello, World!" "red" "bold"
#   # This will print "Hello, World!" in red and bold text.
function print_colored_text {
    local text="$1"
    local color="${2:-reset}"
    local style="${3:-regular}"

    local color_code
    if color_code=$(get_color_code "$color" "$style"); then
        echo -e "${color_code}${text}${CONST_COLOR_CODE_FOR_RESETTING_FOREGROUND_AND_BACKGROUND}"
    else
        print_stderr "Unable to print text with color '$color' and style '$style': No matching color code found for '$color, $style'!" "warn"
        echo -e "${CONST_COLOR_CODE_FOR_RESETTING_FOREGROUND_AND_BACKGROUND}${text}${CONST_COLOR_CODE_FOR_RESETTING_FOREGROUND_AND_BACKGROUND}"
        return 1
    fi
}

# Prints all color combinations.
#
# Usage:
#   print_all_color_combinations
function print_all_color_combinations {
    local colors=("black" "red" "green" "yellow" "blue" "purple" "cyan" "white")
    local styles=("regular" "bold" "underline" "background" "high_intensity" "bold_high_intensity" "high_intensity_background")

    for color in "${colors[@]}"; do
        for style in "${styles[@]}"; do
            local color_code="$color,$style"
            local text=$color_code

            print_colored_text "$text" "$color" "$style" || print_stderr "'$color_code' is not supported!" "warn"
        done
        echo
    done

    print_colored_text "Reset colors with: 'color'=\"reset\" and 'style'=\"regular\"" "reset" "regular"
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░      INTERNAL PRINTING FOR FAILURES      ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

function _print_internal_error {
    local error_message="$1"
    print_stderr "[INTERNAL $(to_uppercase "$CONST_SIMBASHLOG_NAME") ERROR] - ${error_message}" "error"
    ENABLE_SUMMARY_ON_EXIT=false
    exit 1
}

function _print_internal_warning {
    local warning_message="$1"
    print_stderr "[INTERNAL $(to_uppercase "$CONST_SIMBASHLOG_NAME") WARN] - ${warning_message}" "warn"
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░               VALIDATIONS                ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║             MUTABLE VARIABLES              ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

declare -rx CONST_MIN_ALLOWED_SEVERITY_CODE=0
declare -rx CONST_MAX_ALLOWED_SEVERITY_CODE=7

function _validate_enable_log_file {
    is_boolean "$ENABLE_LOG_FILE"
}

function _validate_enable_json_log_file {
    is_boolean "$ENABLE_JSON_LOG_FILE"
}

function _validate_enable_log_to_system {
    is_boolean "$ENABLE_LOG_TO_SYSTEM"
}

function _validate_log_dir {
    if is_var_empty "$LOG_DIR"; then
        return 1
    fi

    if path_not_ends_with_slash "$LOG_DIR"; then
        LOG_DIR="${LOG_DIR}/"
    fi

    return 0
}

function _validate_enable_simple_log_dir_structure {
    is_boolean "$ENABLE_SIMPLE_LOG_DIR_STRUCTURE"
}

function _validate_enable_combined_log_files {
    is_boolean "$ENABLE_COMBINED_LOG_FILES"
}

function _validate_log_level {
    is_numeric_in_range "$LOG_LEVEL" "$CONST_MIN_ALLOWED_SEVERITY_CODE" "$CONST_MAX_ALLOWED_SEVERITY_CODE"
}

function _validate_log_level_for_system_logging {
    is_numeric_in_range "$LOG_LEVEL_FOR_SYSTEM_LOGGING" "$CONST_MIN_ALLOWED_SEVERITY_CODE" "$CONST_MAX_ALLOWED_SEVERITY_CODE"
}

function _validate_facility_name_for_system_logging {
    case "$FACILITY_NAME_FOR_SYSTEM_LOGGING" in
    auth | \
        authpriv | \
        cron | \
        daemon | \
        ftp | \
        kern | \
        lpr | \
        mail | \
        news | \
        syslog | \
        user | \
        uucp | \
        local0 | \
        local1 | \
        local2 | \
        local3 | \
        local4 | \
        local5 | \
        local6 | \
        local7 | \
        security)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

function _validate_enable_exiting_script_if_at_least_error_is_logged {
    is_boolean "$ENABLE_EXITING_SCRIPT_IF_AT_LEAST_ERROR_IS_LOGGED"
}

function _validate_enable_date_in_console_outputs_for_logging {
    is_boolean "$ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING"
}

function _validate_show_current_script_name_in_console_outputs_for_logging {
    case "$SHOW_CURRENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING" in
    path | \
        simple | \
        simple_without_file_extension | \
        absolute)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

function _validate_enable_parent_script_name_in_console_outputs_for_logging {
    is_boolean "$ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING"
}

function _validate_enable_gui_popups_for_logging_notifications {
    is_boolean "$ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS"
}

function _validate_log_popup_notification_window_width {
    is_numeric_and_greater_than_zero "$LOG_POPUP_NOTIFICATION_WINDOW_WIDTH"
}

function _validate_log_popup_notification_window_height {
    is_numeric_and_greater_than_zero "$LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT"
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║        ALL MUTABLE VARIABLES AT ONCE       ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

function _validate_user_input_for_logging {
    _validate_enable_log_file ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_LOG_FILE") must be 'true' or 'false'."

    _validate_enable_json_log_file ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_JSON_LOG_FILE") must be 'true' or 'false'."

    _validate_enable_log_to_system ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_LOG_TO_SYSTEM") must be 'true' or 'false'."

    _validate_log_dir ||
        _print_internal_error "'LOG_DIR' is empty or not properly formatted."

    _validate_enable_simple_log_dir_structure ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_SIMPLE_LOG_DIR_STRUCTURE") must be 'true' or 'false'."

    _validate_enable_combined_log_files ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_COMBINED_LOG_FILES") must be 'true' oder 'false'."

    _validate_log_level ||
        _print_internal_error "$(print_var_with_current_value "LOG_LEVEL") must be numeric between $CONST_MIN_ALLOWED_SEVERITY_CODE and $CONST_MAX_ALLOWED_SEVERITY_CODE."

    _validate_log_level_for_system_logging ||
        _print_internal_error "$(print_var_with_current_value "LOG_LEVEL_FOR_SYSTEM_LOGGING") must be numeric between $CONST_MIN_ALLOWED_SEVERITY_CODE and $CONST_MAX_ALLOWED_SEVERITY_CODE."

    _validate_facility_name_for_system_logging ||
        _print_internal_error "$(print_var_with_current_value "FACILITY_NAME_FOR_SYSTEM_LOGGING") is invalid. See 'man logger' for more information."

    _validate_enable_exiting_script_if_at_least_error_is_logged ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_EXITING_SCRIPT_IF_AT_LEAST_ERROR_IS_LOGGED") must be 'true' or 'false'."

    _validate_enable_date_in_console_outputs_for_logging ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING") must be 'true' or 'false'."

    _validate_show_current_script_name_in_console_outputs_for_logging ||
        _print_internal_error "$(print_var_with_current_value "SHOW_CURRENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING") must be 'path', 'simple', 'simple_without_file_extension', or 'absolute'."

    _validate_enable_parent_script_name_in_console_outputs_for_logging ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING") must be 'true' or 'false'."

    _validate_enable_gui_popups_for_logging_notifications ||
        _print_internal_error "$(print_var_with_current_value "ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS") must be 'true' or 'false'."

    _validate_log_popup_notification_window_width ||
        _print_internal_error "$(print_var_with_current_value "LOG_POPUP_NOTIFICATION_WINDOW_WIDTH") must be numeric and greater than zero."

    _validate_log_popup_notification_window_height ||
        _print_internal_error "$(print_var_with_current_value "LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT") must be numeric and greater than zero."
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║          ADDITIONAL VALIDATIONS            ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

function _is_package_for_json_logging_installed {
    local required_package_for_json_logging="$CONST_SIMBASHLOG_REQUIRED_EXTERNAL_PACKAGE_FOR_JSON_LOGGING"

    is_package_installed "$required_package_for_json_logging" ||
        _print_internal_error "Required package ('$required_package_for_json_logging') for JSON logs is not installed. Please install it and try again."
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░              GET ARGUMENTS               ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

declare -x _ARG_SEVERITY=""
declare -x _ARG_MESSAGE=""

function _get_arguments_and_validate {
    local arg_which_is_processed=""
    local message_with_help_information="Use '-h' or '--help' for more information."

    function _validate_if_value_is_short_argument {
        local value="$1"
        if [[ "$value" == "-"* && "$value" != "--"* ]]; then
            _print_internal_error "'${arg_which_is_processed}': Invalid value ('$value')! Value must not start with '-'."
        fi
    }

    function _validate_if_value_is_long_argument {
        local value="$1"
        if [[ "$value" == "--"* ]]; then
            _print_internal_error "'${arg_which_is_processed}': Invalid value ('$value')! Value must not start with '--'."
        fi
    }

    function _validate_if_value_is_argument {
        local value="$1"
        _validate_if_value_is_short_argument "$value"
        _validate_if_value_is_long_argument "$value"
    }

    local note_for_notifier="Note: '--notifier' should be used before this, otherwise it has no effect"
    local notifier_enabled=false
    function _is_used_without_notifier {
        if is_false "$notifier_enabled"; then
            _print_internal_warning "'$arg_which_is_processed': Should only be used if '--notifier' is used before, e.g. '... --notifier ... $arg_which_is_processed ...'."
        fi
    }

    local note_for_valid_actions_for_normal_logging="Note: '-a, --action' should be used before and set to 'console' 'log', 'json' or 'all', otherwise it has no effect"
    local is_normal_logging_enabled=false
    function _is_used_without_valid_action_for_normal_logging {
        if is_false "$is_normal_logging_enabled"; then
            _print_internal_warning "'$arg_which_is_processed': Should only be used if '-a, --action' is used before and set to 'console' 'log', 'json' or 'all', e.g. '... -a log $arg_which_is_processed ...'."
        fi
    }

    local note_for_valid_actions_for_system_logging="Note: '-a, --action' should be used before this and set to 'system' or 'all', otherwise it has no effect"
    local is_system_logging_enabled=false
    function _is_used_without_valid_action_for_system_logging {
        if is_false "$is_system_logging_enabled"; then
            _print_internal_warning "'$arg_which_is_processed': Should only be used if '-a, --action' is used before and set to 'system' or 'all', e.g. '... -a system $arg_which_is_processed ...'."
        fi
    }

    local note_for_valid_actions_for_log_files="Note: '-a, --action' should be used before this and set to 'log', 'json' or 'all', otherwise it has no effect"
    local log_files_enabled=false
    function _is_used_without_valid_action_for_log_files {
        if is_false "$log_files_enabled"; then
            _print_internal_warning "'$arg_which_is_processed': Should only be used if '-a, --action' is used before and set to 'log', 'json' or 'all', e.g. '... -a log $arg_which_is_processed ...'."
        fi
    }

    local note_for_script_name="Note: '--script-name' should be used before this, otherwise it has no effect"
    local script_name_enabled=false
    function _is_used_without_script_name {
        if is_false "$script_name_enabled"; then
            _print_internal_warning "'$arg_which_is_processed': Should only be used if '--script-name' is used before, e.g. '... --script-name ... $arg_which_is_processed ...'."
        fi
    }

    local note_for_gui_popups="Note: '--gui' should be used before this, otherwise it has no effect"
    local gui_enabled=false
    function _is_used_without_enabled_gui_popups {
        if is_false "$gui_enabled"; then
            _print_internal_warning "'$arg_which_is_processed': Should only be used if '--gui' is used before, i.e. '... --gui $arg_which_is_processed ...'."
        fi
    }

    function _print_internal_warning_for_arg_is_empty {
        _print_internal_warning "'$arg_which_is_processed' is empty. If you don't want to use it, don't use '$arg_which_is_processed'."
    }

    while [[ $# -gt 0 ]]; do
        case $1 in
        -h | --help)
            echo "Version: $CONST_SIMBASHLOG_VERSION"
            echo
            _show_donate_message
            echo
            echo "Usage: (sudo) $CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION"
            echo
            echo "  -h, --help                                      Show help"
            echo
            echo "  -v, --version                                   Show version"
            echo
            echo "  -a, --action            [action]                Action for logging"
            echo "                                                  {console,log,json,system,all}"
            echo "                                                  Important: Json logging can lead to performance problems"
            echo "                                                  Note: There will always be an output on the console"
            echo "                                                  Addition for 'system': If '--script-name' was used, this is the tag that can be searched for."
            echo "                                                                         Otherwise the absolute path of '$CONST_SIMBASHLOG_NAME' is used."
            echo
            echo "  -s, --severity          [severity]              Severity for logging"
            echo "                                                  {"
            echo "                                                      debug,  7,"
            echo "                                                      info,   6,"
            echo "                                                      notice, 5,"
            echo "                                                      warn,   4,"
            echo "                                                      error,  3,"
            echo "                                                      crit,   2,"
            echo "                                                      alert,  1,"
            echo "                                                      emerg,  0"
            echo "                                                  }"
            echo
            echo "  -m, --message           [message]               Message to be logged"
            echo
            echo "  --notifier              [notifier]              '$CONST_SIMBASHLOG_NAME' notifier ($CONST_SIMBASHLOG_NOTIFIERS_GITHUB_LINK)"
            echo "                                                  Important: The notifier must be correctly installed"
            echo
            echo "  --notifier-config       [notifier config]       '$CONST_SIMBASHLOG_NAME' notifier configuration path"
            echo "                                                  Important: The path will be passed to the notifier"
            echo "                                                  $note_for_notifier"
            echo "                                                  Default: The default configuration file of the notifier"
            echo
            echo "  --enable-date-in-console-output                 Enable date in console output"
            echo
            echo "  --log-level             [log level]             Log level"
            echo "                                                  {0,1,2,3,4,5,6,7}"
            echo "                                                  $note_for_valid_actions_for_normal_logging"
            echo "                                                  Default: '$LOG_LEVEL'"
            echo
            echo "  --system-log-level      [system log level]      Log level for system logging"
            echo "                                                  {0,1,2,3,4,5,6,7}"
            echo "                                                  $note_for_valid_actions_for_system_logging"
            echo "                                                  Default: '$LOG_LEVEL_FOR_SYSTEM_LOGGING'"
            echo
            echo "  --facility              [facility]              Facility name for system logging"
            echo "                                                  'logger' facility names ('man logger'):"
            echo "                                                  {"
            echo "                                                      auth,authpriv,cron,"
            echo "                                                      daemon,ftp,kern,"
            echo "                                                      lpr,mail,news,syslog,user,uucp,"
            echo "                                                      local0,local1,local2,local3,local4,local5,local6,local7,"
            echo "                                                      security"
            echo "                                                  }"
            echo "                                                  $note_for_valid_actions_for_system_logging"
            echo "                                                  Default: '$FACILITY_NAME_FOR_SYSTEM_LOGGING'"
            echo
            # Because the script that is executed by arguments is itself 'simbashlog', it means that the parent script is the script that calls 'simbashlog' with arguments.
            # `PARENT_SCRIPT_NAME`
            echo "  --script-name           [script name]           Script name"
            echo
            # `ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING`
            echo "  --enable-script-name-in-console-output          Enable script name in console output"
            echo "                                                  $note_for_script_name"
            echo
            echo "  --log-dir               [log dir]               Directory path for log files"
            echo "                                                  Important: Be careful! If '--show-log-files' is not used, there is no output where exactly the log files are located"
            echo "                                                  $note_for_valid_actions_for_log_files"
            echo "                                                  Default: '$LOG_DIR'"
            echo
            echo "  --show-log-files                                Show log files after each log operation"
            echo "                                                  $note_for_valid_actions_for_log_files"
            echo
            echo "  --disable-simple-log-dir-structure              Disable simple log dir structure"
            echo "                                                  $note_for_valid_actions_for_log_files"
            echo
            echo "  --enable-combined-log-files                     Enable combined log files"
            echo "                                                  $note_for_valid_actions_for_log_files"
            echo
            echo "  --gui                                           Enable GUI popups for logging notifications with 'zenity' or 'yad'"
            echo
            echo "  --popup-width           [popup width]           Popup window width"
            echo "                                                  $note_for_gui_popups"
            echo "                                                  Default: '$LOG_POPUP_NOTIFICATION_WINDOW_WIDTH'"
            echo
            echo "  --popup-height          [popup height]          Popup window height"
            echo "                                                  $note_for_gui_popups"
            echo "                                                  Default: '$LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT'"
            exit 0
            ;;
        -v | --version)
            echo "$CONST_SIMBASHLOG_VERSION"
            exit 0
            ;;
        -a | --action)
            arg_which_is_processed="$1"
            shift
            _validate_if_value_is_argument "$1"
            case "$1" in
            console)
                is_normal_logging_enabled=true
                ENABLE_LOG_FILE=false
                ENABLE_JSON_LOG_FILE=false
                ENABLE_LOG_TO_SYSTEM=false
                ;;
            log)
                is_normal_logging_enabled=true
                log_files_enabled=true
                ENABLE_LOG_FILE=true
                ENABLE_JSON_LOG_FILE=false
                ENABLE_LOG_TO_SYSTEM=false
                ;;
            json)
                is_normal_logging_enabled=true
                log_files_enabled=true
                ENABLE_LOG_FILE=false
                ENABLE_JSON_LOG_FILE=true
                ENABLE_LOG_TO_SYSTEM=false
                _is_package_for_json_logging_installed
                ;;
            system)
                is_system_logging_enabled=true
                ENABLE_LOG_FILE=false
                ENABLE_JSON_LOG_FILE=false
                ENABLE_LOG_TO_SYSTEM=true
                ;;
            all)
                is_normal_logging_enabled=true
                is_system_logging_enabled=true
                log_files_enabled=true
                ENABLE_LOG_FILE=true
                ENABLE_JSON_LOG_FILE=true
                ENABLE_LOG_TO_SYSTEM=true
                ;;
            *)
                _print_internal_error "'$arg_which_is_processed': The action '$1' is invalid."
                ;;
            esac
            ;;
        -s | --severity)
            arg_which_is_processed="$1"
            shift
            _validate_if_value_is_argument "$1"
            _ARG_SEVERITY="$1"
            case "$_ARG_SEVERITY" in
            debug | 7 | info | 6 | notice | 5 | warn | 4 | error | 3 | crit | 2 | alert | 1 | emerg | 0) ;;
            *)
                _print_internal_error "'$arg_which_is_processed': '$1' is invalid. $message_with_help_information"
                ;;
            esac
            ;;
        -m | --message)
            arg_which_is_processed="$1"
            shift
            _validate_if_value_is_argument "$1"
            _ARG_MESSAGE="$1"
            ! is_var_empty "$_ARG_MESSAGE" || _print_internal_error "'$arg_which_is_processed': Message must not be empty."
            ;;
        --notifier)
            notifier_enabled=true
            arg_which_is_processed="$1"
            shift
            _validate_if_value_is_argument "$1"
            SIMBASHLOG_NOTIFIER="$1"
            ! is_var_empty "$SIMBASHLOG_NOTIFIER" || _print_internal_warning_for_arg_is_empty
            ;;
        --notifier-config)
            arg_which_is_processed="$1"
            _is_used_without_notifier
            shift
            _validate_if_value_is_argument "$1"
            SIMBASHLOG_NOTIFIER_CONFIG_PATH="$1"
            ! is_var_empty "$SIMBASHLOG_NOTIFIER_CONFIG_PATH" || _print_internal_warning_for_arg_is_empty
            ;;
        --enable-date-in-console-output)
            ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING=true
            ;;
        --log-level)
            arg_which_is_processed="$1"
            _is_used_without_valid_action_for_normal_logging
            shift
            _validate_if_value_is_argument "$1"
            LOG_LEVEL="$1"
            _validate_log_level || _print_internal_error "'$arg_which_is_processed': '$1' must be numeric between $CONST_MIN_ALLOWED_SEVERITY_CODE and $CONST_MAX_ALLOWED_SEVERITY_CODE."
            ;;
        --system-log-level)
            arg_which_is_processed="$1"
            _is_used_without_valid_action_for_system_logging
            shift
            _validate_if_value_is_argument "$1"
            LOG_LEVEL_FOR_SYSTEM_LOGGING="$1"
            _validate_log_level_for_system_logging || _print_internal_error "'$arg_which_is_processed': '$1' must be numeric between $CONST_MIN_ALLOWED_SEVERITY_CODE and $CONST_MAX_ALLOWED_SEVERITY_CODE."
            ;;
        --facility)
            arg_which_is_processed="$1"
            _is_used_without_valid_action_for_system_logging
            shift
            _validate_if_value_is_argument "$1"
            FACILITY_NAME_FOR_SYSTEM_LOGGING="$1"
            _validate_facility_name_for_system_logging || _print_internal_error "'$arg_which_is_processed': '$1' is not a valid facility name. $message_with_help_information"
            ;;
        --script-name)
            script_name_enabled=true
            arg_which_is_processed="$1"
            shift
            _validate_if_value_is_argument "$1"
            PARENT_SCRIPT_NAME="$1"
            ! is_var_empty "$PARENT_SCRIPT_NAME" || _print_internal_warning_for_arg_is_empty
            ;;
        --enable-script-name-in-console-output)
            _is_used_without_script_name
            ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING=true
            ;;
        --log-dir)
            arg_which_is_processed="$1"
            _is_used_without_valid_action_for_log_files
            shift
            _validate_if_value_is_argument "$1"
            LOG_DIR="$1"
            _validate_log_dir || _print_internal_error "'$arg_which_is_processed': Log dir must not be empty."
            ;;
        --show-log-files)
            arg_which_is_processed="$1"
            _is_used_without_valid_action_for_log_files
            ENABLE_SUMMARY_ON_EXIT=true
            ;;
        --disable-simple-log-dir-structure)
            arg_which_is_processed="$1"
            _is_used_without_valid_action_for_log_files
            ENABLE_SIMPLE_LOG_DIR_STRUCTURE=false
            ;;
        --enable-combined-log-files)
            arg_which_is_processed="$1"
            _is_used_without_valid_action_for_log_files
            ENABLE_COMBINED_LOG_FILES=true
            ;;
        --gui)
            gui_enabled=true
            ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS=true
            ;;
        --popup-width)
            arg_which_is_processed="$1"
            _is_used_without_enabled_gui_popups
            shift
            _validate_if_value_is_long_argument "$1"
            LOG_POPUP_NOTIFICATION_WINDOW_WIDTH="$1"
            _validate_log_popup_notification_window_width || _print_internal_error "'$arg_which_is_processed': '$1' must be numeric and greater than zero."
            ;;
        --popup-height)
            arg_which_is_processed="$1"
            _is_used_without_enabled_gui_popups
            shift
            _validate_if_value_is_long_argument "$1"
            LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT="$1"
            _validate_log_popup_notification_window_height || _print_internal_error "'$arg_which_is_processed': '$1' must be numeric and greater than zero."
            ;;
        *)
            if [[ "$1" == "-"* ]]; then
                _print_internal_error "Invalid argument: '$1'"
            fi
            ;;
        esac
        shift
    done
}

declare -x _ARGS_PASSED=false

if [[ $# -gt 0 ]]; then
    _ARGS_PASSED=true
    PARENT_SCRIPT_NAME=""
    _get_arguments_and_validate "$@"
fi

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░                SEVERITIES                ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# RFC 5424
#
# | Numerical Code | Severity      | Description                      |
# |----------------|---------------|----------------------------------|
# | 0              | Emergency     | System is unusable               |
# | 1              | Alert         | Action must be taken immediately |
# | 2              | Critical      | Critical conditions              |
# | 3              | Error         | Error conditions                 |
# | 4              | Warning       | Warning conditions               |
# | 5              | Notice        | Normal but significant condition |
# | 6              | Informational | Informational messages           |
# | 7              | Debug         | Debug-level messages             |

declare -Arx CONST_SEVERITIES=(
    ['DEBUG']=7
    ['INFO']=6
    ['NOTICE']=5
    ['WARN']=4
    ['ERROR']=3
    ['CRIT']=2
    ['ALERT']=1
    ['EMERG']=0
)

# Retrieves the severity name for a given numeric severity code.
#
# Usage:
#   get_severity_name 0
#   # This will return 'EMERG'.
function get_severity_name {
    local code="$1"

    if is_not_numeric "$code"; then
        _print_internal_warning "Invalid input '$code'. Must be a numeric code."
        return 1
    fi

    if ! get_key_by_value_from_dict CONST_SEVERITIES "$code"; then
        _print_internal_warning "Severity code '$code' not found."
        return 1
    fi
}

# Retrieves the numeric severity code for a given severity name and ensures case-insensitivity.
#
# Usage:
#   get_severity_code error
#   # This will return 3.
#
#   get_severity_code "error"
#   # This will return 3.
#
#   get_severity_code "ERROR"
#   # This will also return 3, demonstrating case-insensitivity.
function get_severity_code {
    local name="$1"

    name="$(to_uppercase "$name")"

    if ! get_value_by_key_from_dict CONST_SEVERITIES "$name"; then
        _print_internal_warning "Severity name '$name' not found."
        return 1
    fi
}

# Prints the severity levels in descending order of their associated values.
#
# Usage:
#   print_severities
function print_severities {
    echo "Severity Levels:"
    print_dict CONST_SEVERITIES
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░                COUNTERS                  ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

declare -Ax _TOTAL_LOG_COUNTER

declare -Ax _LOG_COUNTER_FOR_SYSTEM_LOGGING
declare -Ax _LOG_COUNTER_FOR_LOGGING_TO_LOG_FILES
declare -Ax _LOG_COUNTER_FOR_LOGGING_TO_JSON_LOG_FILES

for severity in "${!CONST_SEVERITIES[@]}"; do
    add_key_value_pair_to_dict _TOTAL_LOG_COUNTER "$severity" 0
    add_key_value_pair_to_dict _LOG_COUNTER_FOR_SYSTEM_LOGGING "$severity" 0
    add_key_value_pair_to_dict _LOG_COUNTER_FOR_LOGGING_TO_LOG_FILES "$severity" 0
    add_key_value_pair_to_dict _LOG_COUNTER_FOR_LOGGING_TO_JSON_LOG_FILES "$severity" 0
done

function _get_key_for_a_log_counter {
    local input="$1"
    local severity_name
    local severity_code

    if is_numeric "$input"; then
        if ! severity_name="$(get_severity_name "$input")"; then
            return 1
        fi
    else
        if ! severity_code="$(get_severity_code "$input")"; then
            return 1
        fi

        if ! severity_name="$(get_severity_name "$severity_code")"; then
            return 1
        fi
    fi

    echo "$severity_name"
}

function _get_value_from_a_log_counter {
    local log_counter_name="$1"
    local input="$2"

    local process_canceled="The process to get the counter entry was canceled."
    local severity_name

    if ! severity_name="$(_get_key_for_a_log_counter "$input")"; then
        _print_internal_warning "Severity level '$severity_name' not found. $process_canceled"
        return 1
    fi

    if ! get_value_by_key_from_dict "$log_counter_name" "$severity_name"; then
        _print_internal_warning "No counter entry for severity level '$severity_name' found. $process_canceled"
        return 1
    fi
}

function _increment_a_log_counter {
    local log_counter_name="$1"
    local input="$2"

    local process_canceled="The process to increment the counter entry was canceled."
    local severity_name

    if ! severity_name="$(_get_key_for_a_log_counter "$input")"; then
        _print_internal_warning "Severity level '$input' not found. $process_canceled"
        return 1
    fi

    local counter_value
    if counter_value="$(_get_value_from_a_log_counter "$log_counter_name" "$severity_name")"; then
        counter_value=$((counter_value + 1))
        update_key_value_pair_in_dict "$log_counter_name" "$severity_name" "$counter_value"

        if total_counter_value="$(_get_value_from_a_log_counter "_TOTAL_LOG_COUNTER" "$severity_name")"; then
            total_counter_value=$((total_counter_value + 1))
            update_key_value_pair_in_dict "_TOTAL_LOG_COUNTER" "$severity_name" "$total_counter_value"
            return 0
        fi
    fi
    return 1
}

function _are_all_entries_zero_from_a_log_counter {
    local log_counter_name="$1"
    local -n log_counter="$log_counter_name"

    for entry in "${!log_counter[@]}"; do
        if is_var_not_equal "$(get_value_by_key_from_dict "$log_counter_name" "$entry")" 0; then
            return 1
        fi
    done
    return 0
}

# Prints (unsorted) the counters for severity levels.
# The order of the output corresponds to the order in which the keys are iterated, and is not sorted.
#
# Usage:
#   print_all_log_counters
function print_all_log_counters {
    if _are_all_entries_zero_from_a_log_counter "_TOTAL_LOG_COUNTER"; then
        echo "No log counts."
        return 1
    else
        echo "Total log counts:"
        print_dict _TOTAL_LOG_COUNTER

        echo

        if _are_all_entries_zero_from_a_log_counter "_LOG_COUNTER_FOR_SYSTEM_LOGGING"; then
            echo "No log counts for system logging."
        else
            echo "Log counts for system logging:"
            print_dict _LOG_COUNTER_FOR_SYSTEM_LOGGING
        fi

        echo

        if _are_all_entries_zero_from_a_log_counter "_LOG_COUNTER_FOR_LOGGING_TO_LOG_FILES"; then
            echo "No log counts for logging to log files."
        else
            echo "Log counts for logging to '.log' files:"
            print_dict _LOG_COUNTER_FOR_LOGGING_TO_LOG_FILES
        fi

        echo

        if _are_all_entries_zero_from_a_log_counter "_LOG_COUNTER_FOR_LOGGING_TO_JSON_LOG_FILES"; then
            echo "No log counts for logging to JSON log files."
        else
            echo "Log counts for logging to '.json' log files:"
            print_dict _LOG_COUNTER_FOR_LOGGING_TO_JSON_LOG_FILES
        fi
    fi
    return 0
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░           LOGGING FUNCTIONALITY          ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║           LOGGING HELP VARIABLES           ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝
# ┌─────────────────────┬──────────────────────┐
# │                  SYSTEM                    │
# └─────────────────────┴──────────────────────┘

declare -x _USED_TAG_FOR_SYSTEM_LOGGING=""

# ┌─────────────────────┬──────────────────────┐
# │                 LOG FILES                  │
# └─────────────────────┴──────────────────────┘

_CONST_DATE_FOR_LOG_FILE="$(date +"%Y-%m-%d")"
declare -rx _CONST_DATE_FOR_LOG_FILE

_CONST_DATE_AND_TIME_FOR_LOG_FILE="$(date +"%Y-%m-%d_%H-%M-%S")"
declare -rx _CONST_DATE_AND_TIME_FOR_LOG_FILE

declare -ax _LOG_FILES_LIST=()
declare -x _USED_LOG_FILE_FOR_CURRENT_ENVIRONMENT_TO_NOTIFY_WITH=""
declare -x _USED_JSON_LOG_FILE_FOR_CURRENT_ENVIRONMENT_TO_NOTIFY_WITH=""

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║           LOGGING HELP FUNCTIONS           ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │             SCRIPT INFORMATION             │
# └─────────────────────┴──────────────────────┘

function _get_script_information_for_logging {
    local script_name="$1"

    local parent_script_name="$PARENT_SCRIPT_NAME"
    local args_passed="$_ARGS_PASSED"

    if is_var_not_empty "$parent_script_name"; then
        if is_false "$args_passed"; then
            echo "'$parent_script_name' -> '$script_name'"
        else
            echo "'$parent_script_name'"
        fi
    else
        echo "'$script_name'"
    fi
}

# ┌─────────────────────┬──────────────────────┐
# │            PARENT SCRIPT PATH              │
# └─────────────────────┴──────────────────────┘

function _get_parent_script_path {
    local parent_script="$PARENT_SCRIPT_NAME"
    local parent_script_path

    if is_var_empty "$parent_script"; then
        echo ""
        return 0
    fi

    local script_name_without_extensions
    script_name_without_extensions="$(extract_basename_without_file_extensions_from_file "$PARENT_SCRIPT_NAME")"

    if path_not_starts_with_slash "$script_name_without_extensions"; then
        script_name_without_extensions="/$script_name_without_extensions"
    fi

    if is_true "$ENABLE_SIMPLE_LOG_DIR_STRUCTURE"; then
        echo "$script_name_without_extensions"
        return 0
    fi

    # Try to resolve the absolute path
    if ! parent_script_path="$(realpath "$parent_script" 2>/dev/null)"; then
        echo "$script_name_without_extensions"
        return 0
    fi

    # Ensure the result ends with the script name without extension
    if [[ "$parent_script_path" != */"$script_name_without_extensions" ]]; then
        parent_script_path="$(dirname "$parent_script_path")${script_name_without_extensions}"
    fi

    # Ensure the result starts and ends with a '/'
    if is_var_not_empty "$parent_script_path"; then
        if path_not_starts_with_slash "$parent_script_path"; then
            parent_script_path="/$parent_script_path"
        fi

        if path_not_ends_with_slash "$parent_script_path"; then
            parent_script_path="$parent_script_path/"
        fi
    fi

    normalize_path "$parent_script_path"
}

# ┌─────────────────────┬──────────────────────┐
# │                  LOG DIR                   │
# └─────────────────────┴──────────────────────┘

function _get_log_dir_for_current_script {
    local parent_script="$PARENT_SCRIPT_NAME"
    local parent_script_path=""

    local args_passed="$_ARGS_PASSED"
    local enable_simple_log_dir_structure="$ENABLE_SIMPLE_LOG_DIR_STRUCTURE"
    local log_dir="$LOG_DIR"

    if is_var_not_empty "$parent_script"; then
        parent_script_path="$(_get_parent_script_path)/"
    fi

    local current_script_log_dir

    if is_false "$args_passed"; then
        if is_true "$enable_simple_log_dir_structure"; then
            # Use the script's name without extension as the directory name
            current_script_log_dir="${log_dir}${parent_script_path}${CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION}/"
        else
            # Mirror the script's full directory structure in `log_dir` and include the script name
            current_script_log_dir="${log_dir}${parent_script_path}${CONST_ABSOLUTE_SCRIPT_DIR}${CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION}/"
        fi
    else
        current_script_log_dir="${log_dir}${parent_script_path}/"
    fi

    normalize_path "$current_script_log_dir"
}

# ┌─────────────────────┬──────────────────────┐
# │          LOG FILE WITHOUT SUFFIX           │
# └─────────────────────┴──────────────────────┘

function _get_log_file_without_suffix {
    local args_passed="$_ARGS_PASSED"

    local log_file_prefix_for_current_script=""
    if is_false "$args_passed"; then
        log_file_prefix_for_current_script="${_CONST_DATE_AND_TIME_FOR_LOG_FILE}_${CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION}"
    else
        local parent_script_name="$PARENT_SCRIPT_NAME"

        if is_var_empty "$parent_script_name"; then
            log_file_prefix_for_current_script="${_CONST_DATE_FOR_LOG_FILE}"
        else
            log_file_prefix_for_current_script="${_CONST_DATE_FOR_LOG_FILE}_$(extract_basename_without_file_extensions_from_file "$PARENT_SCRIPT_NAME")"
        fi
    fi

    echo "$(_get_log_dir_for_current_script)${log_file_prefix_for_current_script}"
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║           ACTIONS DURING LOGGING           ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │               SYSTEM LOGGING               │
# └─────────────────────┴──────────────────────┘

# Dependencies: `logger`
#
# Example usage for different distributions:
#
# `_USED_TAG_FOR_SYSTEM_LOGGING`: `/path/to/your/script.sh`
#
# | Distribution            | View Logs                                        | Filter by Severity                                                     |
# |-------------------------|------------------------------------------------- |------------------------------------------------------------------------|
# | Ubuntu (systemd)        | `journalctl -t /path/to/your/script.sh`          | `journalctl -t /path/to/your/script.sh -p [SEVERITY]`                  |
# | CentOS/RHEL/Fedora      | `journalctl -t /path/to/your/script.sh`          | `journalctl -t /path/to/your/script.sh -p [SEVERITY]`                  |
# | Debian (rsyslog)        | `grep /path/to/your/script.sh /var/log/syslog`   | `grep '/path/to/your/script.sh' /var/log/syslog | grep '[SEVERITY]'`   |
# | Arch Linux (systemd)    | `journalctl -t /path/to/your/script.sh`          | `journalctl -t /path/to/your/script.sh -p [SEVERITY]`                  |
# | SUSE (rsyslog)          | `grep /path/to/your/script.sh /var/log/messages` | `grep '/path/to/your/script.sh' /var/log/messages | grep '[SEVERITY]'` |
# | Alpine (busybox syslog) | `grep /path/to/your/script.sh /var/log/messages` | `grep '/path/to/your/script.sh' /var/log/messages | grep '[SEVERITY]'` |
# | Generic (rsyslog)       | `grep /path/to/your/script.sh /var/log/syslog`   | `grep '/path/to/your/script.sh' /var/log/syslog | grep '[SEVERITY]'`   |
function _log_to_system {
    local severity_code="$1"
    local message="$2"

    local facility_name="$FACILITY_NAME_FOR_SYSTEM_LOGGING"
    local level_name=""

    # Assignment of the severity code to the appropriate `logger` level name
    case "$severity_code" in
    0)
        # EMERG (0)
        level_name="emerg"
        ;;
    1)
        # ALERT (1)
        level_name="alert"
        ;;
    2)
        # CRIT (2)
        level_name="crit"
        ;;
    3)
        # ERROR (3)
        level_name="err"
        ;;
    4)
        # WARN (4)
        level_name="warning"
        ;;
    5)
        # NOTICE (5)
        level_name="notice"
        ;;
    6)
        # INFO (6)
        level_name="info"
        ;;
    7 | *)
        # DEBUG (7), ...
        level_name="debug"
        ;;
    esac

    local script_information
    script_information="$(_get_script_information_for_logging "$CONST_ABSOLUTE_SCRIPT_NAME")"

    local tag_for_system_logging
    if is_var_empty "$PARENT_SCRIPT_NAME"; then
        tag_for_system_logging="$CONST_ABSOLUTE_SCRIPT_NAME"
    else
        tag_for_system_logging="$PARENT_SCRIPT_NAME"
    fi

    _USED_TAG_FOR_SYSTEM_LOGGING="$tag_for_system_logging"

    # If the message is multi-line, each line is logged as a new line
    logger \
        --tag "${tag_for_system_logging}" \
        --priority "${facility_name}.${level_name}" \
        "[$script_information] - [PID: $CONST_CURRENT_PID] - $message" ||
        _print_internal_error "logger --tag \"${tag_for_system_logging}\" --priority \"${facility_name}.${level_name}\" \"[$script_information] - [PID: $CONST_CURRENT_PID] - $message\""
}

# ┌─────────────────────┬──────────────────────┐
# │             STANDARD LOG FILE              │
# └─────────────────────┴──────────────────────┘

function _write_message_to_log_file {
    local file="$1"
    local timestamp="$2"
    local severity_name="$3"
    local message="$4"

    local script_information
    script_information="$(_get_script_information_for_logging "$CONST_ABSOLUTE_SCRIPT_NAME")"

    while IFS= read -r line; do
        write_line_to_file "$file" "$timestamp - [$script_information] - [PID: $CONST_CURRENT_PID] - [$severity_name] - $line"
    done <<<"$message"
}

# ┌─────────────────────┬──────────────────────┐
# │               JSON LOG FILE                │
# └─────────────────────┴──────────────────────┘

# Dependencies: `jq`
function _write_message_to_json_log_file {
    local file="$1"
    local timestamp="$2"
    local severity_name="$3"
    local message="$4"

    local pid="$CONST_CURRENT_PID"

    local directory
    directory="$(dirname "$file")"

    _is_package_for_json_logging_installed

    if directory_not_exists "$directory"; then
        if ! mkdir -p "$directory"; then
            _print_internal_error "Error when creating a directory for JSON logs. '$directory'."
        fi
    fi

    # Replace line breaks in the message with '\n'
    local escaped_message
    escaped_message="${message//$'\n'/\\n}"

    local severity_count
    if ! severity_count="$(_get_value_from_a_log_counter _LOG_COUNTER_FOR_LOGGING_TO_JSON_LOG_FILES "$severity_name")"; then
        _print_internal_error "Error when retrieving the severity counter '$severity_name' for JSON logs."
    fi

    local log_entry
    log_entry=$(jq -n \
        --argjson timestamp "$timestamp" \
        --arg level "$severity_name" \
        --arg message "$escaped_message" \
        --arg script_info "$(_get_script_information_for_logging "$CONST_ABSOLUTE_SCRIPT_NAME")" \
        '{
            timestamp: $timestamp,
            level: $level,
            message: $message,
            script_info: $script_info
        }')

    if file_exists "$file"; then
        local existing_json
        existing_json="$(cat "$file")"

        local updated_json
        updated_json=$(echo "$existing_json" | jq --arg pid "$pid" \
            --arg level "$severity_name" \
            --argjson new_log "$log_entry" \
            --argjson severity_count "$severity_count" \
            '
            # Ensure .pids is an array and add the PID if not already present
            .pids |= (if . == null then [] else . end | unique | . + [$pid] | unique) |
            # Ensure .[$pid] is an object
            .[$pid] |= (if . == null then {} else . end) |
            # Replace the severity count in summary
            .[$pid].summary[$level] = $severity_count |
            # Add new log entry
            .[$pid].logs += [$new_log]
            ')

        if ! echo "$updated_json" >"$file"; then
            _print_internal_error "Error when updating the file '$file' for JSON logs."
        fi
    else
        local new_json
        new_json=$(jq -n \
            --arg pid "$pid" \
            --arg level "$severity_name" \
            --argjson new_log "$log_entry" \
            --argjson severity_count "$severity_count" \
            '{
                pids: [$pid],
                ($pid): {
                    summary: {
                        ($level): $severity_count
                    },
                    logs: [$new_log]
                }
            }')

        if ! echo "$new_json" >"$file"; then
            _print_internal_error "Error when creating and writing the file '$file' for JSON logs."
        fi
    fi
}

# ┌─────────────────────┬──────────────────────┐
# │               CONSOLE OUTPUT               │
# └─────────────────────┴──────────────────────┘

function _print_log_message {
    local timestamp="$1"
    local severity_code="$2"
    local severity_name="$3"
    local message="$4"

    local enable_parent_script_name_in_console_outputs_for_logging="$ENABLE_PARENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING"
    local parent_script_name="$PARENT_SCRIPT_NAME"

    case "$severity_code" in
    0)
        # EMERG (0)
        color="red"
        style="high_intensity_background"
        ;;
    1)
        # ALERT (1)
        color="red"
        style="background"
        ;;
    2)
        # CRIT (2)
        color="red"
        style="bold_high_intensity"
        ;;
    3)
        # ERROR (3)
        color="red"
        style="bold"
        ;;
    4)
        # WARN (4)
        color="yellow"
        style="bold"
        ;;
    5)
        # NOTICE (5)
        color="purple"
        style="regular"
        ;;
    6)
        # INFO (6)
        color="green"
        style="regular"
        ;;
    7 | *)
        # DEBUG (7), ...
        color="blue"
        style="regular"
        ;;
    esac

    local prefix=""
    if is_true "$ENABLE_DATE_IN_CONSOLE_OUTPUTS_FOR_LOGGING"; then
        prefix="$timestamp"
    fi

    if is_false "$_ARGS_PASSED"; then
        local script_name=""
        case "$SHOW_CURRENT_SCRIPT_NAME_IN_CONSOLE_OUTPUTS_FOR_LOGGING" in
        "path")
            script_name="$CONST_SCRIPT_NAME_WITH_CURRENT_PATH"
            ;;
        "simple")
            script_name="$CONST_SIMPLE_SCRIPT_NAME"
            ;;
        "simple_without_file_extension")
            script_name="$CONST_SIMPLE_SCRIPT_NAME_WITHOUT_FILE_EXTENSION"
            ;;
        "absolute")
            script_name="$CONST_ABSOLUTE_SCRIPT_NAME"
            ;;
        *)
            script_name="$CONST_SCRIPT_NAME_WITH_CURRENT_PATH"
            ;;
        esac

        if is_true "$enable_parent_script_name_in_console_outputs_for_logging"; then
            local script_information
            script_information="$(_get_script_information_for_logging "$script_name")"

            if is_var_not_empty "$prefix"; then
                prefix="$prefix [$script_information] - "
            else
                prefix="[$script_information] - "
            fi
        else
            if is_var_not_empty "$prefix"; then
                prefix="$prefix [$script_name] - "
            else
                prefix="[$script_name] - "
            fi
        fi
    else
        if is_true "$enable_parent_script_name_in_console_outputs_for_logging" && is_var_not_empty "$parent_script_name"; then
            if is_var_not_empty "$prefix"; then
                prefix="$prefix [$parent_script_name] - "
            else
                prefix="[$parent_script_name] - "
            fi
        else
            if is_var_not_empty "$prefix"; then
                prefix="$prefix - "
            fi
        fi
    fi

    while IFS= read -r line; do
        print_colored_text "${prefix}[$severity_name] - $line" "$color" "$style"
    done <<<"$message"
}

# ┌─────────────────────┬──────────────────────┐
# │                   POPUPS                   │
# └─────────────────────┴──────────────────────┘

function _show_gui_popup_logging_notification {
    local severity="$1"
    local message="$2"

    local severity_code
    local title
    local icon

    if is_not_numeric "$severity"; then
        severity_code="$(get_severity_code "$severity")"
    else
        severity_code="$severity"
    fi

    # Set title and icon based on severity code
    case "$severity_code" in
    0 | 1 | 2 | 3)
        # EMERG (0), ALERT (1), CRIT (2), ERROR (3)
        title="$(get_severity_name "$severity_code")"
        icon="error"
        ;;
    4)
        # WARN (4)
        title="$(get_severity_name "$severity_code")"
        icon="warning"
        ;;
    5 | 6 | 7 | *)
        # NOTICE (5), INFO (6), DEBUG (7), ...
        # Message is not displayed as a popup
        return 0
        ;;
    esac

    local tool
    tool="$(get_available_popup_tool)"

    if is_var_not_empty "$tool"; then
        local width="$LOG_POPUP_NOTIFICATION_WINDOW_WIDTH"
        local height="$LOG_POPUP_NOTIFICATION_WINDOW_HEIGHT"

        if is_var_equal "$tool" "yad"; then
            yad --"$icon" --width="$width" --height="$height" \
                --title="$title" \
                --text="$message" \
                --button="OK:0"

        elif is_var_equal "$tool" "zenity"; then
            zenity --"$icon" --width="$width" --height="$height" \
                --title="$title" \
                --text="$message"
        fi
    else
        _print_internal_warning "Neither 'yad' nor 'zenity' is available to show a popup notification."
    fi
}

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║             MAIN LOGGING LOGIC             ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# Logs a message with a specified severity level and performs logging actions based on configuration.
#
# The function takes a severity level and a message, validates the input and then logs the message according to the severity level.
# It determines whether to log to the system, to a standard `.log` file, or in JSON format.
# The severity level can be provided as either a numeric code (0-7) or a severity name (DEBUG, INFO, NOTICE, WARN, ERROR, CRIT, ALERT, EMERG).
# The function also supports GUI popups for logging notifications if configured to do so.
#
# Usage:
#   log "ERROR" "An error has occurred while processing the request."
function log {
    local severity="$1"
    local message="$2"

    if is_false "$_ARGS_PASSED"; then
        _validate_user_input_for_logging
    fi

    local severity_code
    if is_not_numeric "$severity"; then
        severity_code="$(get_severity_code "$severity")"
    else
        severity_code="$severity"
    fi

    if ! is_numeric_in_range "$severity_code" "$CONST_MIN_ALLOWED_SEVERITY_CODE" "$CONST_MAX_ALLOWED_SEVERITY_CODE"; then
        _print_internal_error "Invalid severity code: '$severity_code'. It must be an integer between $CONST_MIN_ALLOWED_SEVERITY_CODE and $CONST_MAX_ALLOWED_SEVERITY_CODE."
    fi

    if is_var_not_empty "$message"; then
        if is_less_or_equal "$severity_code" "$LOG_LEVEL_FOR_SYSTEM_LOGGING" && is_true "$ENABLE_LOG_TO_SYSTEM"; then
            _increment_a_log_counter _LOG_COUNTER_FOR_SYSTEM_LOGGING "$severity_code"
            _log_to_system "$severity_code" "$message"
        fi

        if is_less_or_equal "$severity_code" "$LOG_LEVEL"; then
            local current_timestamp_for_message
            current_timestamp_for_message="$(date +"%F %T")" # Format 'YYYY-MM-DD HH:MM:SS'

            local current_unix_timestamp
            current_unix_timestamp="$(date "+%s")" # Number of seconds since January 1, 1970

            local severity_name
            severity_name="$(get_severity_name "$severity_code")"

            local enable_log_file="$ENABLE_LOG_FILE"
            local enable_json_log_file="$ENABLE_JSON_LOG_FILE"
            local enable_combined_log_files="$ENABLE_COMBINED_LOG_FILES"

            if is_true "$enable_log_file" || is_true "$enable_json_log_file"; then
                local log_dir="$LOG_DIR"

                local file_part_for_combined_log_files="combined"
                local log_file_in_use=""
                local log_file_suffix=""

                if is_true "$enable_log_file"; then
                    log_file_suffix=".log"

                    function _write_message_to_log_file_and_add_to_list {
                        _write_message_to_log_file "$log_file_in_use" "$current_timestamp_for_message" "$severity_name" "$message"
                        add_unique_item_to_list _LOG_FILES_LIST "$log_file_in_use"
                    }

                    log_file_in_use="$(_get_log_file_without_suffix)${log_file_suffix}"
                    _USED_LOG_FILE_FOR_CURRENT_ENVIRONMENT_TO_NOTIFY_WITH="$log_file_in_use"
                    _increment_a_log_counter _LOG_COUNTER_FOR_LOGGING_TO_LOG_FILES "$severity_code"
                    _write_message_to_log_file_and_add_to_list

                    if is_true "$enable_combined_log_files"; then
                        log_file_in_use="${log_dir}${file_part_for_combined_log_files}${log_file_suffix}"
                        _write_message_to_log_file_and_add_to_list

                        log_file_in_use="${log_dir}$(to_lowercase "$severity_name")${log_file_suffix}"
                        _write_message_to_log_file_and_add_to_list
                    fi
                fi

                if is_true "$enable_json_log_file"; then
                    log_file_suffix="_log.json"

                    function _write_message_to_json_log_file_and_add_to_list {
                        _write_message_to_json_log_file "$log_file_in_use" "$current_unix_timestamp" "$severity_name" "$message"
                        add_unique_item_to_list _LOG_FILES_LIST "$log_file_in_use"
                    }

                    log_file_in_use="$(_get_log_file_without_suffix)${log_file_suffix}"
                    _USED_JSON_LOG_FILE_FOR_CURRENT_ENVIRONMENT_TO_NOTIFY_WITH="$log_file_in_use"
                    _increment_a_log_counter _LOG_COUNTER_FOR_LOGGING_TO_JSON_LOG_FILES "$severity_code"
                    _write_message_to_json_log_file_and_add_to_list

                    if is_true "$enable_combined_log_files"; then
                        log_file_in_use="${log_dir}${file_part_for_combined_log_files}${log_file_suffix}"
                        _write_message_to_json_log_file_and_add_to_list

                        log_file_in_use="${log_dir}$(to_lowercase "$severity_name")${log_file_suffix}"
                        _write_message_to_json_log_file_and_add_to_list
                    fi
                fi
            fi

            _print_log_message "$current_timestamp_for_message" "$severity_code" "$severity_name" "$message"

            if is_true "$ENABLE_GUI_POPUPS_FOR_LOGGING_NOTIFICATIONS"; then
                _show_gui_popup_logging_notification "$severity_code" "$message"
            fi
        fi

        if is_true "$ENABLE_EXITING_SCRIPT_IF_AT_LEAST_ERROR_IS_LOGGED" &&
            is_less_or_equal "$severity_code" 3; then # Log level is 0 (Emergency), 1 (Alert), 2 (Critical), or 3 (Error)

            print_colored_text "An error has been logged and the script aborts as a result." "red" "bold_high_intensity"
            exit 1
        fi
    fi
}

# ┌─────────────────────┬──────────────────────┐
# │          MAIN FUNCTIONS FOR USERS          │
# └─────────────────────┴──────────────────────┘

# Log EMERG message
function log_emerg {
    log 0 "$1"
}

# Log ALERT message
function log_alert {
    log 1 "$1"
}

# Log CRIT message
function log_crit {
    log 2 "$1"
}

# Log ERROR message
function log_error {
    log 3 "$1"
}

# Log WARN message
function log_warn {
    log 4 "$1"
}

# Log NOTICE message
function log_notice {
    log 5 "$1"
}

# Log INFO message
function log_info {
    log 6 "$1"
}

# Log DEBUG message
function log_debug {
    log 7 "$1"
}

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░               TRAP DEBUG                 ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

declare -x _PREV_CMD="null"
declare -x _THIS_CMD="null"

if is_true "$ENABLE_TRAP_FOR_DEBUG"; then
    trap '_PREV_CMD=$_THIS_CMD; _THIS_CMD=$BASH_COMMAND; log_debug "Command to execute: $_THIS_CMD"' DEBUG
fi

# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░
# ░░                                          ░░
# ░░                                          ░░
# ░░              FINAL EXECUTIONS            ░░
# ░░                                          ░░
# ░░                                          ░░
# ░░░░░░░░░░░░░░░░░░░░░▓▓▓░░░░░░░░░░░░░░░░░░░░░░

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                   HELPERS                  ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# ┌─────────────────────┬──────────────────────┐
# │                 ARG LOGIC                  │
# └─────────────────────┴──────────────────────┘

if is_true "$_ARGS_PASSED"; then
    log "$_ARG_SEVERITY" "$_ARG_MESSAGE"
fi

# ┌─────────────────────┬──────────────────────┐
# │                   NOTIFY                   │
# └─────────────────────┴──────────────────────┘

function _notify_with_log_files {
    local notifier="$SIMBASHLOG_NOTIFIER"
    local notifier_config="$SIMBASHLOG_NOTIFIER_CONFIG_PATH"

    local args_passed="$_ARGS_PASSED"
    local used_log_file="$_USED_LOG_FILE_FOR_CURRENT_ENVIRONMENT_TO_NOTIFY_WITH"
    local used_json_log_file="$_USED_JSON_LOG_FILE_FOR_CURRENT_ENVIRONMENT_TO_NOTIFY_WITH"

    if is_var_not_empty "$notifier"; then
        if is_true "$args_passed" || is_var_not_empty "$used_log_file" || is_var_not_empty "$used_json_log_file"; then
            local cmd="$notifier"

            if is_var_not_empty "$notifier_config"; then
                cmd="$cmd --config \"$notifier_config\""
            fi

            cmd="$cmd --pid \"$CONST_CURRENT_PID\""

            if is_true "$args_passed"; then
                local severity="$_ARG_SEVERITY"

                local severity_code
                if is_not_numeric "$severity"; then
                    severity_code="$(get_severity_code "$severity")"
                else
                    severity_code="$severity"
                fi

                cmd="$cmd --log-level \"$severity_code\" --message \"$_ARG_MESSAGE\""
            else
                echo
                cmd="$cmd --log-level \"$LOG_LEVEL\""
            fi

            if is_var_not_empty "$used_log_file"; then
                cmd="$cmd --log-file \"$used_log_file\""
            fi

            if is_var_not_empty "$used_json_log_file"; then
                cmd="$cmd --json-log-file \"$used_json_log_file\""
            fi

            if eval "$cmd" 2>/dev/null; then
                print_colored_text "Notification successful: '$cmd'" "green" "bold"
            else
                _print_internal_warning "Failed to notify with: '$cmd'"
                _print_internal_warning "See $CONST_SIMBASHLOG_NOTIFIERS_GITHUB_LINK for more information."
            fi
        else
            _print_internal_warning "A notifier ('$notifier') was specified, but no log files were created. Therefore no notification was executed!"
        fi
    fi
}

# ┌─────────────────────┬──────────────────────┐
# │                 LOG FILES                  │
# └─────────────────────┴──────────────────────┘

# Prints all log files to console.
#
# Usage:
#   print_all_log_files
function print_all_log_files {
    # Retrieve all log file names
    local log_files
    log_files="$(print_list _LOG_FILES_LIST)"

    if is_var_not_empty "$log_files"; then
        echo "Log files:"
        echo "$log_files"
    else
        echo "No log files were created."
    fi
}

# ┌─────────────────────┬──────────────────────┐
# │                 EXPORTING                  │
# └─────────────────────┴──────────────────────┘

# Exporting all functions so that they can be used in other scripts and subshells
for func in $(declare -F | awk '{print $3}'); do
    export -f "${func?}"
    #echo "$func"
done

# Show all available functions
#print_available_functions

# Checking the exported functions
#env | grep '^BASH_FUNC_'

# Checking the exported variables
#export -p | grep -v "^declare -x _"

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                   EXIT                     ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

function _execute_actions_on_exit {
    _notify_with_log_files

    if is_true "$ENABLE_SUMMARY_ON_EXIT"; then
        if is_true "$_ARGS_PASSED"; then
            print_all_log_files
        else
            local color="blue"
            local style="bold"

            echo
            print_colored_text "  _____                                                " "$color" "$style"
            print_colored_text " / ____|                                             _ " "$color" "$style"
            print_colored_text "| (___  _   _ _ __ ___  _ __ ___   __ _ _ __ _   _  (_)" "$color" "$style"
            print_colored_text " \___ \| | | | '_ \` _ \| '_ \` _ \ / _\` | '__| | | |    " "$color" "$style"
            print_colored_text " ____) | |_| | | | | | | | | | | | (_| | |  | |_| |  _ " "$color" "$style"
            print_colored_text "|_____/ \__,_|_| |_| |_|_| |_| |_|\__,_|_|   \__, | (_)" "$color" "$style"
            print_colored_text "                                              __/ |    " "$color" "$style"
            print_colored_text "                                             |___/     " "$color" "$style"
            echo

            echo
            echo "Version: $CONST_SIMBASHLOG_VERSION"
            echo
            echo "If system logging has been activated, the following tag can be used to search for it:"
            echo "$_USED_TAG_FOR_SYSTEM_LOGGING"
            echo
            print_all_log_files
            echo
            print_all_log_counters
            echo
            print_colored_text "$(_show_donate_message)" "$color" "$style"
        fi
    fi
}

if is_true "$ENABLE_TRAP_FOR_EXIT"; then
    trap "_execute_actions_on_exit" EXIT
fi
