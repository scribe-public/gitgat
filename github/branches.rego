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

filtered_protection_data[x] = v {
  d := protection_data[x]
  v := {
    "allow_deletions": d["allow_deletions"]["enabled"],
    "allow_force_pushes": d["allow_force_pushes"]["enabled"],
    "block_creations": d["block_creations"]["enabled"],
    "enforce_admins": d["enforce_admins"]["enabled"],
    "required_conversation_resolution": d["required_conversation_resolution"]["enabled"],
    "required_linear_history": d["required_linear_history"]["enabled"],
    "dismiss_stale_reviews": d["required_pull_request_reviews"]["dismiss_stale_reviews"],
    "require_code_owner_reviews": d["required_pull_request_reviews"]["require_code_owner_reviews"],
    "required_signatures": d["required_signatures"]["enabled"],
  }
}

unchanged_protection[x] = protection_data[x] {
  protection_data[x] == data.github.state.branches.protection_data[x]
}

protection_diff[x] = protection_data[x] {
  not protection_data[x] == data.github.state.branches.protection_data[x]
}

recommendation_diff[x] = v {
  not filtered_protection_data[x] == data.github.state.branches.recommended_protection
  v := filtered_protection_data[x]
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

findings := concat("\n\n", [protected_findings, diff_findings])

overview_section := concat("\n", [
  "Branch protection are specific protection mechanisms that limit users from making dangerous modifications of your repositories.",
  "Branch protection rules include requiring pull-request reviews, signed commits and limiting deleting history.",
  "GitHub Branch protection rules are detailed at the following link:",
  "<https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches>.",
  "Branch protection is managed at the repository-branch level.",
])

recommendation_section := concat("\n", [
  "You should configure branch protection for the main branches of your repositories.",
  "Branch protection rules for these branches should include requiring pull-request-reviews, signed commits, and not allowing deletions.",
])

module_title := "## Branch Protection"
overview_report := concat("\n", [
  module_title,
  "### Motivation",
  overview_section,
  "",

  "### Key Findings",
  findings,
  "",
  "See [below](#branch-protection-1) for a detailed report.",
  "",

  "### Our Recommendation",
  recommendation_section,
  "This can be done from the following links:",
  "<details>",
  "<summary>Click to expand</summary>",
  "",
  utils.json_to_md_list(settings_urls, "  "),
  "</details>",
  "",
])

settings_urls := { v |
  some k, r in data.github.repos.repos
  v := sprintf("<%s>", [concat("/", [r.html_url, "settings", "branches"])])
}

detailed_report := concat("\n", [
  module_title,
  overview_section,
  recommendation_section,
  "",
  "Go [back](#branch-protection) to the overview report.",
  "",

  "<details open>",
  "<summary> <b>Branch Protection</b> </summary>",
  "",
  protection_details,
  "</details>",
  "",

  "<details open>",
  "<summary> <b>Unprotected Branches</b> </summary>",
  "",
  unprotected_details,
  "</details>",
  "",
])

create_table_row(k, v, r, e) = res {
  res := { "Setting": k, "Value": v, "Recommended": r, "Explanation": e }
}

explanations := {
  "allow_deletions": "",
  "allow_force_pushes": "",
  "block_creations": "",
  "enforce_admins": "",
  "required_conversation_resolution": "",
  "required_linear_history": "",
  "dismiss_stale_reviews": "",
  "require_code_owner_reviews": "",
  "required_signatures": "",
}

protection_table_data[x] := v {
  d := recommendation_diff[x]
  r := data.github.state.branches.recommended_protection
  v := [ row | some k, diff in d; row := create_table_row(k, d[k], r[k], explanations[k]) ]
}

format_table_row(row) = res {
  res := sprintf("| %v | %v | %v | %v |", [row["Setting"], row["Value"], row["Recommended"], row["Explanation"]])
}

table_header := "| Setting | Value | Recommended | Explanation |"
delim := "| --- | --- | --- | --- |"

format_table(table_data) = res {
  rows := [ format_table_row(x) | some x in table_data ]
  concated_rows := concat("\n", rows)
  res := concat("\n", [table_header, delim, concated_rows, ""])
}

unprotected_details = v {
  count(unprotected_branches) == 0
  v := "None"
}

unprotected_details = v {
  count(unprotected_branches) > 0

  table := { branch: link |
    branch := unprotected_branches[x]
    parts := split(branch, "/")
    repo_full := concat("/", [parts[0], parts[1]])
    link := sprintf("[Settings](<https://github.com/%s/settings/branches>)", [repo_full])
  }

  header := "| Branch | Link |"
  delim := "| --- | --- |"
  body := utils.json_to_md_dict_to_table(table, "  ")
  v := concat("\n", [header, delim, body])
}

protection_details = v {
  count(recommendation_diff) == 0
  v := "None"
}

tables := { k: v |
  some k, t in protection_table_data
  v := sprintf("%s", [sprintf(format_table(t), [])])
}

protection_details = v {
  count(recommendation_diff) > 0
  v := utils.json_to_md_dict(tables, ":\n\n", "  ")
}

verified_history_rule := v {
  v := {
    "id": "GGS002",
    "name": "SourceHistoryVerified",
    "shortDescription": {
      "text": "All commits are signed."
    },
    "fullDescription": {
      "text": concat("\n", [
        "Every change in the revision’s history has at least one strongly authenticated actor identity (author, uploader, reviewer, etc.) and timestamp. It must be clear which identities were verified, and those identities must use two-step verification or similar. (Exceptions noted below.)",
        "",
        "[First-parent history] In the case of a non-linear version control system, where a revision can have more than one parent, only the “first parent history” is in scope. In other words, when a feature branch is merged back into the main branch, only the merge itself is in scope.",
	"",
        "[Historical cutoff] There is some TBD exception to allow existing projects to meet SLSA 3/4 even if historical revisions were present in the history. Current thinking is that this could be either last N months or a platform attestation guaranteeing that future changes in the next N months will meet the requirements.",
      ])
    },
    "messageStrings": {
      "pass": {
        "text": "Signed commits are requried by the branch protection rules."
      },
      "fail": {
        "text": "Signed commits are NOT requried by the branch protection rules."
      }
    }
  }
}

verified_history_result = v {
  filtered_protection_data[input.slsa.protected_branch].required_signatures == true
  v := {
    "ruleId": verified_history_rule.id,
    "level": "note",
    "message": {
      "id": "pass",
    }
  }
}

verified_history_result = v {
  filtered_protection_data[input.slsa.protected_branch].required_signatures == false
  v := {
    "ruleId": verified_history_rule.id,
    "level": "error",
    "message": {
      "id": "fail",
    }
  }
}

verified_history_result = v {
  not utils.exists(filtered_protection_data, input.slsa.protected_branch)
  v := {
    "ruleId": verified_history_rule.id,
    "level": "error",
    "message": {
      "id": "fail",
    }
  }
}


