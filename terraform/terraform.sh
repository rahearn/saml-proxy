#!/usr/bin/env bash

rmk_file="../config/credentials/staging.key"
cmd="plan"

usage="
$0: Run terraform commands against a given environment

Usage:
  $0 -h
  $0 -e <ENV NAME> [-k <RAILS_MASTER_KEY>] [-f] [-c <TERRAFORM-CMD>] [-- <EXTRA CMD ARGUMENTS>]

Options:
-h: show help and exit
-e ENV_NAME: The name of the environment to run terraform against
-k RAILS_MASTER_KEY: RAILS_MASTER_KEY value. Defaults to contents of $rmk_file
-f: Force, pass -auto-approve to all invocations of terraform
-c TERRAFORM-CMD: command to run. Defaults to $cmd
[<EXTRA CMD ARGUMENTS>]: arguments to pass as-is to terraform
"


rmk=`cat $rmk_file || echo -n ""`
env=""
force=""
args_to_shift=0

set -e
while getopts ":he:k:fc:" opt; do
  case "$opt" in
    e)
      env=${OPTARG}
      args_to_shift=$((args_to_shift + 2))
      ;;
    k)
      rmk=${OPTARG}
      args_to_shift=$((args_to_shift + 2))
      ;;
    f)
      force="-auto-approve"
      args_to_shift=$((args_to_shift + 1))
      ;;
    c)
      cmd=${OPTARG}
      args_to_shift=$((args_to_shift + 2))
      ;;
    h)
      echo "$usage"
      exit 0
      ;;
  esac
done

shift $args_to_shift
if [[ "$1" = "--" ]]; then
  shift 1
fi

if [ -z "$GITLAB_PROJECT_ID"] || [ -z "$GITLAB_HOSTNAME" ]; then
  echo "GITLAB_PROJECT_ID or GITLAB_HOSTNAME have not been set. Run bootstrap/setup_shadowenv.sh first"
  exit 1
fi

if [[ -z "$env" ]]; then
  echo "-e <ENV_NAME> is required"
  echo "$usage"
  exit 1
fi

if [[ ! -f "$env.tfvars" ]]; then
  echo "$env.tfvars file is missing. Create it first"
  exit 1
fi

# ensure we're logged in via cli
cf spaces &> /dev/null || cf login -a api.fr.cloud.gov --sso

tfm_needs_init=true
tf_state_address="https://$GITLAB_HOSTNAME/api/v4/projects/$GITLAB_PROJECT_ID/terraform/state/$env"
if [[ -f .terraform/terraform.tfstate ]]; then
  backend_state_address=`cat .terraform/terraform.tfstate | jq -r ".backend.config.address"`
  if [[ "$backend_state_address" = "$tf_state_address" ]]; then
    tfm_needs_init=false
  fi
fi

if [[ $tfm_needs_init = true ]]; then
  terraform init -reconfigure \
    -backend-config="address=$tf_state_address" \
    -backend-config="lock_address=$tf_state_address/lock" \
    -backend-config="unlock_address=$tf_state_address/lock"
fi

echo "=============================================================================================================="
echo "= Calling $cmd $force on the application infrastructure"
echo "=============================================================================================================="
terraform "$cmd" -var-file="$env.tfvars" -var rails_master_key="$rmk" $force "$@"
