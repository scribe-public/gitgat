package github.admins

import future.keywords.in
import data.github.utils as utils
import data.github.gh_utils as gh_utils

admin_filter := "role=admin"
orgs := data.github.orgs.orgs
responses[x] = gh_utils.get_nested_data(orgs[x], "members_url", "{/member}", admin_filter, {})
current_admins[x] = utils.flatten_array(responses[x], "login")
admin_members[x] = utils.array_subtraction(current_admins[x], data.github.state.admins.members[x])
admin_members[x] = current_admins[x] {
  not utils.exists(data.github.state.admins.members, x)
}

eval = v {
  merged_responses := utils.merge(responses, data.github.orgs.responses)
  v := { "state": {"members": admin_members},
         "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v)},
  }
}

non_empty_admin_members[x] = admin_members[x] {
  count(admin_members[x]) > 0
}

more_than_two_admin_members[x] = admin_members[x] {
  count(admin_members[x]) > 2
}

members_findings = v {
  v := { x: count(v) | some x, v in more_than_two_admin_members }
}

overview_section := concat("\n", [
  "Admin permissions allow full control over your organization.",
  "Excessive admin permissions may be exploited, intentionally or unintentionally.",
  "Limiting permissions will limit the potential damage of credential theft, account-takeover or developer-workstation-takeover.",
])

recommendation_section := concat("\n", [
  "Review the permissions and limit the number of users with admin permissions, to the minimum required.",
])

report := [
  "## Admin Permissions",
  "### Motivation",
  "%s",
  "",

  "### Key Findings",
  "The following organizations have more than 2 admin members:",
  "%s",
  "",
  "See [below](#admin-permissions-1) for a detailed report.",
  "",

  "### Our Recommendation",
  "%s",
  "You can limit the administrative permissions of members at the following links:",
  "<details>",
  "<summary>Click to expand</summary>",
  "",
  "%s",
  "</details>",
  "",
]

findings = v {
  count(members_findings) > 0
  v := concat("\n", [utils.json_to_md_dict(members_findings, ":", "  ")])
}

findings = "None" {
  count(members_findings) == 0
}

settings_urls := { v |
  some k, _ in members_findings
  v := sprintf("<%s>", [concat("/", ["https://github.com/organizations", k, "settings", "member_privileges"])])
}

overview_report := v {
  c_report := concat("\n", report)
  urls := utils.json_to_md_list(settings_urls, "  ")
  v := sprintf(c_report, [overview_section, findings, recommendation_section, urls])
}

d_report := [
  "## Admin Permissions",
  "%s",
  "%s",
  "",
  "Go [back](#admin-permissions) to the overview report.",
  "",

  "<details open>",
  "<summary> <b>Admin Members</b> </summary>",
  "",
  "%s",
  "</details>",
  "",
]

admin_details = v {
  count(non_empty_admin_members) == 0
  v := "None"
}

admin_details = v {
  count(non_empty_admin_members) > 0
  v := utils.json_to_md_dict_of_lists(non_empty_admin_members, "  ")
}

detailed_report := v {
  v := sprintf(concat("\n", d_report), [overview_section, recommendation_section, admin_details])
}

update := v {
  v := { "known": current_admins, }
}

# state: empty, admin_members: admin_data -> update: admin_data
# state: admin_data, admin_members: empty -> update:
#   if current_admins == admin_data -> update: current_admins
#   if current_admins < admin_data -> update: current_admins
# state: admin1, admin_members: admin2 -> update:
#   if current_admins == admin1+admin2 -> update: current_admins
#   if current_admins == admin2 -> update: current_admins
