# GitHub Security Posture report
SCM security is important because it gives an entry point to the whole CI/CD pipeline. The report focuses on the GitHub organization security.

# Organizations
We identified the following organizations and repositories this account belongs to. 

  * test-org:
    * owner/repo-1 (public)
    * owner/repo-2 (private)

Make sure that public repositories are the ones that are intended to be public.

## Members
Review the organizations members to make sure there are no *stale or misconfigured* accounts:

  * test-org:
    * test-admin-1
    * test-user-1
    * test-user-2

Administrators have full control of the organization so it is important to review the list of admin users:

  * test-org:
    * test-admin-1

## 2 factor authentication
There are several ways to get access to the organization's assets. The first and the most obvious one is through an account of the organization's member. Hence securing developers accounts is of high priority. A compromised user's password gives an attacker full access to the account. A second factor protects against password leakage. Below find the list of organization members with no two factor authentication configured. It is **highly recommended** to request the users to enable 2 factor authentication.

  * test-org:
    * test-user-1

## SSH keys
Developers use SSH keys to access the repositories without using passwords. In general SSH keys are more secure way to connect to remote servers (developer machine is a client, GitHub is a server). However protecting and rotating private SSH keys is necessary so that potentially leaked keys are revoked. The list of SSH keys associated with the user account:

  * ssh-rsa public key
    * created at: timestamp

Setup an expiry date to get a list of **expired** SSH keys.

## Teams
Teams group organization's members to have a fine control over configuring permissions for the members. There are the following teams configured for the organizations:

  * test-org:
    * team-1
	  * test-user-1
	* team-2
	  * test-admin-1
	
Teams permissions for each repository are the following. Especially review the teams that have **admin** permissions in the repository:

  * test-org:
    * owner/repo-1:
	  * team-1:
	    * admin
		* triage

# Repositories

## Signed commits
Review the commits for each repository. Signed commits is an additional protection mechanism. Here are the list of commits for which the signature verification failed or the signature is missing:
  
  * test-org:
    * owner/repo-1:
	  * commit sha256 created_at timestamp by committer login

## Individual files
It is often necessary to restrict modyfing certain files, like CI/CD configuration files.

  * test-org:
    * owner/repo-1:
	  * commit:
	    * file modified by committer not in allowed list

## Hooks
Web hooks trigger HTTP POST request towards configured endpoints on certain configured events. Make sure that all hooks are up-to-date:

  * test-org:
    * owner/repo:
	  * web-hook:
	    * name: web-hook-1
	    * created_at: timestamp
        * updated_at: timestamp
		* events: list of configured events
		* URL: example.com

## Deploy keys
Deploy keys are SSH keys that give access to the repository. Review the list of deploy keys.

  * test-org:
    *owner/repo:
      * ssh-rsa public key
        * created at: timestamp

## Secrets

## Dependabot
