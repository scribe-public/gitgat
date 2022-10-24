package github.deploy_keys

import future.keywords.in
import data.github.utils as utils

# Get URLs
deploy_keys_urls[r.full_name] = url {
  some r in data.github.repos.responses[x]
  url := trim_suffix(r.keys_url, "{/key_id}")
}
responses[x] = utils.error_substitute(
  utils.parse(data.github.api.call_github_abs(deploy_keys_urls[x])),
  { "404 Not Found: Not Found": "This accout is not allowed to get deploy keys for this repository" } )

successes[x] = responses[x] {
  not utils.is_error(responses[x])
}

deploy_keys[x] = utils.flatten_array(successes[x], "key")
keys[x] = utils.array_subtraction(deploy_keys[x], data.github.state.deploy_keys.keys[x])
keys[x] = deploy_keys[x] {
  not utils.exists(data.github.state.deploy_keys.keys, x)
}

non_empty_keys[x] = keys[x] {
  count(keys[x]) > 0
}

expired[k.id] = v {
  k := successes[_][_]
  utils.is_expired(k, data.github.state.deploy_keys.expiration)
  v := json.filter(k, ["id", "created_at"])
}

all_keys[k.id] = v {
  k := successes[_][_]
  k.key == keys[_][_]
  v := json.filter(k, ["id", "created_at", "title", "url"])
}

non_empty_findings = v {
  count(non_empty_keys) > 1
  c_findings := "(i) %d keys are configured for the repositories."
  v := sprintf(c_findings, [count(non_empty_keys)])
}

non_empty_findings = v {
  count(non_empty_keys) == 1
  v := "(i) 1 key is configured for the repository."
}

non_empty_findings = v {
  count(non_empty_keys) == 0
  v := "(v) no new keys."
}

expired_findings = v {
  count(expired) == 0
  v := "(v) no keys are expired."
}

expired_findings = v {
  count(expired) == 1
  v := "(i) 1 key is expired."
}

expired_findings = v {
  count(expired) > 1
  c_findings := "(i) %d keys are expired."
  v := sprintf(c_findings, [count(expired)])
}


eval = v {
  merged_responses := utils.merge(responses, data.github.repos.responses)
  v := { "state": {"expired": expired, "keys": non_empty_keys},
         "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v) },
  }
}

findings := concat("\n\n", [non_empty_findings, expired_findings])

overview_section := concat("\n", [
  "Deploy keys are an authentication tool to enable access to repositories.",
  "Manage your deploy keys to ensure you have not left keys that can be wrongfully used.",
  "GitHub’s explanation about deploy keys can be found here:",
  "<https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys>",
  "",
])

recommendation_section := concat("\n", [
  "Deploy keys are SSH keys assigned to each repository that allow reading and (optional) writing to private repositories.",
  "We recommend you review your SSH keys regularly; ensure you are familiar with the keys and their use.",
  "In case of an upcoming expiration date - ensure you replace the keys on time.",
])

module_title := "## Deploy Keys"
overview_report := concat("\n", [
  module_title,
  "### Motivation",
  overview_section,
  "",

  "### Key Findings",
  findings,
  "",
  "See [below](#deploy-keys-1) for a detailed report.",
  "",

  "### Our Recommendation",
  recommendation_section,
  "Deploy keys can be managed at the following links:",
  "<details>",
  "<summary>Click to expand</summary>",
  "",
  utils.json_to_md_list(settings_urls, "  "),
  "</details>",
  "",
])

settings_urls := { v |
  some x, _ in non_empty_keys
  r := data.github.repos.repos[x]
  v := sprintf("<%s>", [concat("/", [r.html_url, "settings", "keys"])])
}

detailed_report := concat("\n", [
  module_title,
  overview_section,
  recommendation_section,
  "",
  "Go [back](#deploy-keys) to the overview report.",
  "",

  "<b>Expired</b>",
  "",
  expired_details,
  "",

  "<b>All</b>",
  "",
  non_empty_details,
  ""
])

expired_details = v {
  count(expired) == 0
  v := "None"
}

expired_details = v {
  count(expired) > 0
  v_data := [ q |
    k := expired[_]
    q := { "Key": k.title, "Creation time": k.created_at,
      "Link": k.url }
  ]

  expired_details_keys := ["Key", "Creation time", "Link"]
  v := sprintf("%s", [utils.json_to_md_array_of_dict_to_table(v_data,
    expired_details_keys, "")])
}

non_empty_details = v {
  count(all_keys) == 0
  v := "None"
}

non_empty_details = v {
  count(all_keys) > 0
  v_data := [ q |
    some k in all_keys
    q := { "Key": k.title, "Creation time": k.created_at,
      "Link": k.url }
  ]

  non_empty_details_keys := ["Key", "Creation time", "Link"]
  v := sprintf("%s", [utils.json_to_md_array_of_dict_to_table(v_data,
    non_empty_details_keys, "")])
}

# See comment about update in admins.rego
update := v {
  v := { "keys": non_empty_keys, }
}
