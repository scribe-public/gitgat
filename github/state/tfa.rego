package github.state.tfa

default exceptions := {}
exceptions := input.tfa.disabled_members

default unenforced_orgs := []
unenforced_orgs := input.tfa.unenforced_orgs