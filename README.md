# code-examples
This is a repositoy of code I've written and placed here as examples of my work.
## Bash
### build_sutomation_server_aws
Using GitLab tag feature, the build_server.sh passes values from automation_server.conf to stack_template.yml, then issues an AWS command utilizing the stack_template.yml as a CloudForamtion script.  Runs inside GitLab CI/CD.
### createreleaseinfo.sh
Using the Confluence and Jira CLIs, the script creates Confluece Release pages from Jira "Release Request" issues that have "Create Release Page Status" set to "Pending".
## Perl
### fizzbuzz.pl
A demonstration script to find the divizable integers of an iteration from 1 to 100.
### OddCount.pl
A demonstration script to finding the odd number of occurances of elements in an array.
## Python
### resize_instances.py
A module to change the AWS instance types of Tableau servers for a specific build pipeline.
## SQL
### CopyFolderAccessRecordsBetweenServers.sql
Copies all folderaccess (fa1) table values from remote server to current server.
### sp_CheckContentAccessControlMemberPermissions.sql
A Microsoft SQL Server stored procedure to list out all folder permissions for members.