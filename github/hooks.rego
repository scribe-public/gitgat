package github.hooks

import future.keywords.in
import data.github.utils as utils

# Get URLs
hooks_urls[name] = url {
  some r in data.github.repos.responses[x]
  name := r.full_name
  url := r.hooks_url
}
responses[x] = utils.error_substitute(
  utils.parse(data.github.api.call_github_abs(hooks_urls[x])),
  { "404 Not Found: Not Found": "This account is not allowed to get hooks configuration for this repository" } )

successes[x] := responses[x] {
  not utils.is_error(responses[x])
}

hooks[repo] = result {
  some repo, repo_hooks in successes

  utils.exists(data.github.state.hooks.config, repo)

  result := [ x |
    h := repo_hooks[_]
    h == data.github.state.hooks.config[repo][_]

    x := { "id": h.id, "created_at": h.created_at, "config": { "url": h.config.url } }
  ]
}

hooks[repo] = result {
  some repo, repo_hooks in successes

  not utils.exists(data.github.state.hooks.config, repo)

  result := [ x |
    h := repo_hooks[_]
    x := { "id": h.id, "created_at": h.created_at, "config": { "url": h.config.url } }
  ]
}

new_hooks[repo] = result {
  some repo, repo_hooks in successes

  result := [ x |
    x := repo_hooks[_]
    not x in hooks[repo]
  ]

  count(result) > 0
}

eval = v {
  pre_merged_responses := utils.merge(data.github.init.responses, data.github.repos.responses)
  merged_responses := utils.merge(responses, pre_merged_responses)
  v := {
    "state": {"hooks": new_hooks},
    "processing_errors": { k: v | some k; v := merged_responses[k]; utils.is_error(v) },
    "description": "Web hooks issue HTTP POST request to specified URLs when configured events occur. Make sure that all the configured hooks are approved. It is recommended to configure a secret associated with a Web hook to verify that the POST request is coming from GitHub."
  }
}
