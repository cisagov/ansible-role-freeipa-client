#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# There are several items below that look like shell variables but are
# actually replaced by the Terraform templating engine.  Hence we can
# ignore the "undefined variable" warnings from shellcheck.
#
# shellcheck disable=SC2154
sed -i "s/^ADMIN_PW=.*/ADMIN_PW=\"${admin_pw}\"/g" /usr/local/sbin/setup_freeipa.sh
# shellcheck disable=SC2154
sed -i "s/^HOSTNAME=.*/HOSTNAME=\"${hostname}\"/g" /usr/local/sbin/setup_freeipa.sh
# shellcheck disable=SC2154
sed -i "s/^REALM=.*/REALM=\"${realm}\"/g" /usr/local/sbin/setup_freeipa.sh
