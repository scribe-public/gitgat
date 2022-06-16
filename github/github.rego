# TODO Unclear what happens if the package name is github
# then eval rule becomes recursive
package gh

import future.keywords.in
import data.github.utils as utils

rule_set := input.rule_set { utils.exists(input, "rule_set") } else := data.rule_set

gh_modules["user"] := [
  "tfa",
  "admins",
  "hooks",
  "teams",
  "ssh_keys",
  "deploy_keys",
  "branches",
  "commits"
]

gh_requesting_modules["user"] := [
  "init",
  "repos",
  "tfa",
  "admins",
  "hooks",
  "teams",
  "deploy_keys",
  "branches",
  "commits"
]

gh_modules["org"] := [
  "tfa",
  "admins",
  "hooks",
  "teams",
  "deploy_keys",
  "files",
  "branches",
  "commits"
]

gh_requesting_modules["org"] := [
  "init",
  "repos",
  "tfa",
  "admins",
  "hooks",
  "teams",
  "deploy_keys",
  "files",
  "branches",
  "commits"
]

m_states = { v |
  some m in gh_modules[rule_set]
  v := {
    m: data.github[m].eval.state,
  }
}

m_errors = { v |
  some rm in gh_requesting_modules[rule_set]
  v := {
    concat("_", [rm, "processing_errors"]): { k: v | some k; v := data.github[rm].responses[k]; data.github.utils.is_error(v) }
  }
}

eval := { "state": m_states, "errors": m_errors }

post_gist = response.status {
  response := data.github.api.post_github("gists",
    { "files":
      {
        "report.md":
        { "content": data.github.report.f_report },

        "report.json":
        { "content": sprintf("%s\n", [eval]) }
      },
      "description": "GitHub security posture report"
    }
  )
}
