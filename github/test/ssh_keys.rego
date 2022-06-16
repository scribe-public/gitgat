package test.ssh_keys

import future.keywords.in

expired_key := { "keys": [{ "id": 1, "created_at": "2010-01-01T00:00:00Z" }] }
not_expired_key := { "keys": [{ "id": 1, "created_at": "2022-01-01T00:00:00Z" }] }

expiration := [1, 0, 0]

test_expired {
  count(data.github.ssh_keys.expired) == 1 with data.github.ssh_keys.responses as expired_key["keys"] with input.ssh_keys.expiration as expiration
}

test_not_expired {
  count(data.github.ssh_keys.expired) == 0 with data.github.ssh_keys.responses as not_expired_key["keys"]
}

known_key := [{ "id": 1, "key": "ssh-rsa" }]
state_known_key := ["ssh-rsa"]

test_known {
  count(data.github.ssh_keys.keys) == 0 with data.github.ssh_keys.responses as known_key with data.github.state.ssh_keys.keys as state_known_key
}

state_unknown_key := ["not-ssh-rsa"]

test_unknown {
  count(data.github.ssh_keys.keys) == 1 with data.github.ssh_keys.responses as known_key with data.github.state.ssh_keys.keys as state_unknown_key
}

