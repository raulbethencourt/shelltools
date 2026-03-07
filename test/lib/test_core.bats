#!/bin/bash

load ../helpers/test_helper

@test "error_exit exits with custom exit code" {
  run error_exit "Test error message" 5
  [ "$status" -eq 5 ]
}

@test "error_exit exits with default exit code 1" {
  run error_exit "Test error message"
  [ "$status" -eq 1 ]
}

@test "error_exit outputs error message to stderr" {
  run error_exit "Custom error text" 3
  [[ "$output" == *"Custom error text"* ]]
}
