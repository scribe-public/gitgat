package github.test.branches

import future.keywords.in

protection_a := {
  "owner/repo/branches/main": {
    "allow_deletions": {
      "enabled": false
    },
    "allow_force_pushes": {
      "enabled": false
    },
    "block_creations": {
      "enabled": false
    },
    "enforce_admins": {
      "enabled": false,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/enforce_admins"
    },
    "required_conversation_resolution": {
      "enabled": false
    },
    "required_linear_history": {
      "enabled": true
    },
    "required_pull_request_reviews": {
      "dismiss_stale_reviews": false,
      "require_code_owner_reviews": false,
      "required_approving_review_count": 1,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_pull_request_reviews"
    },
    "required_signatures": {
      "enabled": true,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_signatures"
  },
    "required_status_checks": {
      "checks": [],
      "contexts": [],
      "contexts_url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_status_checks/contexts",
      "strict": true,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_status_checks"
    },
    "url": "https://api.github.com/repos/owner/repo/branches/main/protection"
  }
}

protection_b := {
  "owner/repo/branches/main": {
    "allow_deletions": {
      "enabled": true
    },
    "allow_force_pushes": {
      "enabled": false
    },
    "block_creations": {
      "enabled": false
    },
    "enforce_admins": {
      "enabled": false,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/enforce_admins"
    },
    "required_conversation_resolution": {
      "enabled": false
    },
    "required_linear_history": {
      "enabled": true
    },
    "required_pull_request_reviews": {
      "dismiss_stale_reviews": false,
      "require_code_owner_reviews": false,
      "required_approving_review_count": 1,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_pull_request_reviews"
    },
    "required_signatures": {
      "enabled": true,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_signatures"
  },
    "required_status_checks": {
      "checks": [],
      "contexts": [],
      "contexts_url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_status_checks/contexts",
      "strict": true,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_status_checks"
    },
    "url": "https://api.github.com/repos/owner/repo/branches/main/protection"
  }
}

protection_c := {
  "owner/repo/branches/main": {
    "allow_deletions": {
      "enabled": false
    },
    "allow_force_pushes": {
      "enabled": false
    },
    "block_creations": {
      "enabled": false
    },
    "enforce_admins": {
      "enabled": false,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/enforce_admins"
    },
    "required_conversation_resolution": {
      "enabled": false
    },
    "required_linear_history": {
      "enabled": true
    },
    "required_pull_request_reviews": {
      "dismiss_stale_reviews": false,
      "require_code_owner_reviews": false,
      "required_approving_review_count": 1,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_pull_request_reviews"
    },
    "required_signatures": {
      "enabled": true,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_signatures"
  },
    "required_status_checks": {
      "checks": [1],
      "contexts": [],
      "contexts_url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_status_checks/contexts",
      "strict": true,
      "url": "https://api.github.com/repos/owner/repo/branches/main/protection/required_status_checks"
    },
    "url": "https://api.github.com/repos/owner/repo/branches/main/protection"
  }
}

test_allow_deletions {
  not protection_a == protection_b
}

test_detect_checks {
  not protection_a == protection_c
}

unprotected_branches := {
  "some-branch": {
    "protected": false
  },
  "some-other-branch": {
    "protected": false
  }
}

known_unprotected_branches := ["some-branch"]

test_known {
  count(data.github.branches.unprotected_branches) == 1
    with data.github.branches.current_unprotected_branches as unprotected_branches
    with data.github.state.branches.unprotected_branches as known_unprotected_branches
}

known_protection_data := {
  "some-branch": {
    "allow_deletions": {
      "enabled": false
    }
  }
}

test_known_protection_data {
  count(data.github.branches.unchanged_protection) == 1
    with data.github.branches.protection_data as known_protection_data
    with data.github.state.branches.protection_data as known_protection_data
}
