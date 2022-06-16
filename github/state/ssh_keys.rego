package github.state.ssh_keys

# Default expiration is one year
default expiration := [1, 0, 0]
expiration := input.ssh_keys.expiration

default keys := []
keys := input.ssh_keys.keys
