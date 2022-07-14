package github.collaborators

import future.keywords.in
import data.github.utils as utils

orgs := data.github.orgs.orgs

collaborators_urls[r.full_name] = url {
  some r in data.github.repos.repos
  url := trim_suffix(r.collaborators_url, "{/collaborator}")
}
collaborators_responses[x] = utils.parse(data.github.api.call_github_abs(collaborators_urls[x]))

members_urls[orgs[x].login] = trim_suffix(orgs[x].members_url, "{/member}")
members_responses[x] = utils.parse(data.github.api.call_github_abs(members_urls[x]))

collaborators_successes[x] = collaborators_responses[x] {
  not utils.is_error(collaborators_responses[x])
}
members_successes[x] = members_responses[x] {
  not utils.is_error(members_responses[x])
}

collaborators[x] = utils.flatten_array(collaborators_successes[x], "login")
members[x] = utils.flatten_array(members_successes[x], "login")

non_members_collaborators[k] = vv {
  some k, v in collaborators

  owner := split(k, "/")[0]

  vv := utils.array_subtraction(v, members[owner])
  owner in utils.keys(members)
  not owner in v
}

non_members_collaborators[k] = vv {
  some k, v in collaborators

  owner := split(k, "/")[0]

  vv := v
  not owner in utils.keys(members)
  not owner in v
}


unknown_collaborators[x] = utils.array_subtraction(non_members_collaborators[x], data.github.state.collaborators.known[x])
unknown_collaborators[x] = non_members_collaborators[x] {
  not utils.exists(data.github.state.collaborators.known, x)
}

non_empty_collaborators[x] = unknown_collaborators[x] {
  count(unknown_collaborators[x]) > 0
}

eval = v {
  pre_merged_responses := utils.merge(collaborators_responses, data.github.repos.responses)
  merged_responses := utils.merge(members_responses, pre_merged_responses)
  v := { "state": {"unknown": unknown_collaborators},
         "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v)},
  }
}

members_findings = v {
  count(non_empty_collaborators) > 1
  c_findings := "(i) %d of your repositories have collaborators."
  v := sprintf(c_findings, [count(non_empty_collaborators)])
}

members_findings = v {
  count(non_empty_collaborators) == 1
  v := "(i) 1 repository has collaborators."
}

members_findings = v {
  count(non_empty_collaborators) == 0
  v := "(v) your repositories do not have out of organization collaborators."
}

findings := concat("\n", [members_findings])

overview_section := concat("\n", [
  "Collaborators are people outside of the organization who are active in your repositories.",
])

recommendation_section := concat("\n", [
  "Regularly review the collaborators of your repositories, and block users that are not collaborators anymore.",
])

report := [
  "## Collaborators",
  "### Motivation",
  "%s",
  "",

  "### Key Findings",
  "%s",
  "",
  "See [below](#collaborators-1) for a detailed report.",
  "",

  "### Our Recommendation",
  "%s",
  "Blocking members is done through the following links:",
  "<details>",
  "<summary>Click to expand</summary>",
  "",
  "%s",
  "</details>",
  "",
]

settings_urls := { v |
  some k, r in orgs
  v := sprintf("<%s>", [concat("/", ["https://github.com/organizations", r.login, "settings", "member_privileges"])])
}

overview_report := v {
  c_report := concat("\n", report)
  v := sprintf(c_report, [overview_section, findings, recommendation_section, utils.json_to_md_list(settings_urls, "  ")])
}

d_report := [
  "## Collaborators",
  "%s",
  "%s",
  "",
  "Go [back](#collaborators) to the overview report.",
  "",

  "<details open>",
  "<summary> <b>Outside Collaborators</b> </summary>",
  "",
  "%s",
  "</details>",
  "",
]

collaborators_details = v {
  count(non_empty_collaborators) == 0
  v := "None"
}

collaborators_details = v {
  count(non_empty_collaborators) > 0
  v := utils.json_to_md_dict_of_lists(non_empty_collaborators, "  ")
}

detailed_report := v {
  v := sprintf(concat("\n", d_report), [overview_section, recommendation_section, collaborators_details])
}
