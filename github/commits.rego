package github.commits

import future.keywords.in
import data.github.utils as utils

commits_urls[x] = trim_suffix(data.github.repos.repos[x].commits_url, "{/sha}")
#commits_urls[x] = concat("?", [trim_suffix(data.github.repos.repos[x].commits_url, "{/sha}"), "per_page=2&page=2"])

responses[x] = utils.parse(data.github.api.call_github_abs(commits_urls[x])) {
  some x, _ in data.github.state.commits.config
}

successes[x] = responses[x] {
  not utils.is_error(responses[x])
}

# Not verified and not allowed
commits_unverified = { repo: result |
  some repo, repo_commits in successes
  result := [ x |
    c := repo_commits[_]
    not c.commit.verification.verified
    not c.author.login in data.github.state.commits.config[repo].allow_unverified
    x := { "sha": c.sha, "message": c.commit.message, "author": c.author.login }
  ]
}

commits[x] := utils.flatten_array(successes[x], "sha")
commits_history[x] := utils.array_subtraction(commits[x], data.github.state.commits.config[x].history)
authors[x] := utils.flatten_array(utils.flatten_array(successes[x], "author"), "login")
authors_set := { x: v |
  some x, arr in authors
  v := { y | y := arr[_] }
}

eval = v {
  merged_responses := utils.merge(responses, data.github.repos.responses)
  v := {
    "state": {"unverified": commits_unverified,
              "history": commits_history},
    "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v) },
  }
}

findings = v {
  count(commits_unverified) == 0
  count(commits) > 0
  v := "(v) all commits are verified."
}

findings = v {
  count(commits_unverified) == 0
  count(commits) == 0
  v := "(i) no data is fetched. The module needs configuration."
}

findings = v {
  count(commits_unverified) == 1
  v := "(i) 1 commit is not verified."
}

findings = v {
  count(commits_unverified) > 1
  c_findings := "(i) %d commits are not verified."
  v := sprintf(c_findings, [count(commits_unverified)])
}

report := [
  "## Signed Commits",
  "### Motivation",
  "Signing commits prevents unauthorized people from committing code into your repositories.",
  "In case you have not deployed appropriate branch protection rules,",
  "the following findings display the signing status of individual commits.",
  "",

  "### Key Findings",
  "%s",
  "",

  "### Our Recommendation",
  "You should either configure branch protection rules to enforce signed commits, or require developers to sign their commits.",
  "Instructions for configuring your local git installation to sign commits to work with GitHub can be found here:",
  "<https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits>",
  "",
]

overview_report := v {
  c_report := concat("\n", report)
  v := sprintf(c_report, [findings])
}
