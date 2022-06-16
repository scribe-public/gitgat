package github.orgs

import future.keywords.in
import data.github.utils as utils

default rule_set := "user"
rule_set := input.rule_set { utils.exists(input, "rule_set") } else := data.rule_set

user_response := v {
  rule_set == "user"
  v := utils.parse(data.github.api.call_github("user/orgs"))
}

responses["user/orgs"] := user_response

responses[org.login] = v {
  rule_set == "user"
  some org in user_response
  v := utils.parse(data.github.api.call_github_abs(org.url))
}

responses[split(input.organizations[x], "/")[1]] = v {
  rule_set == "org"
  v := utils.parse(data.github.api.call_github(input.organizations[x]))
}

orgs[x] = responses[x] {
  not x == "user/orgs"
  not utils.is_error(responses[x])
}
