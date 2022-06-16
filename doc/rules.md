
| Rule \ Account    | Personal                      | Organizational               | Enterprise          |
|-------------------|-------------------------------|------------------------------|---------------------|
| 2fa               | For orgs where user is admin  | For org admin                | For org admins      |
| Admins            | For orgs user belongs to      | Supported                    | Supported           |
| SSH keys          | For user own keys             | Metadata not available       | Possible to support |
| Deploy keys       | For repos where user is admin | For repos where org is owner | Supported           |
| Hooks             | Supported                     | Supported                    | Supported           |
| Teams             | For orgs wher user is admin   | Supported                    | Supported           |
| Files             | Supported                     | Supported                    | Supported           |
| Commits           | Supported                     | Supported                    | Supported           |
| Branch protection | For repo admin                | For repo admin               | For repo admin      |
|-------------------|-------------------------------|------------------------------|---------------------|
| Audit log         | Not supported                 | Not supported                | Supported           |
| Secret scanning   | Not part of GitHub API        |                              |                     |
| Dependabot        |                               |                              |                     |
