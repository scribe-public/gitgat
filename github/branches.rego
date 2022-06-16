package github.branches

import future.keywords.in
import data.github.utils as utils

# Get URLs
branches_urls[name] = url {
  some r in data.github.repos.responses[x]
  name := r.full_name
  url := concat("/", ["repos", name, "branches"])
}
responses[x] = utils.parse(data.github.api.call_github(branches_urls[x]))

successes[x] = responses[x] {
  not utils.is_error(responses[x])
}

branches[name] = branch {
  some x, response in successes

  some branch in response
  name := concat("/", [x, "branches", branch.name])
}

current_unprotected_branches[x] = branches[x] {
  not branches[x].protected
}

unprotected_branches := utils.array_subtraction(
  utils.keys(current_unprotected_branches), data.github.state.branches.unprotected_branches
)

protected_branches[x] = branches[x] {
  branches[x].protected
}

protection_responses[x] = utils.parse(data.github.api.call_github_abs(protected_branches[x].protection_url))
protection_data[x] = protection_responses[x] {
  not utils.is_error(protection_responses[x])
}

unchanged_protection[x] = protection_data[x] {
  protection_data[x] == data.github.state.branches.protection_data[x]
}

protection_diff[x] = protection_data[x] {
  not protection_data[x] == data.github.state.branches.protection_data[x]
}

protected_findings = v {
  count(unprotected_branches) > 1
  c_findings := "(i) %d branches lacking any protection rules."
  v := sprintf(c_findings, [count(unprotected_branches)])
}

protected_findings = v {
  count(unprotected_branches) == 1
  v := "(i) 1 branch lacking any protection rules."
}

protected_findings = v {
  count(unprotected_branches) == 0
  v := "(v) all branches are protected."
}

diff_findings = v {
  count(protected_branches) == 0
  v := "(i) no branches are protected."
}

diff_findings = v {
  count(protection_diff) == 1
  v := "(v) 1 branch is protected."
}

diff_findings = v {
  count(protection_diff) > 1
  c_findings := "(v) %d branches are protected."
  v := sprintf(c_findings, [count(protection_diff)])
}

eval = v {
  pre_merged_responses := utils.merge(responses, data.github.repos.responses)
  merged_responses := utils.merge(protection_responses, pre_merged_responses)

  v := { "state": { "unprotected_branches": unprotected_branches,
                    "protection_diff": protection_diff },
         "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v) },
  }
}

findings := concat("\n", [protected_findings, diff_findings])

report := [
  "## Branch Protection",
  "### Motivation",
  "Branch protection are specific protection mechanisms that limit users from making dangerous modifications of your repositories.",
  "Branch protection rules include requiring pull-request reviews, signed commits and limiting deleting history.",
  "GitHub Branch protection rules are detailed at the following link:",
  "<https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches>",
  "Branch protection is managed at the repository-branch level.",
  "",

  "### Key Findings",
  "%s",
  "",
  "See [below][#branches_details] for a detailed report.",
  "",

  "### Our Recommendation",
  "You should configure branch protection for the main branches of your repositories.",
  "Branch protection rules for these branches should include requiring pull-request-reviews, signed commits, and not allowing deletions.",
  "This can be done from the following links:",
  "%s",
  "",
]

settings_urls := { v |
  some k, r in data.github.repos.repos
  v := sprintf("<%s>", [concat("/", [r.html_url, "settings", "branches"])])
}

overview_report := v {
  c_report := concat("\n", report)
  v := sprintf(c_report, [findings, utils.json_to_md_list(settings_urls, "  ")])
}

d_report := [
  "## Branch Protection {#branches_details}",
  "### Unprotected Branches",
  "%s",
  "",
]

unprotected_details = v {
  count(unprotected_branches) == 0
  v := "None"
}

unprotected_details = v {
  count(unprotected_branches) > 0
  v := utils.json_to_md_list(unprotected_branches, "  ")
}

detailed_report := v {
  v := sprintf(concat("\n", d_report), [unprotected_details])
}
