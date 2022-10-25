package github.test.deploy_keys

import future.keywords.in

expired_key := { "org/repo": [{ "id": 1, "created_at": "2010-01-01T00:00:00Z" }] }
not_expired_key := { "org/repo": [{ "id": 1, "created_at": "2022-01-01T00:00:00Z" }] }

expiration := [1, 0, 0]

test_expired {
  count(data.github.deploy_keys.expired) == 1 with data.github.deploy_keys.responses as expired_key with input.deploy_keys.expiration as expiration
}

test_not_expired {
  count(data.github.deploy_keys.expired) == 0 with data.github.deploy_keys.responses as not_expired_key with input.deploy_keys.expiration as expiration
}

#known_key := { "org/repo": [ "ssh-rsa" ] }
known_key := { "org/repo": [
  { "id": 1, "key": "ssh-rsa" },
  { "id": 2, "key": "ssh-ed25591" },
] }

state_known_key := { "org/repo": ["ssh-rsa"] }

test_known {
  count(data.github.deploy_keys.non_empty_keys) == 1
    with data.github.deploy_keys.responses as known_key
    with data.github.state.deploy_keys.keys as state_known_key
}
