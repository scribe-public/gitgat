package github.teams

import future.keywords.in
import data.github.utils as utils

# Organizations
orgs = data.github.orgs.orgs

# Repos
repos := data.github.repos.repos

teams_urls[orgs[x].login] = concat("/", ["orgs", orgs[x].login, "teams"])
teams_responses[x] = utils.parse(data.github.api.call_github(teams_urls[x]))
teams[x] = teams_responses[x] {
  not utils.is_error(teams_responses[x])
}
# teams_responses := {"org": [{"slug", "repositories_url"}]}

repos_urls = { slug: url |
  some org, org_teams in teams
  some team in org_teams
  slug := sprintf("%s/%s", [org, team.slug])
  url := team.repositories_url
}
teams_repos_responses[x] = utils.parse(data.github.api.call_github_abs(repos_urls[x]))
teams_repos[x] = teams_repos_responses[x] {
  not utils.is_error(teams_repos_responses[x])
}
# teams_repos := {"org/team": [{"full_name"(owner/repo), "permissions"}]}

team_members_urls = { slug: url |
  some org, org_teams in teams
  some team in org_teams
  slug := sprintf("%s/%s", [org, team.slug])
  url := trim_suffix(team.members_url, "{/member}")
}
teams_members_responses[x] = utils.parse(data.github.api.call_github_abs(team_members_urls[x]))
teams_members[x] = teams_members_responses[x] {
  not utils.is_error(teams_members_responses[x])
}

merged_responses := object.union(teams_responses, teams_repos_responses)
responses := object.union(merged_responses, teams_members_responses)

teams_members_logins[k] = utils.flatten_array(teams_members[k], "login")

#configured_members[k] = v {
#  some org, teams
#}

members[k] = utils.array_intersection(teams_members_logins[k], data.github.state.teams.members[k])
new_members[k] = utils.array_subtraction(teams_members_logins[k], members[k])
new_members[k] = teams_members_logins[k] {
  not k in members
}

non_empty_new_members[k] = new_members[k] {
  count(new_members[k]) > 0
}

members_findings = v {
  count(non_empty_new_members) > 1
  c_findings := "(i) %d teams have new members."
  v := sprintf(c_findings, [count(non_empty_new_members)])
}

members_findings = v {
  count(non_empty_new_members) == 1
  v := "(i) 1 team has new members."
}

members_findings = v {
  count(non_empty_new_members) == 0
  count(teams) > 0
  v := "(v) all teams members are approved."
}

members_findings = v {
  count(teams) == 0
  v := "(v) no teams are configured in the organizations."
}

current_permissions[k] = v {
  some org_team, repos in teams_repos
  some repo in repos
  k := concat("/", [org_team, repo.full_name])
  v := repo.permissions
}

configured_permissions[k] = v {
  some org, teams in data.github.state.teams.permissions
  some team, repos in teams
  some repo, v in repos
  k := concat("/", [org, team, repo])
}

current_keys := { k | some k, _ in current_permissions }
configured_keys := { k | some k, _ in configured_permissions }
state_available := current_keys & configured_keys
state_unavailable := current_keys - configured_keys

permissions = { k: v |
  some t;
  k := state_unavailable[t];
  v := current_permissions[k]
}

changed_permissions = { k: v |
  some t;
  k := state_available[t];
  current_permissions[k] != configured_permissions[k];
  v := current_permissions[k]
}

permissions_findings = v {
  count(permissions) == 0
  v := "(v) all teams permissions are verified."
}

permissions_findings = v {
  count(permissions) > 1
  c_findings := "(i) %d teams permissions should be reviewed."
  v := sprintf(c_findings, [count(permissions)])
}

permissions_findings = v {
  count(permissions) == 1
  v := "(i) 1 team's permissions should be reviewed."
}

eval = v {
  merged_responses := utils.merge(responses, data.github.orgs.responses)
  v := {
    "state": {"changed_permissions": changed_permissions,
              "permissions": permissions,
	      "members": new_members},
    "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v) },
  }
}

findings := concat("\n", [members_findings, permissions_findings])

report := [
  "## Teams",
  "### Motivation",
  "Excess permissions may be exploited, intentionally or unintentionally.",
  "Limiting permissions will limit the potential damage of credential theft, account-takeover or developer-workstation-takeover.",
  "",

  "### Key Findings",
  "%s",
  "",

  "### Our Recommendation",
  "Review the permissions for team members according to our recommendations below.",
  "Remove team members who are not active or are no longer on the team.",
  "You can manage team permissions at the following links:",
  "%s",
  "",
]

access_settings_urls := { v |
  # t is org/team/owner/repo
  some t, _ in permissions
  some k, r in repos
  splitted_slug := split(t, "/")
  k == concat("/", [splitted_slug[2], splitted_slug[3]])
  v := sprintf("<%s>", [concat("/", [r.html_url, "settings", "access"])])
}

overview_report := v {
  c_report := concat("\n", report)
  urls := utils.json_to_md_list(access_settings_urls, "  ")
  v := sprintf(c_report, [findings, urls])
}
