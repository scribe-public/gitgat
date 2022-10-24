package github.files

import future.keywords.in
import data.github.utils as utils

all_commits_urls[x] = trim_suffix(data.github.repos.repos[x].commits_url, "{/sha}")

commits_responses[x] = utils.parse(data.github.api.call_github_abs(all_commits_urls[x])) {
  some x, _ in data.github.state.files.permissions
}

commits_successes[x] = commits_responses[x] {
  not utils.is_error(commits_responses[x])
}

# Get URLs
# "<org>/<repo>": [ { "sha": <sha>, "url": <url> } ]
# "<org>/<repo>": {"sha": <url>}

commits_urls = { repo: commits |
  some repo, files in data.github.state.files.permissions
  commits = { sha: url |
    some commit in commits_successes[repo]
    sha := commit.sha
    url := commit.url
  }
}

responses = { repo: commits |
  some repo, urls in commits_urls
  commits = { sha: response |
    some sha, url in urls
    response := data.github.utils.parse(data.github.api.call_github_abs(url))
  }
}

# "org/repo": {
#   "sha": {
#     "committer": "login",
#     "files": [ "filename" ]
#   }
# }
filtered = { repo: filtered_commits |
  some repo, response in responses
  filtered_commits = { sha: commit |
    some sha, commits in response
    filtered_commit := json.filter(commits, ["author/login", "committer/login", "files", "html_url"])
    commit := {
      "author": filtered_commit.author.login,
      "committer": filtered_commit.committer.login,
      "html_url": filtered_commit.html_url,
      "files": [ filename |
        filename := filtered_commit.files[_].filename
      ]
    }
  }
}

commit_contains_file(permissions, commit) {
  p := permissions[file]
  regex.match(file, commit.files[x])
}

commit_okay(permissions, commit) {
  commit_contains_file(permissions, commit)

  p := permissions[file]
  regex.match(file, commit.files[x])
  commit.committer == p.committers[y]
  commit.author == p.authors[z]
}

commit_okay(permissions, commit) {
  not commit_contains_file(permissions, commit)
}

violating_commits = { repo: checked |
  some repo, commits in filtered
  checked = { sha: commit |
    some sha, commit in commits
    not commit_okay(data.github.state.files.permissions[repo], commit)
  }
}

eval = v {
  merged_responses := responses
  v := {
    "state": {"violating_commits": violating_commits},
    "processing_errors": { k: v | some k; v := merged_responses[k]; data.github.utils.is_error(v) },
    "description": "The files module checks for modifications of specific files in a repostitory. Only committers that are listed in the configurable state are allowed to modify those files. This module does nothing without pre-configuring."
  }
}

overview_section :=
`
### Motivation

In many cases your repository includes sensitive files,
such as CI pipeline and IaC definitions. You should manage
who’s allowed to modify these files. To use this rule, configure
the file-name patterns of the files you want to track.
`

recommendation_section :=
`Configure the rule and regularly track access to sensitive files.`

module_title := "## Fine Grained File Access Tracking"
overview_report := concat("\n", [
  module_title,
  overview_section,

  "### Key Findings",
  findings,
  "",
  "See [below](#fine-grained-file-access-tracking-1) for a detailed report.",
  "",

  "### Our Recommendation",
  "",
])

findings = "There are no violating commits." {
  violating_counts := [ count(x) | some x in violating_commits ]
  all([violating_counts[_] == 0])
}

findings = sprintf("There are %d violating commits.", [v]) {
  violating_counts := [ count(x) | some x in violating_commits ]
  any([violating_counts[_] > 0])
  v := sum(violating_counts)
}

violating_details = v {
  count(violating_commits) > 0
  violating_commits_lists := { k: v |
    some k, vv in violating_commits
    v := [ c.html_url | some c in vv ]
  }
  v := utils.json_to_md_dict_of_lists(violating_commits_lists, "  ")
  #v := "Some"
}

detailed_report := concat("\n", [
  module_title,
  overview_section,
  recommendation_section,
  "",
  "Go [back](#fine-grained-file-access-tracking) to the overview report.",
  "",

  "<details open>",
  "<summary> <b>Violating Commits</b> </summary>",
  "",
  violating_details,
  "</details>",
  "",
])
