#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# This script is called by the freeipa-enroll service.

# These variables must be set before execution.  They will
# be loaded from a file installed by cloud-init:
# /var/lib/cloud/instance/freeipa-creds.sh
# ADMIN_PW: The password for the IPA server's Kerberos admin role
# HOSTNAME: The hostname of this IPA client (e.g. client.example.com)
# REALM: The realm for the IPA server (e.g. EXAMPLE.COM)

source /var/lib/cloud/instance/freeipa-creds.sh

# Get the default Ethernet interface
function get_interface {
    ip route | grep default | sed "s/^.* dev \([^ ]*\).*$/\1/"
}

# Get the IP address corresponding to an interface
function get_ip {
    ip --family inet address show dev "$1" | \
        grep inet | \
        sed "s/^ *//" | \
        cut --delimiter=' ' --fields=2 | \
        cut --delimiter='/' --fields=1
}

# Get the PTR record corresponding to an IP
function get_ptr {
    dig +noall +ans -x "$1" | sed "s/.*PTR[[:space:]]*\(.*\)/\1/"
}

function enroll {
    # Check to see if freeipa-client is already installed
    if [[ -f "/etc/ipa/default.conf" ]]; then
        echo "FreeIPA client is already installed... rejoining."
        echo ${ADMIN_PW} | kinit admin@${REALM}
        ipa-join || true
        kdestroy
        exit 0
    fi

    interface=$(get_interface)
    ip_address=$(get_ip "$interface")

    # Wait until the IP address has a non-Amazon PTR record before
    # proceeding
    ptr=$(get_ptr "$ip_address")
    while grep amazon <<< "$ptr"
    do
        sleep 30
        ptr=$(get_ptr "$ip_address")
    done

    ipa-client-install --realm="${REALM}" \
                       --principal=admin \
                       --password="${ADMIN_PW}" \
                       --mkhomedir \
                       --hostname="${HOSTNAME}" \
                       --no-ntp \
                       --unattended \
                       --force-join
}

function unenroll {
  echo ${ADMIN_PW} | kinit admin@${REALM}
  ipa-join --unenroll
  rm /etc/krb5.keytab
  kdestroy
  exit 0
}

if [ $# -lt 1 ]
then
    echo "command required: enroll | unenroll"
    exit 255
fi

case "$1" in
    enroll)
      enroll
      ;;
    unenroll)
      unenroll
      ;;
    *)
    echo "unknown command.  Valid commands are: enroll | unenroll"
    exit 255
esac
