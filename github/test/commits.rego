package test.commits

import future.keywords.in

verified_commit_by_test := { "author": { "login": "test" }, "commit": { "verification": { "verified": true } } }
unverified_commit_by_test := { "author": { "login": "test" }, "commit": { "verification": { "verified": false } } }
unverified_commit_by_allowed := { "author": { "login": "allowed" }, "commit": { "verification": { "verified": false } } }

input_state_allowed := { "org/repo": ["allowed"] }

one_verified_commits_state := { "org/repo": [ unverified_commit_by_test, verified_commit_by_test ] }
one_unverified_commits_state := { "org/repo": [ unverified_commit_by_test ] }
one_unverified_commits_state_with_allowed := { "org/repo": [ verified_commit_by_test, unverified_commit_by_test, unverified_commit_by_allowed ] }

test_one_verified {
  count(data.github.commits.commits_unverified) == 1 with data.github.commits.successes as one_verified_commits_state
}

test_one_unverified {
  count(data.github.commits.commits_unverified) == 1 with data.github.commits.successes as one_unverified_commits_state
}

test_one_allowed {
  count(data.github.commits.commits_unverified) == 1
    with data.github.commits.successes as one_unverified_commits_state_with_allowed
    with data.github.state.commits.allowed as input_state_allowed
}
