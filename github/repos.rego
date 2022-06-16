package github.repos

import future.keywords.in
import data.github.utils as utils

rule_set := input.rule_set { utils.exists(input, "rule_set") } else := data.rule_set

orgs = data.github.orgs.orgs

repos_urls[x] = orgs[x].repos_url {
  rule_set == "org"
}
responses[x] = utils.parse(data.github.api.call_github_abs(repos_urls[x]))

user_response := v {
  rule_set == "user"
  v := utils.parse(data.github.api.call_github("user/repos"))
}

# { "user/repos": [ { "name": "repo" } ] }
responses["user/repos"] := user_response

repos[k] = v {
  not utils.is_error(responses[x])

  r := responses[x][y]
  k := r.full_name

  v := json.filter(responses[x][y],
    ["private",
     "hooks_url",
     "keys_url",
     "collaborators_url",
     "owner/login",
     "owner/type",
     "full_name",
     "commits_url",
     "html_url"])
}

private_repos := [ k |
  repos[k].private
]

public_repos := [ k.full_name |
  some k in repos
  not k.full_name in private_repos
]

report := [
  "## Repository Public Visibility and Access",
  "### Motivation",
  "Public GitHub repositories enable open source collaboration. But mistakenly exposing a private repository as public may leak information and allow unwanted people access to your repositories.",
  "",

  "### Key Findings",
  "%s",
  "",

  "### Our Recommendation",
  "Regularly review your repositories to ensure private repositories have not been made public. Managing repositories visibility can be done through the following links:",
  "%s",
  "",
]

findings = v {
  count(public_repos) == 0
  v := "(v) no public repositories"
}

findings = v {
  total_repos := count(public_repos) + count(private_repos)
  v := sprintf("(i) %d out of %d repositories are public", [count(public_repos), total_repos])
}

settings_urls := { v |
  some k in public_repos
  v := sprintf("<%s>", [concat("/", [repos[k].html_url, "settings"])])
}

overview_report := v {
  c_report := concat("\n", report)
  urls := utils.json_to_md_list(settings_urls, "  ")
  v := sprintf(c_report, [findings, urls])
}
