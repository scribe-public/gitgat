# Initial Access

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Supply Chain Compromise on CI/CD
   </td>
   <td>Supply Chain Attacks to Application Library,<br>Tools, Container Images in CI/CD Pipelines.
   </td>
   <td>
<ol>

<li>(CI, CD) Limit egress connection via Proxy or IP Restriction

<li>(CI, CD) Audit Logging of the activities

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR

<li>(CI, CD) Check each tool’s Integrity

<li>(CI, CD) Doesn’t allow untrusted libraries, tools
</li>
</ol>
   </td>
   <td>
   NA to GitHub repository
   </td>
   <td>
   Suppy Chain Compromise on CI/CD is out of scope of repository security
   </td>
  </tr>
  <tr>
   <td>Valid Account of Git Repository
<p>
(Personal Token, SSH key, Login password, Browser Cookie)
   </td>
   <td>Use developer’s credentials to access to Git Repository Service<br>
(Personal token, SSH key, browser cookie, or login password is stolen)
   </td>
   <td>
<ol>

<li>(Device) Device security is out of scope

<li>(Git Repository) Network Restriction

<li><b>(Git Repository) Limit access permission of each developer<br>(e.g. no write permission, limited read permission) </b>

<li>(CI, CD) Use GitHub App and enable IP restriction
</li>
</ol>
   </td>
   <td>
   <b>2 factor authentication should be on</b> (on user/org/enterprise accounts, read:org and should be org admin to use the 2fa filter).<br>
   <b>Permissions of developers should be minimal</b> (teams rule needs repo and read:org authorizations, user account with org admin can get the list of admins in the org).<br>
   <b>SSH keys should be rotated </b>(user account only, read:public_key authorization).<br>
   <b>Audit log analysis (Coming soon) </b>(only enterprise account over API).
   </td>
   <td>
   Access tokens usage cannot be tracked.<br>
   In regular organization accounts, only limited info about users is available to the admin.
   </td>
  </tr>
  <tr>
   <td>Valid Account of CI/CD Service
<p>
(Personal Token, Login password, Browser Cookie)
   </td>
   <td>Use SSH key or Tokens to access to CI/CD Service Servers directly
   </td>
   <td>
<ol>

<li>(CI, CD) Strict access control to CI/CD pipeline servers

<li>(CI, CD) Hardening CI/CD pipeline servers
</li>
<li> <b> (New) (Git Repository) Prevent CI\CD credential leakage from source control </b>
</li>
</ol>
   </td>
   <td>
   <b>Secret scanning (secrets towards CI/CD Service) <br> Coming soon</b>
   </td>
   <td>
   Mostly not related to repository security.<br> If GitHub Actions are used as CI/CD then above access controls can be applied.
   </td>
  </tr>
  <tr>
   <td>Valid Admin account of Server hosting Git Repository
   </td>
   <td>Use SSH key, Tokens to access to Server hosting Git Repository
   </td>
   <td>
<ol>

<li>(Git Repository) Strict access control to server hosting Git Repository

<li>(Git Repository) Hardening git repository servers
</li>
</ol>
   </td>
   <td>
   Not applicable to GitHub
   </td>
   <td>
   If GitHub is compromised we are out of luck
   </td>
  </tr>
</table>


# Execution

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Modify CI/CD Configuration
   </td>
   <td>Modify CI/CD Configuration on Git Repository
<p>
(CircleCI: .circleci/config.yml, CodeBuild: buildspec.yml, CloudBuild: cloudbuild.yaml, GitHub Actions: .github/workflows/*.yaml)
   </td>
   <td>
<ol>

<li><b>(Git Repository) Only allow pushing of signed commits</b>

<li><b>(CI, CD) Disallow CI/CD config modification without review (CI/CD must not follow changes of a branch without review)</b>

<li>(CI, CD) Add signature to CI/CD config and verify it

<li><b>(New) (Git Repository) Limit editing permissions to CI/CD configurations</b>

<li>(CI, CD) Limit egress connections via Proxy and IP restrictions

<li>(CI, CD) Audit Logging of activities

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR
</li>
</ol>
   </td>
   <td>
   <b>Signed commits</b> (any account with repo authorization).<br>
   <b>Requiring review</b> (Coming soon - not implemented yet branch protection rule).<br>
   <b>Files rule limits who can edit CI/CD config files</b> (any account with repo authorization, requires addition of standard regular expressions for CI/CD files).<br>
   </td>
   <td>
   Files and commits are reactive rules, they check
   the history of the repository. <b>Note: all our rules are reactive</b>
   </td>
  </tr>
  <tr>
   <td>Inject code to IaC configuration
   </td>
   <td>For example, Terraform allows code execution and file inclusion. The code is executed during CI(plan stage)
<p>
Code Execution: Provider installation(put provider binary with .tf), Use External provider <br>
File inclusion: file Function
   </td>
   <td>
<ol>

<li><b>(Git Repository) Only allow pushing of signed commits</b>

<li><b>(New) (Git Repository) Limit editing permissions to CI/CD configurations</b>

<li><b>(New) (Git Repository) Disallow CI/CD config modification without review <i>(CI/CD must not follow changes of a branch without review)<i></b>

<li>(CI, CD) Restrict dangerous code through Policy as Code

<li>(CI, CD) Restrict untrusted providers

<li>(CI, CD) Limit egress connections via Proxy and IP restrictions

<li>(CI, CD) Audit Logging of activities

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR
</li>
</ol>
   </td>
   <td>
   <b>Signed commits.</b><br>
   <b>Files rule to limit who can edit config.</b><br>
   <b>Requiring review.</b>
   </td>
   <td>
   Our rules are reactive - code can be executed already by the time commits and files check are done.
   </td>
  </tr>
  <tr>
   <td>Inject code to source code
   </td>
   <td>Application executes test code during CI
   </td>
   <td>
<ol>

<li><b>(New) (Git Repository) Limit editing permissions to source files</b>

<li><b>(New) (Git Repository) Disallow CI/CD config modification without review</b>

<li>(CI, CD) Restrict dangerous code through Policy as Code

<li>(CI, CD) Limit egress connections via Proxy and IP restrictions

<li>(CI, CD) Audit Logging of the activities

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR
</li>
</ol>
   </td>
   <td>
   <b>Requiring reviews.</b><br>(Coming soon)
   </td>
   <td>
   Can anything else be done here from repository perspective?
   Permissions do let developers to modify source code.
   Files will not cover all of the source code files.
   </td>
  </tr>
  <tr>
   <td>Supply Chain Compromise on CI/CD
   </td>
   <td>(Repeated)
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>Inject bad dependency
   </td>
   <td>Inject bad dependency
   </td>
   <td>
<ol>
<li><b>(New) (Git Repository) Limit editing permissions to source files</b>
<li>(CI, CD) Code checks by SCA(Software composition analysis)

<li>(CI, CD) Restrict untrusted libraries, and tools

<li>(CI, CD) Limit egress connections via Proxy and IP restrictions

<li>(CI, CD) Audit Logging of activities

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR
</li>
</ol>
   </td>
   <td>
   <b>Files rule</b> to make sure only limited number of developers can modify
   project configuration that specifies dependencies. For example, package.json
   specifies dependencies for NodeJS app, so make sure only trusted developers
   can modify it.<br>
   <b>Dependency rule (TBD Coming soon: based on dependabot data)</b>
   </td>
   <td>
   The dependency can be injected with the version that is configured in the repo already.
   For example, if an attacker can see package.json file, he does not need to modify it directly but provide a version of the dependency in the upstream that will be pulled by CI/CD (dependency confusion attack). <b>True, but I think it is more complicated to generate an such a dependency (would it be a new version? how would it be pushed to npm\pypi?)
   </td>
  </tr>
  <tr>
   <td>SSH to CI/CD pipelines
   </td>
   <td>Connect to CI/CD pipeline servers via SSH or Valid Token
   </td>
   <td>
<ol>

<li>(CI, CD) Implement strict access control to CI/CD pipeline servers

<li>(CI, CD) Disallow SSH access
</li>
</ol>
   </td>
   <td>
   Not applicable to GitHub repository security
   </td>
   <td>
   CI/CD pipeline access is ouf of scope
   </td>
  </tr>
</table>

# Execution (Production)


<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Modify the configuration of Production environment
   </td>
   <td>Modify the configuration of Production environment via stolen credentials
   </td>
   <td>
<ol>
<li><b>(New) (Git Repository) Limit editing permissions to source files (Reconsider if this is the right place)</b>
<li>(Secret Manager) Rotate credentials regularly or issue temporary tokens only

<li>(Production environment) Network Restriction to Cloud API

<li>(Production environment) Enable Audit Logging

<li>(Production environment) Security Monitoring of data access

<li>(Production environment) Enforce principle of least privilege to issued credentials

<li>(Production environment) Rate limiting
</li>
</ol>
   </td>
   <td>
   <b> See above: modify CI/CD configuration:
   If configuration of Production environment is stored in the repository,
   files and commits rule can help preventing its modification.
   Limit effect of  stolen credentials by enforcing 2fa</b>
   </td>
   <td>
   Mostly out of scope of repository security though.
   </td>
  </tr>
  <tr>
   <td>Deploy modified applications or server images to production environment
   </td>
   <td>Deploy modified applications or server images (e.g. container image, function, VM image) to production environment via stolen credentials
   </td>
   <td>
<ol>

<li>(Secret Manager) Rotate credentials regularly or issue temporary tokens only

<li><b>(Git Repository) Require multi-party approval(peer review)</b>

<li>(Production environment) Verify signature of artifacts

<li>(Production environment) Network Restriction to Cloud API

<li>(Production environment) Enable Audit Logging

<li>(Production environment) Security Monitoring of deployment

<li>(Production environment) Enforce principle of least privilege to issued credentials

<li>(Production environment) Rate limiting
</li>
</ol>
   </td>
   <td>
   <b>Requiring review. (Coming soon)</b> <br> <b>File Rule: Who uploads and when.</b> <br>
   </td>
   <td>
   Not implemented. Check what GitHub is doing about artifacts.
   </td>
  </tr>
</table>


# Persistence

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Compromise CI/CD Server
   </td>
   <td>Compromise CI/CD Server from pipeline
   </td>
   <td>
<ol>

<li>(CI, CD) Clean environment created on every pipeline run
</li>
</ol>
   </td>
   <td>
   Out of scope of repository security.
   </td>
   <td>
   Out of scope.<br>
   <i>CI/CD Server configuration is not stored in the repo.</i>
   </td>
  </tr>
  <tr>
   <td>Implant CI/CD runner images
   </td>
   <td>Implant container images for CI/CD with malicious code to establish persistence
   </td>
   <td>
<ol>

<li>Use signed/trusted CI runners only

<li>Implement strict access controls to container registry

<li>(CI, CD) Audit Logging of activities
</li>
</ol>
   </td>
   <td>
   Out of scope<br>
   </td>
   <td>
   Out of scope<br>
   <i>Images are out of scope of repository security.</i>
   </td>
  </tr>
  <tr>
   <td>(Modify CI/CD Configuration)
   </td>
   <td>(Repeated)
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>(Inject code to IaC configuration)
   </td>
   <td>(Repeated)
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>(Inject code to source code)
   </td>
   <td>(Repeated)
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>(Inject bad dependency)
   </td>
   <td>(Repeated)
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
</table>


# Privilege Escalation

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Get credential for Deployment(CD) on CI stage
   </td>
   <td>Get high privilege credential in CI stage (not CD)
   </td>
   <td>
<ol>
<li> <b> (New) (Git Repository) Prevent CI\CD credential leakage from source control </b>

<li>(CI, CD) Limit the scope of credentials in each step.

<li>(CI) Always enforce Least Privilege. CI(not CD) must not have credentials for deployment

<li>(CI, CD) Use different Identities between CI and CD

<li>(CI, CD) Maintain strong isolation between CI and CD
</li>
</ol>
   </td>
   <td>
   <b>Repository secret scanning.</b>(Coming soon)
   </td>
   <td>
   Mostly Out of scope.<br> CD must be separated from CI, but except secret scanning impossible to check from repository security perspective if it is.
   </td>
  </tr>
  <tr>
   <td>Privileged Escalation and compromise other CI/CD pipeline
   </td>
   <td>Privilege Escalation from CI/CD Environment to other components
   </td>
   <td>
<ol>

<li>(CI, CD) Hardening of CI/CD pipeline servers

<li>(CI, CD) Isolate CI/CD pipeline from other systems.
</li>
</ol>
   </td>
   <td>
   Out of scope.
   </td>
   <td>
   </td>
  </tr>
</table>


# Defense Evasion

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Add Approver using Admin permission
   </td>
   <td>Change Approver using Git Repository Service Admin permission
   </td>
   <td>
<ol>

<li><b>(Git Repository) Limit admin users</b>

<li><b>(Git Repository) Require multi-party approval(peer review)</b>
</li>
</ol>
   </td>
   <td>
   <b>Admins and teams rules to limit admin users and permissions.</b><br>
   <b>Review rule (branch protection, coming soon)</b>
   </td>
   <td>
   <b> Our rules are reactive: An attacker with admin priviledges can add reviewers, make changes and return the original settings. But we will be able to catch this through the GitHub app given there are events triggered.</b>
   </td>
  </tr>
  <tr>
   <td>Bypass Review
   </td>
   <td>Bypass Peer Review of Git Repository
   </td>
   <td>
<ol>

<li><b>(Git Repository) Restrict repository admin from pushing to main branch without a review</b>

<li>(CD) Require additional approval from reviewer to kick CD
</li>
</ol>
   </td>
   <td>
   <b>Branch protection.</b><br>
   <b>Requiring review.<br> (Both coming soon)</b>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>Access to Secret Manager from CI/CD kicked by different repository
   </td>
   <td>Use a CI/CD system in a different repository to leverage stolen credentials to access secret manager
   </td>
   <td>
<ol>

<li>(Secret Manager) Restrict and separate access from different workloads
</li>
</ol>
   </td>
   <td>
   Out of scope of repository security
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>Modify Caches of CI/CD
   </td>
   <td>Implant bad code to caches of CI/CD pipeline
   </td>
   <td>
<ol>

<li>(CI, CD) Clean environment on every pipeline run
</li>
</ol>
   </td>
   <td>
   Out of scope of repository security
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>Implant CI/CD runner images
   </td>
   <td>(Repeated)
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
</table>


# Credential Access

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Dumping Env Variables in CI/CD
   </td>
   <td>Dump Environment Variables in CI/CD
   </td>
   <td>
<ol>

<li>(CI, CD) Don’t use environment variables for storing credentials

<li>(Secret Manager) Use secret manager which has network restriction

<li>(Secret Manager) Enable Audit Logging

<li>(Secret Manager) Security Monitoring to detect malicious activity

<li>(Secret Manager) Rotate credentials regularly or issue temporary tokens only

<li>(CI, CD) Enable Audit Logging

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR
</li>
</ol>
   </td>
   <td>
   <b>I think all of this is out of scope.</b>
   Secret scanning for credentials.
   </td>
   <td>
   Mostly out of scope.
   </td>
  </tr>
  <tr>
   <td>Access to Cloud Metadata
   </td>
   <td>Access to Cloud Metadata to get access token of Cloud resources
   </td>
   <td>
<ol>

<li>(CI, CD) Restrict metadata access from suspicious processes

<li>(Secret Manager) Use secret manager which has network restriction

<li>(Secret Manager) Enable Audit Logging

<li>(Secret Manager) Security Monitoring to detect malicious activity

<li>(Secret Manager) Rotate credentials regularly or issue temporary tokens only

<li>(CI, CD) Enable Audit Logging

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR
</li>
</ol>
   </td>
   <td>
   <b>I think all of this is out of scope.</b><br>
   Secret scanning.
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>Read credentials file
   </td>
   <td>Read credentials file mounted in CI/CD pipeline
   </td>
   <td>
<ol>

<li>(CI, CD) Disable or mask contents of files in results of CI/CD

<li>(Secret Manager) Use secret manager which has network restriction

<li>(Secret Manager) Enable Audit Logging

<li>(Secret Manager) Security Monitoring to detect malicious activity

<li>(Secret Manager) Rotate credentials regularly or issue temporary tokens only

<li>(CI, CD) Enable Audit Logging

<li>(CI, CD) Security Monitoring using IDS/IPS, and EDR
</li>
</ol>
   </td>
   <td>
   Out of scope of repository security
   </td>
   <td>
   Credentials mounted on CI/CD pipeline are not represented in the repository
   </td>
  </tr>
  <tr>
   <td>Get credential from CI/CD Admin Console
   </td>
   <td>See credential from CI/CD admin console
   </td>
   <td>
<ol>

<li>(CI, CD) Doesn’t use CI/CD services that expose credentials from the system console
</li>
</ol>
   </td>
   <td>
   Out of scope of repository security
   </td>
   <td>
   </td>
  </tr>
</table>


# Lateral Movement

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td> 
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
 </tr>
  <tr>
   <td>Exploitation of Remote Services
   </td>
   <td>Exploit services from CI/CD Pipeline
   </td>
   <td>
<ol>

<li>(CI, CD) Isolate CI/CD pipeline systems from other services
</li>
</ol>
   </td>
   <td>
   Potentially: secret scanning for credentials towards other services
   </td>
   <td>
   Isolation is out of scope of repository security
   </td>
  </tr>
  <tr>
   <td>(Monorepo) Get credential of different folder's context
   </td>
   <td>In monorepo architecture of Git Repository, there are many approvers.
<p>
Need to set access controls carefully
   </td>
   <td>
<ol>

<li><b>(Git Repository) Set approver for each folder</b>

<li>(CI, CD, Secret Manager) Avoid sharing CI/CD environment and credentials between different folders. 

<li>(CI, CD) should be isolated by environment folder or context
</li>
</ol>
   </td>
   <td>
   TODO Need to investigate monorepo on GitHub
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>Privileged Escalation and compromise other CI/CD pipeline
<p>
(Repeated)
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
</table>


# Exfiltration

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Exfiltrate data in Production environment
   </td>
   <td>Exfiltrate data in Production environment via stolen credentials
   </td>
   <td>
<ol>

<li>(CI/CD) Doesn’t put data access credential in CI/CD

<li>(Production environment) Network Restriction to Cloud API

<li>(Production environment) Enable Audit Logging

<li>(Production environment) Security Monitoring of data access

<li>(Production environment) Enforce principle of least privilege to issued credentials

<li>(Production environment) Rate limiting
</li>
</ol>
   </td>
   <td>
   Secret scanning <b>lets discuss: scanning can prevent sensitive data existance, not exfiltration</b>
   </td>
   <td>
   Mostly out of scope
   </td>
  </tr>
  <tr>
   <td>Clone Git Repositories
   </td>
   <td>Exfiltrate data from Git Repositories
   </td>
   <td>
<ol>

<li>(Git Repository) Network Restriction

<li><b>(Git Repository) Use temporary tokens instead of long life static tokens</b>

<li><b>(Git Repository) Limit access permission of each developer (e.g. no write permission, limited read permission)</b>

<li><b> (New) (Git Repository) Limit permission to make public/private</b>

<li>(Git Repository) Enable Audit Logging

<li>(Git Repository) Security Monitoring of data access

<li>(Git Repository) Rate limiting
</li>
</ol>
   </td>
   <td>
   <b>Permissions, hooks (can leak information about events in the repository), deploy keys.<br>
   Audit logging (coming soon)</b>
   </td>
   <td>
   Token usage cannot be tracked.
   </td>
  </tr>
</table>


# Impact

<table>
  <tr>
   <td>Techniques
   </td>
   <td>Description
   </td>
   <td>Mitigation
   </td>
   <td>GitHub Posture comments
   </td>
   <td>Remaining Threat
   </td>
  </tr>
  <tr>
   <td>Denial of Services
   </td>
   <td>Denial of Services of CI/CD pipeline
   </td>
   <td>
<ol>

<li>(CI, CD) Scalable Infrastructure
</li>
</ol>
   </td>
   <td>
   Out of scope
   </td>
   <td>
   <b>DoS cannot be mitigated via GitHub repository security monitoring</b>
   </td>
  </tr>
</table>
