

<center><img src='https://repository-images.githubusercontent.com/503625714/4c7c0d6c-cd0c-448c-98b9-e24be16b3ca4' alt='Gitgat' width="250" /></center>

# Source control system security posture
SCM (Source Control Management) security is of high importance as it serves as an entry point to the whole CI/CD pipeline. This repository contains policies that verify SCM (currently GitHub's) organization/repositories/user accounts security. The policies are evaluated using [Open Policy Agent (OPA)](https://openpolicyagent.org).


There are different sets of policies depending on which account is being evaluated. **Most policies are only relevant for organization owners**. See the rulesets section bellow.

The policies are evaluated against a certain state. When executed for the first time, the state is empty. The returned data should be reviewed, and the security posture should be manually evaluated (with recommendations from each module). If the state is approved, it should be added to the input data, so that the next evaluation of policies tracks the changes of the state. More information about the state configurable for each module is available in each module's corresponding section.


# Usage
## Get a GitHub Personal Access Token
1. Generate a Personal Access Token with necessary permissions on GitHub in Settings > Developer Settings. 
You will need the following permissions:
* read:org
* read:user 
* read:public_key
* repo:status
* repo_deployment
* read:repo_hook
* public_repo
* gist

If needed, refer to each module's section to figure out what permissions are needed to evaluate the module's policies.

2. Set an environment variable with the token, for example:

```sh
export GH_TOKEN='<token>'
```

## Run Using Docker
Run the following to get the report as a gist in your GitHub Account:

```sh
docker run -e GH_TOKEN scribesecurity/gitgat:latest data.gh.post_gist
```

You can access your report from your gists <https://gist.github.com/>

Run the following to get the report as a Markdown file:
```sh
docker run -e GH_TOKEN scribesecurity/gitgat:latest data.github.report.print_report 2> report.md
```

Run the following to get the report as a JSON object:
```sh
docker run -e GH_TOKEN scribesecurity/gitgat:latest data.gh.eval
```
In order to run the report using the variables and state you have saved in the input.json file, use this command:
```sh
docker run -e GH_TOKEN -v <full_path_to_directory_containing_input_file>:/var/opt/opa scribesecurity/gitgat:latest
```
If you have already included the token in the input.json file, you can shorten it to:
```sh
docker run -v <full_path_to_directory_containing_input_file>:/var/opt/opa scribesecurity/gitgat:latest
```
Note that the default report is the JSON version, so if you want to get the Markdown file you need to specify it as seen at the top of this section.

## Run Using the OPA CLI

### Install OPA and additional tools
In order to execute the evaluation of the policies, download and install OPA (version 0.40.0 and up) from <https://www.openpolicyagent.org/docs/latest/#running-opa>.
Binaries are available for macOS, Linux and Windows. 

The examples below demonstrating safe handling of GitHub's Personal Access Token via an environment variable rely on `cat` and `sed` which are typically available on macOS and Linux. They can be obtained for Windows as well, for example, by using [Git for Windows](https://gitforwindows.org/).
It is also possible to put the token directly into the configuration file, but do it at your own risk and make sure that it cannot be read by other users.

### Clone this repository
Clone the repository using:
```sh
git clone git@github.com:scribe-public/gitgat.git 
```
And then enter into the directory created:
```sh
cd gitgat
```


### Configure the input.json configuration file
The configuration file for the examples below is expected to be `input.json`. Make sure you create this file in the main gitgat folder, using the following script:

```sh
cp data/empty-input.json input.json  
```
Samples of configuration files can be found in here: <https://github.com/scribe-public/gitgat/blob/master/data/>.

If you wish to add information or state to your `input.json` file, you can refer to `data/sample_input.json`, for policies configuration and state management. Each rule set is its own JSON section, and the state information for each rule fits inside that segment. Make sure that the state information does not get pushed to the repository, as it might contain sensitive data.

`sample_input.json` is **not** included in .gitignore, but `input.json` is.
So it is recommended to use `input.json` as the input configuration file for OPA.


### Run the policies using OPA

When running eval and report commands, pipe the token variable via stdin and sed. 
Following are a few examples of uses.

Create a report as a report as a gist in your GitHub account:


```sh
cat input.json | sed "s/GH_TOKEN/$GH_TOKEN/" | opa eval -I -b github data.gh.post_gist
```

Get a report as a md file:
```sh
cat input.json | sed "s/GH_TOKEN/$GH_TOKEN/" | opa eval -I -b github data.github.report.print_report 2> report.md
```

Get a report as a JSON object:

```sh
cat input.json | sed "s/GH_TOKEN/$GH_TOKEN/" | opa eval -I -b github data.gh.eval
```

Run a specific module/rule:

```sh
cat input.json | sed "s/GH_TOKEN/$GH_TOKEN/" | opa eval -I -b github data.github.<module>.eval
```
For example:
```sh
cat input.json | sed "s/GH_TOKEN/$GH_TOKEN/" | opa eval -I -b github data.github.ssh_keys.eval
```
You can find the different rule files under `data/github`. Each file is a single OPA rule. The file name is the rule name, and that's the name you can use instead of the `<module>`.

(Under development) Print the Markdown report to stdout:

```sh
cat input.json | sed "s/GH_TOKEN/$GH_TOKEN/" | opa eval -I -b github data.github.report.print_report

```

(Under development) Upload the report to GitHub as a Gist:

```sh
cat input.json | sed "s/GH_TOKEN/$GH_TOKEN/" | opa eval -I -b github data.gh.post_gist
```


## Rule sets
The evaluation can be run for three different rule sets.
The rule set is configured via `input.rule_set`:

  * "user" - evaluates rules from a single user perspective.
  * "org" - evaluates rules from an organization perspective.
    The organizations that are evaluated are configured in the `input.json` file under the  `organizations` header.
  * "enterprise" - evaluates rules for an enterprise (coming soon).

The default selection is "user" as can be seen in the example `input.json` file above.
# State configuration
Policies are configured via relevant state objects in `input.json`.
Each configurable module has a corresponding input configuration object.
Configuration parameters are described in each module's section below.
The state can be updated and approved by the policy administrator.
Eval rules print out violations of policies.
The violated rules can be used to configure exceptions allowed by the SCM administrator for the modules by updating the state of the modules.
Additional information about modules is available in corresponding eval rules descriptions.

# Authentication modules

## 2 factor authentication
  2 factor authentication protects against developers account password leakage. It is **highly recommended** to request users to enable 2 factor authentication.
  Module *tfa* checks for organization members with 2 factor authentication disabled.

  Required permissions:
   * read:org - note, that only organization owners can get the list of users with 2 factor authentication disabled
   * read:user - to get the list of organizations the user belongs to (when evaluating the *user* rule set)

  Configuration parameters:

   * `input.tfa.disabled_members` - specifies the list of users that are allowed to have 2 factor authentication disabled
   * `input.tfa.unenforced_orgs` - specifies the list of organizations that are allowed to have 2 factor authentication enforcements disabled

  Rule modules:

   * `data.github.tfa.eval.state.disabled_members` returns the list of users in each organization that have the 2 factor authentication disabled.
     If the new state is approved, they should be added to the configuration state.

   * `data.github.tfa.eval.state.unenforced_orgs` returns the list of organizations that do not enforce 2 factor authentication.


## SSH keys
  Developers can use SSH keys to access the repositories. A leaked SSH key gives an attacker access to the repository without the need to acquire a password. To mitigate the risk, it is advised to rotate SSH keys periodically and review configured SSH keys. The module is supported in the user rule set as organization owners do not have access to SSH keys metadata.
  Module *ssh_keys* checks for expired and newly added SSH keys.

  Required permissions:

   * read:public_key - to get the list of user's SSH public keys

  Configuration parameters:
   * `input.ssh_keys.expiration` - [years, months, days] for the SSH keys expiration
   * `input.ssh_keys.keys` - list of SSH keys that are registered for the user

  Rule modules:

   * `data.github.ssh_keys.eval.state.expired` returns the list of SSH keys that are older than configured by the expiration parameter.
   * `data.github.ssh_keys.eval.state.keys` returns the list of SSH keys that were not previously added to the input configuration file.
     All the approved keys should be added to the configuration state.

## Deploy keys
  Deploy keys are SSH keys that give access to a specific repository (as opposed to the user's SSH keys that give access to all user's repositories). The same recommendations apply to deploy keys.
  Module *deploy_keys* checks for expired and newly added deploy keys.

  Required permissions:

   * repo - to get the list of deploy keys

  Configuration parameters:
   * `input.deploy_keys.expiration` - [years, months, days] for the deploy keys expiration
   * `input.deploy_keys.keys` - list of deploy keys that are registered for the repository

  Rule modules:

   * `data.github.deploy_keys.eval.state.expired` returns the list of deploy keys that are older than configured by the expiration parameter.
   * `data.github.deploy_keys.eval.state.keys` returns the list of deploy keys that were not previously registered for organization repositories. All the approved new keys should be added to the configuration state.

## Commits
  Commit signatures can serve as an additional protection mechanism against compromised developer's accounts. Even when the password or an SSH key is leaked, the commit signing key will not necessarily be leaked and requiring signatures would prevent an attacker from authoring commits on behalf of a compromised developer's account. See branches section for documentation on enabling signatures enforcement per branch.
  Module *commits* checks for commit signatures in specified repositories and for the history of commits to detect anomalies.

  Required permissions:

   * repo - to get the list of commits

  Configuration parameters:

   * `input.commits.<repo>.allow_unverified` - list of user accounts per repository that are allowed to commit without signing
   * `input.commits.<repo>.history` - list of the last 30 commits in the repository

  Rule modules:

   * `data.github.commits.eval.state.unverified` returns the list of commits that are either not signed or for which the signature verification failed.
     It does not include the commits by authors listed in `allow_unverified`. To approve the new state, the authors of unverified commits should be added to the configuration state.
   * `data.github.commits.eval.state.history` returns the list of commits in the repository that are not included in the input configuration state.

# Permission modules

## Admins
  Organization administrators have full control over the organization configuration and its repositories. The list of administrator users should be kept up-to-date.
  Module *admins* monitor the list of admin users.

  Required permissions:

   * read:org - to get the list of admins in the organization

  Configuration parameters:

   * `input.admins.members` - current set of admin users

  Rule module:

   * `data.github.admins.eval.state.members` returns the list of admin users in each organization that were not included in the input list of admin users.
     If the new state is approved, they should be added to the configuration state.

## Branches
  Branch protection is a set of configuration options to authorize commits that can be pushed to a branch. For more information, refer to SCM documentation.
  Module *branches* monitor the branch protection configuration for a repository.

  Required permissions:

   * repo - to get the branch protection configuration in repositories

  Configuration parameters:

   * `input.branches.unprotected` - branches for which the branch protection is turned off
   * `input.branches.protection_data` - current configuration of branch protection

  Rule modules:

   * `data.github.branches.eval.state.unprotected` returns the list of unprotected branches not included in the input configuration.
   * `data.github.branches.eval.state.protection_data` returns the protection configuration that is different from the input protection data.
     If the new branch protection configuration is approved, the unprotected branches and the protection configuration should be added to the input.

## Teams
  Teams configuration is a convenient mechanism to organize users into groups and set permissions on a per team basis.
  Module *teams* monitor the teams members and the permissions of teams in repositories.

  Required permissions:

   * read:org - to get the list of teams in an organization
   * repo - to get the information about repositories

  Configuration parameters:

   * `input.teams.permissions` - current permissions of teams in repositories
   * `input.teams.members` - current teams members

  Rule modules:

   * `data.github.teams.eval.state.changed_permissions` returns the *newly added* permissions of teams in repositories.
   * `data.github.teams.eval.state.permissions` returns the permissions of teams in repositories for which no previous state was configured.
   * `data.github.teams.eval.state.members` returns the lists of team members that are not included in the input data.
     If the new state is approved, the teams permissions state should be updated.

## Files
  Sometimes it is necessary to configure more fine-grained permissions for the files in the repository. For example, access to CI/CD configuration files should be limited to DevOps developers. While teams module checks for the current settings, the repository history can be monitored for suspicious activity.
  Module *files* monitors modifications of individual files in the repository.

  Required permissions:

   * read:repo - to get the repository commits

  Configuration parameters:

   * `input.files.permissions` - permissions to modify individual files.
     Committers from the list per file are allowed to push commits that modify the file.

  Rule modules:

   * `data.github.admins.eval.state.violating_commits` returns the list of commits that violate the
     restrictions from the state. Updating the state requires adding the committers of the
     violating commits to the allowed list.

# Isolation modules

## Hooks
  Web hooks notify external parties about events in the repository. This can potentially leak sensitive information.
  Module *hooks* monitors the list of configured Web hooks.

  Required permissions:

   * read:repo_hook - to get the list of Web hooks in repositories

  Configuration parameters:

   * `input.hooks` - the list of configured Web hooks

  Rule module:

   * `data.github.hooks.eval.state.hooks` returns the list of new/changed Web hooks.
     If the new state is approved, they should be added to the configuration state.

# Contribute

Information describing how to contribute can be found **[here](https://github.com/scribe-public/gitgat/blob/master/CONTRIBUTING.md)**.
