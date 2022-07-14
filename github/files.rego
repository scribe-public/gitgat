package github.files

import future.keywords.in

# Get URLs
# "<org>/<repo>": [ { "sha": <sha>, "url": <url> } ]
# "<org>/<repo>": {"sha": <url>}
commits_urls = { repo: commits |
  some repo, files in data.github.state.files.permissions
  commits = { sha: url |
    some commit in data.github.init.responses[repo]
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
    filtered_commit := json.filter(commits, ["committer/login", "files"])
    commit := {
      "committer": filtered_commit.committer.login,
      "files": [ filename |
        filename := filtered_commit.files[_].filename
      ]
    }
  }
}

commit_okay(permissions, commit) {
  p := permissions[file]
  regex.match(file, commit.files[x])
  commit.committer == p[y]
}

violating_commits = { repo: checked |
  some repo, commits in filtered
  checked = { sha: commit |
    some sha, commit in commits
    not commit_okay(data.github.state.files.permissions[repo], commit)
  }
}

eval = v {
  merged_responses := data.github.utils.merge(responses, data.github.init.responses)
  v := {
    "state": {"violating_commits": violating_commits},
    "processing_errors": { k: v | some k; v := merged_responses[k]; data.github.utils.is_error(v) },
    "description": "The files module checks for modifications of specific files in a repostitory. Only committers that are listed in the configurable state are allowed to modify those files. This module does nothing without pre-configuring."
  }
}

findings := concat("\n", ["(Coming soon)"])

report := [
  "## Fine Grained File Access Tracking",
  "### Motivation",
  "In many cases your repository includes sensitive files, such as CI pipeline and IaC definitions.",
  "You should manage who’s allowed to modify these files.",
  "To use this rule, configure the file-name patterns of the files you want to track.",
  "",

  "### Key Findings",
  "%s",
  "",

  "### Our Recommendation",
  "Configure the rule and regularly track access to sensitive files.",
  "",
]

overview_report := v {
  c_report := concat("\n", report)
  v := sprintf(c_report, [findings])
}
