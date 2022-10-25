package github.repos

import future.keywords.in
import data.github.utils as utils

rule_set := input.rule_set { utils.exists(input, "rule_set") } else := data.github.rule_set

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
     "name",
     "commits_url",
     "html_url"])
}

owners := { r.owner.login |
  some r in repos
}

repos_per_owner[x] = v {
  some x in owners
  v := [ r.full_name | some r in repos; r.owner.login == x ]
}

private_repos := [ k |
  repos[k].private
]

public_repos := [ k.full_name |
  some k in repos
  not k.full_name in private_repos
]

private_repos_per_owner[x] = v {
  some x, x_repos in repos_per_owner
  v := [ r | some r in private_repos; some y in x_repos; r == y ]
}

public_repos_per_owner[x] = v {
  some x, x_repos in repos_per_owner
  v := [ r | some r in public_repos; some y in x_repos; r == y ]
}

overview_section := concat("\n", [
  "Public GitHub repositories enable open source collaboration.",
  "But mistakenly exposing a private repository as public",
  "may leak information and allow unwanted people access to your repositories.",
])

recommendation_section := concat("\n", [
  "Regularly review your repositories to ensure private repositories have not been made public.",
])

report := [
  "## Repository Public Visibility and Access",
  "### Motivation",
  "%s",
  "",

  "### Key Findings",
  "%s",
  "",
  "See [below](#repository-public-visibility-and-access-1) for a detailed report.",
  "",

  "### Our Recommendation",
  "%s",
  "",
  "Managing repositories visibility can be done through the following links:",
  "<details>",
  "<summary>Click to expand</summary>",
  "",
  "%s",
  "</details>",
  "",
]

findings_per_owner[x] = v {
  count(public_repos_per_owner[x]) == 0
  v := "(v) no public repositories"
}

# format_strings := {
#   { 1:
#     { 1: "(i) %d out of %d repository is public" },
#     {
# format_string[num_public_repos][total_repos]

findings_per_owner[x] = v {
  num_public_repos := count(public_repos_per_owner[x])
  num_public_repos == 1
  total_repos := num_public_repos + count(private_repos_per_owner[x])
  total_repos > 1
  v := sprintf("(i) %d out of %d repositories is public", [num_public_repos, total_repos])
}

findings_per_owner[x] = v {
  num_public_repos := count(public_repos_per_owner[x])
  num_public_repos == 1
  total_repos := num_public_repos + count(private_repos_per_owner[x])
  total_repos == 1
  v := sprintf("(i) %d out of %d repository is public", [num_public_repos, total_repos])
}

findings_per_owner[x] = v {
  num_public_repos := count(public_repos_per_owner[x])
  num_public_repos > 1
  total_repos := num_public_repos + count(private_repos_per_owner[x])
  total_repos > 1
  v := sprintf("(i) %d out of %d repositories are public", [num_public_repos, total_repos])
}

findings = v {
  header := "| Owner | Findings |"
  delim := "| --- | --- |"
  body := utils.json_to_md_dict_to_table(findings_per_owner, "  ")
  v := concat("\n", [header, delim, body])
}

settings_urls := { v |
  some k in public_repos
  v := sprintf("<%s>", [concat("/", [repos[k].html_url, "settings"])])
}

overview_report := v {
  c_report := concat("\n", report)
  urls := utils.json_to_md_list(settings_urls, "  ")
  v := sprintf(c_report, [overview_section, findings, recommendation_section, urls])
}

d_report := [
  "## Repository Public Visibility and Access",
  "%s",
  "%s",
  "",
  "Go [back](#repository-public-visibility-and-access) to the overview report.",
  "",

  "<details open>",
  "<summary> <b>Repositories Visibility Settings (for Public Repositories)</b> </summary>",
  "",
  "%s",
  "</details>",
  "",
]

settings_details = v {
  count(settings_urls) == 0
  v := "No public repositories."
}

settings_details = v {
  count(settings_urls) > 0
  v_data := [ q |
    r := repos[x]
    not r.private
    url := concat("/", [r.html_url, "settings"])
    f_url := sprintf("[Settings](<%s>)", [url])
    q := { "Owner": r.owner.login, "Repository": r.name,
      "Link": f_url }
  ]

  settings_details_keys := ["Owner", "Repository", "Link"]
  v := sprintf("%s", [utils.json_to_md_array_of_dict_to_table(v_data,
    settings_details_keys, "")])
}

detailed_report := v {
  v := sprintf(concat("\n", d_report),
    [overview_section, recommendation_section, settings_details])
}

version_controlled_rule := v {
  v := {
    "id": "GGS001",
    "name": "SourceVersionControlled",
    "shortDescription": {
      "text": "The code must be version-controlled."
    },
    "fullDescription": {
      "text": concat("\n", [
        "Every change to the source is tracked in a version control system that meets the following requirements:",
        "",
        "[Change history] There exists a record of the history of changes that went into the revision. Each change must contain: the identities of the uploader and reviewers (if any), timestamps of the reviews (if any) and submission, the change description/justification, the content of the change, and the parent revisions.",
        "",
        "[Immutable reference] There exists a way to indefinitely reference this particular, immutable revision. In git, this is the {repo URL + branch/tag/ref + commit ID}.",
        "",
        "Most popular version control system meet this requirement, such as git, Mercurial, Subversion, or Perforce.",
        "",
        "NOTE: This does NOT require that the code, uploader/reviewer identities, or change history be made public. Rather, some organization must attest to the fact that these requirements are met, and it is up to the consumer whether this attestation is sufficient.",
      ])
    },
    "messageStrings": {
      "pass": {
        "text": "The code is version-controlled in {0}."
      }
    }
  }
}

version_controlled_result := v {
  v := {
    "ruleId": version_controlled_rule.id,
    "level": "note",
    "message": {
      "id": "pass",
      "arguments": [
        input.slsa.repository_url,
      ]
    }
  }
}
