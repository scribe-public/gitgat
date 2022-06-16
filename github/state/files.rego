package github.state.files

default permissions := {
  ".circle-ci/*": []
}

# Only commiters from the list are allowed to change files
permissions := input.files.permissions

