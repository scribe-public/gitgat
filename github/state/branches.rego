package github.state.branches

default unprotected_branches := []
default protection_data := {}

unprotected_branches := input.branches.unprotected
protection_data := input.branches.protection_data
