package test.tfa

import future.keywords.in

existing_user := { "test_org": [{ "login": "test_user" }] }

test_tfa_existing {
  "test_user" in data.github.tfa.tfa_disabled_members["test_org"] with data.github.tfa.responses as existing_user with data.github.state.tfa.exceptions as {}
}

test_tfa_non_existing {
  "test_user" in data.github.tfa.tfa_disabled_members["test_org"] with data.github.tfa.responses as existing_user with data.github.state.tfa.exceptions as {}
  not "other_user" in data.github.tfa.tfa_disabled_members["test_org"] with data.github.tfa.responses as existing_user with data.github.state.tfa.exceptions as {}
}

exceptions := { "test_org": [ "test_user" ] }

test_tfa_exceptions {
  not "test_user" in data.github.tfa.tfa_disabled_members["test_org"] with data.github.tfa.responses as existing_user with data.github.state.tfa.exceptions as exceptions
}
