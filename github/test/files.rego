package test.files

files_responses := {
  "owner/repo": {
    "sha-1": okay_commit
  }
}

permissions := {
  "owner/repo": {
    ".*md": [ "commiter-1" ]
  }
}

permissions_noregex := {
  "owner/repo": {
    "1": [ "commiter-1" ]
  }
}

okay_commit := {
  "committer": "commiter-1",
  "files": [
    "README.md"
  ]
}

not_okay_commit := {
  "committer": "commiter-2",
  "files": [
    "README.md"
  ]
}

okay_commit_noregex := {
  "committer": "commiter-1",
  "files": [
    "1"
  ]
}

not_okay_commit_noregex := {
  "committer": "commiter-2",
  "files": [
    "1"
  ]
}

test_regex {
  regex.match(".*md", "README.md")
}

test_regex_noregex {
  regex.match("1", "1")
}

test_commit_okay {
  data.github.files.commit_okay(permissions["owner/repo"], okay_commit)
}

test_commit_not_okay {
  not data.github.files.commit_okay(permissions["owner/repo"], not_okay_commit)
}

test_commit_okay_noregex {
  data.github.files.commit_okay(permissions_noregex["owner/repo"], okay_commit_noregex)
}

test_commit_not_okay_noregex {
  not data.github.files.commit_okay(permissions_noregex["owner/repo"], not_okay_commit_noregex)
}
