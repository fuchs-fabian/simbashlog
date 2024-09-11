# Run from project dir:
# ./test/bats/bin/bats test/test-call-with-arguments.bats

setup() {
    load 'test_helper/test-setup'
    init_bats

    chmod +x src/simbashlog.bash
}

teardown() {
    chmod -x src/simbashlog.bash
}

@test "simplest call with arguments" {
    run simbashlog.bash -a console -s error --message 'An error occured'
    remove_ansi_codes_from_output

    [[ "$output" == "[ERROR] - An error occured" ]]
}
