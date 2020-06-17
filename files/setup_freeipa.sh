#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# These variables must be set before client installation:
#
# domain: The domain for the IPA client (e.g. example.com).
#
# hostname: The hostname of this IPA client (e.g. client.example.com).

# The file installed by cloud-init that contains the value for the
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

# Configure the host to be a FreeIPA client and join the domain.
#
# hostname is defined in the FreeIPA variables file that is sourced
# toward the top of this file.  Hence we can ignore the "undefined
# variable" warning from shellcheck.
#
# shellcheck disable=SC2154
ipa-client-install --hostname="$hostname" \
                   --mkhomedir \
                   --no-ntp

# Add a principal alias for the instance ID so folks can ssh in via
# SSM Session Manager.
#
# domain is defined in the FreeIPA variables file that is sourced
# toward the top of this file.  Hence we can ignore the "undefined
# variable" warning from shellcheck.
#
# shellcheck disable=SC2154
ipa host-add-principal \
    "$hostname" \
    host/"$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)"."$domain"
