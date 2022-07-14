package github.state.branches

default unprotected_branches := []
default protection_data := {}

unprotected_branches := input.branches.unprotected
protection_data := input.branches.protection_data

recommended_protection := {
   "allow_deletions": false,
   "allow_force_pushes": false,
   "block_creations": false,
   "enforce_admins": true,
   "required_conversation_resolution": true,
   "required_linear_history": true,
   "dismiss_stale_reviews": true,
   "require_code_owner_reviews": true,
   "required_signatures": true
}
