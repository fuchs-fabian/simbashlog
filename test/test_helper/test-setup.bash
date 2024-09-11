#!/usr/bin/env bash

function init_bats {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd)"
    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT/src:$PATH"
}

function remove_ansi_codes_from_output {
    echo "Actual output with ansi codes: '$output'"
    output=$(echo "$output" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
    echo "Actual output without ansi codes: '$output'"
}
