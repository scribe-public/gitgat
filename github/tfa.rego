package github.tfa

import future.keywords.in
import data.github.utils as utils

orgs = data.github.orgs.orgs

enforced_orgs := [ x | orgs[x].two_factor_requirement_enabled ]
current_unenforced_orgs := [ x.login |
  some x in orgs
  not x.login in enforced_orgs
]

tfa_disabled := "filter=2fa_disabled"

member_orgs_urls[orgs[x].login] = concat("?", [trim_suffix(orgs[x].members_url, "{/member}"), tfa_disabled])
responses[x] = utils.error_substitute(
  utils.parse(data.github.api.call_github_abs(member_orgs_urls[x])),
  { "422 Unprocessable Entity: Only owners can use this filter.": "This account is not the owner of this organization hence it cannot get information about 2fa disabled members." } )

current_tfa_disabled_members[x] = utils.flatten_array(responses[x], "login")
tfa_disabled_members[x] = utils.array_subtraction(current_tfa_disabled_members[x], data.github.state.tfa.exceptions[x])
tfa_disabled_members[x] = current_tfa_disabled_members[x] {
  not utils.exists(data.github.state.tfa.exceptions, x)
}

unenforced_orgs = utils.array_subtraction(current_unenforced_orgs, data.github.state.tfa.unenforced_orgs)
unenforced_orgs = current_unenforced_orgs {
  not utils.exists(data.github.state.tfa, "unenforced_orgs")
}

non_empty_tfa_disabled_members[x] = tfa_disabled_members[x] {
  count(tfa_disabled_members[x]) > 0
}

members_findings = v {
  count(non_empty_tfa_disabled_members) > 1
  c_findings := "(i) %d organizations have members with two factor authentication disabled."
  v := sprintf(c_findings, [count(non_empty_tfa_disabled_members)])
}

members_findings = v {
  count(non_empty_tfa_disabled_members) == 1
  v := "(i) 1 organization has members with two factor authentication disabled."
}

members_findings = v {
  count(non_empty_tfa_disabled_members) == 0
  v := "(v) no organization has members with two factor authentication disabled."
}

unenforced_findings = v {
  count(unenforced_orgs) > 1
  c_findings := "(i) %d organizations lack overall enforcement."
  v := sprintf(c_findings, [count(unenforced_orgs)])
}

unenforced_findings = v {
  count(unenforced_orgs) == 1
  v := "(i) 1 organization lacks overall enforcement."
}

unenforced_findings = v {
  count(unenforced_orgs) == 0
  v := "(v) all organizations have overall enforcement."
}

eval = v {
  merged_responses := utils.merge(responses, data.github.orgs.responses)
  v := { "state": { "disabled_members": non_empty_tfa_disabled_members,
                    "unenforced_orgs": unenforced_orgs },
         "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v) },
  }
}

overview_section := concat("\n", [
  "2 factor authentication protects your account from credential theft.",
])

recommendation_section := concat("\n", [
  "Require all users in your GitHub organization to turn on 2 factor authentication.",
  "They can do it from the following link: <https://github.com/settings/security>.",
  "",
  "Configure your GitHub organizations to enforce 2 factor authentication on all organizations’ users.",
])

module_title := "## Two Factor Authentication"
overview_report := concat("\n", [
  module_title,
  "### Motivation",
  overview_section,
  "",

  "### Key Findings",
  findings,
  "",
  "See [below](#two-factor-authentication-1) for a detailed report.",
  "",

  "### Our Recommendation",
  recommendation_section,
  "That can be done from the following link(s):",
  "<details>",
  "<summary>Click to expand</summary>",
  "",
  utils.json_to_md_list(settings_urls, "  "),
  "</details>",
  "",
])

settings_urls := { v |
  some k in unenforced_orgs
  v := sprintf("<%s>", [concat("/", ["https://github.com/organizations", orgs[k].login, "settings", "security"])])
}

findings := concat("\n\n", [members_findings, unenforced_findings])

detailed_report := concat("\n", [
  module_title,
  overview_section,
  recommendation_section,
  "",
  "Go [back](#two-factor-authentication) to the overview report.",
  "",

  "<details open>",
  "<summary> <b>Two Factor Disabled Members</b> </summary>",
  "",
  disabled_details,
  "</details>",
  "",

  "<details open>",
  "<summary> <b>Two Factor Unenforced Organizations</b> </summary>",
  "",
  unenforced_details,
  "</details>",
  "",
])

disabled_details = v {
  count(non_empty_tfa_disabled_members) == 0
  v := "All members in all organizations have two factor authentication enabled."
}

disabled_details = v {
  count(non_empty_tfa_disabled_members) > 0
  v := utils.json_to_md_dict_of_lists(non_empty_tfa_disabled_members, "  ")
}

unenforced_details = v {
  count(unenforced_orgs) == 0
  v := "All organizations enforce two factor authentication on their members."
}

unenforced_details = v {
  count(unenforced_orgs) > 0
  table := { orgs[k].login: u |
    some k in unenforced_orgs
    u := sprintf("[Settings](<%s>)", [concat("/", ["https://github.com/organizations", orgs[k].login, "settings", "security"])])
  }

  header := "| Organization | Link |"
  delim := "| --- | --- |"
  body := utils.json_to_md_dict_to_table(table, "  ")
  v := concat("\n", [header, delim, body])
}

update := v {
  v := { "disabled_members": current_tfa_disabled_members,
    "unenforced_orgs": current_unenforced_orgs }
}
