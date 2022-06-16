package github.state.deploy_keys

# Default expiration is 1 year
default expiration := [1, 0, 0]
expiration := input.deploy_keys.expiration

default keys := {}
keys := input.deploy_keys.keys


