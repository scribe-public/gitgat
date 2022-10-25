package github.secrets

import future.keywords.in
import data.github.utils as utils

default rule_set := "user"
rule_set := input.rule_set { utils.exists(input, "rule_set") } else := data.github.rule_set

responses[org.login] = v {
  some org in data.github.orgs.orgs
  secrets_url := concat("/", ["orgs", org.login, "actions", "secrets"])
  v := utils.parse(data.github.api.call_github(secrets_url))
}

secrets[x] = responses[x] {
  not utils.is_error(responses[x])
}
