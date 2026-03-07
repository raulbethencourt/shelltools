#!/bin/bash

setup() {
	PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
	export PROJECT_ROOT

	source "${PROJECT_ROOT}/lib/.toolbox"

	TEST_TMP_DIR="$(mktemp -d)"
	export TEST_TMP_DIR
}

teardown() {
	rm -rf "${TEST_TMP_DIR}"
}

assert_success() {
	# shellcheck disable=SC2154
	if [[ "$status" -ne 0 ]]; then
		echo "Expected success but command failed with status $status"
		echo "Output: $output"
		return 1
	fi
}

assert_failure() {
	if [[ "$status" -eq 0 ]]; then
		echo "Expected failure but command succeeded"
		echo "Output: $output"
		return 1
	fi
}

assert_output_contains() {
	local expected="$1"
	if [[ "$output" != *"$expected"* ]]; then
		echo "Expected output to contain: $expected"
		echo "Actual output: $output"
		return 1
	fi
}
