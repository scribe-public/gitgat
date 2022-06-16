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

more_than_one_admin_members[x] = admin_members[x] {
  count(admin_members[x]) > 1
}

members_findings = v {
  v := { x: count(v) | some x, v in more_than_one_admin_members }
}

report := [
  "## Admin Permissions",
  "### Motivation",
  "Admin permissions allow full control over your organization.",
  "Excessive admin permissions may be exploited, intentionally or unintentionally.",
  "Limiting permissions will limit the potential damage of credential theft, account-takeover or developer-workstation-takeover.",
  "",

  "### Key Findings",
  "The following organizations have more than 1 admin member:",
  "%s",
  "",

  "### Our Recommendation",
  "Review the permissions and limit the number of users with admin permissions, to the minimum required.",
  "You can limit the administrative permissions of members at the following links:",
  "<https://github.com/organizations/my-organization/settings/member_privileges>",
  "",
]

findings = v {
  count(members_findings) > 0
  v := concat("\n", [utils.json_to_md_dict_of_int(members_findings, "  ")])
}

findings = "None" {
  count(members_findings) == 0
}

overview_report := v {
  c_report := concat("\n", report)
  v := sprintf(c_report, [findings])
}
