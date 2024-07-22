# Automation Server
Scripts to build a Linux Automation Server via GitLab and CloudFormation
## Tagging
Tags are needed for a deployment.  Use an environment such as prod or nonprod, script, and number (to make it unique).  Use dashes between these items.
### Examples
<pre>
nonprod-build_server.sh-01
</pre>
### How to Launch Using a Tag
<pre>
1) Go to GitLab -> Repository -> Tags
2) Click on "New tag" button
   - Tag Name
       Syntax:  environment-script_name-number
       Example: nonprod-build_server.sh-01
   - Create From
       Select branch name
   - Message
       Any free text description of this run
3) Click on "Create Tag"
4) Go to GitLab -> CI/CD -> Jobs
5) Monitor job progress
</pre>
## Scripts
### build_server.sh
#### Purpose
Creates a Automation Server Linux EC2 instance from latest Amazon Linux 2 AMI.  
#### Code Workflow
<pre>
1) Build a CloudFormation template, replacing variables in stack_template.yml with  values from automation_server.conf.
2) Run CloudFormation using the template.
3) Notify via stdout when done.
</pre>
### stack_template.yml
#### Purpose
The CloudFormation template used to build a Linux server.  It has a series of variables that are replaced with values from automation_server.conf.
#### Code Workflow
<pre>
1) Metadata:  CloudFormation Designer configurations.
2) Parameters:  Argument values passed into the "aws cloudformation create-stack" command.
3) Mappings:  stack_template variables that are replaced by values from automation_server.conf.
4) Resources:  Key:values that are used by CloudFormation create_stack command.  Many reference the Mappings.
</pre>
### automation_server.conf
#### Purpose
Key:Value list used by the stack_template.yml
#### Code Workflow
<pre>
1) COMMON:  Values used by all environments
2) NONPROD:  Values specific to NONPROD
3) PROD:  Values specific to PROD
</pre>
