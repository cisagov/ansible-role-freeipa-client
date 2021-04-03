#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# These variables must be set before client installation:
#
# domain: The domain for the IPA client (e.g. example.com).
#
# hostname: The hostname of this IPA client (e.g. client.example.com).

# The file installed by cloud-init that contains the values for the
# above variables.
freeipa_vars_file=/var/lib/cloud/instance/freeipa-vars.sh

# Load above variable from a file installed by cloud-init:
if [[ -f "$freeipa_vars_file" ]]; then
  # Disable this warning since the file is only available at runtime
  # on the server.
  #
  # shellcheck disable=SC1090
  source "$freeipa_vars_file"
else
  echo "FreeIPA variables file does not exist: $freeipa_vars_file"
  echo "It should have been created by cloud-init at boot."
  exit 254
fi

# Add a principal alias for the instance ID so folks can ssh in via
# SSM Session Manager.  First check to make sure the alias does not
# already exist.
function add_principal {
  # Grab the instance ID from the AWS Instance Meta-Data Service
  # (IMDSv2)
  imds_token=$(curl --silent \
      --request PUT \
      --header "X-aws-ec2-metadata-token-ttl-seconds: 10" \
    http://169.254.169.254/latest/api/token)
  instance_id=$(curl --silent \
      --header "X-aws-ec2-metadata-token: $imds_token" \
    http://169.254.169.254/latest/meta-data/instance-id)
  # Verify that the instance ID is valid
  if [[ $instance_id =~ ^i-[0-9a-f]{17}$ ]]
  then
    # domain and hostname are defined in the FreeIPA variables
    # file that is sourced toward the top of this file.  Hence we
    # can ignore the "undefined variable" warning from shellcheck.
    #
    # shellcheck disable=SC2154
    if ipa host-show "$hostname" | \
      grep "Principal alias" | \
      grep --invert-match host/"$instance_id"."$domain"
    then
      ipa host-add-principal "$hostname" host/"$instance_id"."$domain"
    else
      echo Principal alias host/"$instance_id"."$domain" already \
        exists for "$hostname"
    fi
  else
    echo Invalid AWS instance ID "$instance_id" - not attempting to \
      create principal alias for instance ID
  fi
}

# Configure the host to be a FreeIPA client and join the domain.
function install {
  # hostname is defined in the FreeIPA variables file that is
  # sourced toward the top of this file.  Hence we can ignore the
  # "undefined variable" warning from shellcheck.
  #
  # shellcheck disable=SC2154
  ipa-client-install --hostname="$hostname" \
    --mkhomedir \
    --no-ntp

  add_principal
}

function enroll {
  ipa-join
  add_principal
}

function unenroll {
  ipa-join --unenroll
  # hostname is defined in the FreeIPA variables file that is
  # sourced toward the top of this file.  Hence we can ignore the
  # "undefined variable" warning from shellcheck.
  #
  # shellcheck disable=SC2154
  ipa-rmkeytab -p "host/$hostname" -k /etc/krb5.keytab
}


if [ $# -ne 0 ] && [ $# -ne 1 ]
then
  echo "Program takes zero or one arguments: $0 (enroll | unenroll)"
  exit 255
fi

case $# in
  0)
    install
    ;;
  1)
    case $1 in
      enroll)
        enroll
        ;;
      unenroll)
        unenroll
        ;;
      *)
        # It should not be possible to get here
        echo "If a single argument is provided, it must be enroll or unenroll"
        exit 255
        ;;
    esac
    ;;
esac
