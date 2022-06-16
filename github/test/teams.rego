package test.teams

import future.keywords.in

state_permissions := { "org": { "team": { "owner/repo": { "admin": true, "maintain": true, "pull": true, "push": true, "triage": true } } } }

pass_response_permissions := { "org/team/owner/repo": { "admin": true, "maintain": true, "pull": true, "push": true, "triage": true } }

admin_response_permissions := { "org/team/owner/repo": { "admin": false, "maintain": true, "pull": true, "push": true, "triage": true } }
maintain_response_permissions := { "org/team/owner/repo": { "admin": true, "maintain": false, "pull": true, "push": true, "triage": true } }
pull_response_permissions := { "org/team/owner/repo": { "admin": true, "maintain": true, "pull": false, "push": true, "triage": true } }
push_response_permissions := { "org/team/owner/repo": { "admin": true, "maintain": true, "pull": true, "push": false, "triage": true } }
triage_response_permissions := { "org/team/owner/repo": { "admin": true, "maintain": true, "pull": true, "push": true, "triage": false } }

test_pass_permissions {
  count(data.github.teams.changed_permissions) == 0
    with data.github.init.responses as pass_response_permissions
    with data.github.state.teams.permissions as state_permissions
}

test_admin_permissions {
  count(data.github.teams.changed_permissions) == 0
    with data.github.teams.teams_repos_responses as admin_response_permissions
    with data.github.state.teams.permissions as state_permissions
}
test_maintain_permissions {
  count(data.github.teams.teams_responses) == 0
    with data.github.init.responses as maintain_response_permissions
    with data.github.state.teams.permissions as state_permissions
}
test_pull_permissions {
  count(data.github.teams.teams_responses) == 0
    with data.github.init.responses as pull_response_permissions
    with data.github.state.teams.permissions as state_permissions
}
test_push_permissions {
  count(data.github.teams.teams_responses) == 0
    with data.github.init.responses as push_response_permissions
    with data.github.state.teams.permissions as state_permissions
}
test_triage_permissions {
  count(data.github.teams.teams_responses) == 0
    with data.github.init.responses as triage_response_permissions
    with data.github.state.teams.permissions as state_permissions
}
