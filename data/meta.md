url -> maybe another url -> JSON response -> compare to state -> eval

```
state_diff = responses_state - configured_state
```

`tfa: "user/orgs" -> "user/orgs/<org-name>/members?tfa_disabled" -> [{"login": "login"}] -> not login in tfa exception <org_name>`

`admins: "user/orgs" -> "user/orgs/<org-name>/members?role=admin" -> [{"login": "<login>":}] -> not login in admins`

`ssh: "user/keys" -> [{"created_at": time, "key": "ssh key"}] -> created_at < state.expiration + time.ns; not "key" in state`

`deploy: "<org>/<repo>" -> [{"<org>/<repo>": [{"created_at": time, "key": "ssh key"}]}] -> same as ssh`

`branches: "repos" -> "repo/branches" -> [{"branch": <branch>}] -> branch protection url -> protection data -> diff`

Teams have 2 rules: permissions and members.
Maybe some code refactoring with new tooling is possible but looks okay for now.
`teams: "org/teams/owner/repo" -> {"permissions": <permissions>} -> not permissions in teams state`
`teams: "user/orgs" -> "orgs/<org>/teams" -> repositories url -> permissions of a team in a repo`

For hooks to be refactored as 2fa, array_subtraction should work for arrays of objects.
On the other hand, can implement similarly to branches.
`hooks: "repos" -> "repo/hooks" -> [{"hook": <hook>}] -> not hook in hooks know`

Does not work without preconfiguring state.
`commits: "org/repo" -> "org/repo/commits" -> [{"commit": "verified"}] -> not verified and not committer in allowed`

`files: "org/repo" -> "org/repo/commits" -> [{"commit": [files]}] -> not regex file in files`

# Schema
orgs := { name: { members_url: } }
repos := { owner/repo: { private: } }
tfa: responses\_state = { "org": [{"login": login}] }
branches:


