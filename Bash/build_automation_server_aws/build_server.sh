#!/bin/bash
#---------------------------------------------------------------------------------------------------------------
# Mikael Sikora, 2020-02-10
#---------------------------------------------------------------------------------------------------------------
# syntax:  ./build_server.sh <ENV_NAME> <STACK_TEMPLATE> <SERVER_CONF>
# Example: ./build_server.sh nonprod stack_template.yml automation_server.conf
#---------------------------------------------------------------------------------------------------------------
# Set variables
# -------------
# $CI_JOB_ID:     Gitlab CI Job ID
# LAST_NAME:      Last name of the GitLab user name
# ENV_NAME:       Environment name
# STACK_TEMPLATE: stack_template.yml
# SERVER_CONF:    automation_server.conf
#---------------------------------------------------------------------------------------------------------------
STACK_NAME=$CI_JOB_ID
LAST_NAME=`echo $GITLAB_USER_NAME|awk -F"," '{print $1}'`
ENV_NAME="${1}"
STACK_TEMPLATE="${2}"
SERVER_CONF="${3}"
#---------------------------------------------------------------------------------------------------------------
# Replace variables in stack_template.yml with values from automation_server.conf file
#---------------------------------------------------------------------------------------------------------------
sed -i.bak 's/%ENVIRONMENT_NAME%/'$ENV_NAME'/g' $STACK_TEMPLATE && rm $STACK_TEMPLATE.bak
for a in `cat $SERVER_CONF`;do
    var1=`echo ${a}|awk -F: '{print $1}'`
    var2=`echo ${a}|awk -F: '{print $2}'`
    sed -i.bak 's/%'${var1}'%/'${var2}'/g' $STACK_TEMPLATE && rm $STACK_TEMPLATE.bak
done
#---------------------------------------------------------------------------------------------------------------
# Issue aws create stack command
#---------------------------------------------------------------------------------------------------------------
aws cloudformation create-stack --stack-name gitlab-linux-automation-$STACK_NAME-$LAST_NAME --template-body file://$STACK_TEMPLATE --region us-west-2 --parameters ParameterKey=EnvironmentType,ParameterValue=$ENV_NAME
#---------------------------------------------------------------------------------------------------------------
# Do an until loop (exit after 25 tries), looking for Stack Build Status if CREATE_IN_PROGRESS, keep looping
# until CREATE_COMPLETE, and export the ExitCode for system to pickup for tracking.
#---------------------------------------------------------------------------------------------------------------
echo -en "Running"
counter=0
until [ ${counter} -eq "25" ] ; do
   StackStatus=`aws cloudformation describe-stacks --stack-name gitlab-linux-automation-$STACK_NAME-$LAST_NAME --region us-west-2|awk -F":" '/"StackStatus"/ {print $2}'|tr -d '", '`
   if [ "${StackStatus}" != "CREATE_COMPLETE" ];then echo -en "."
      elif [ "${StackStatus}" != "CREATE_IN_PROGRESS" ];then echo -e "Done";export ENVIRONMENT_NAME ExitCode="$?";break
   fi
   sleep 5 ;counter=`expr ${counter} + 1`
done
#---------------------------------------------------------------------------------------------------------------
# Test ExitCode, for system to pickup for tracking
#---------------------------------------------------------------------------------------------------------------
if [ ${ExitCode} -eq 0 ];then export ENV_NAME;exit 0
   elif [ ${ExitCode} -ne 0 ];then exit 1
fi
