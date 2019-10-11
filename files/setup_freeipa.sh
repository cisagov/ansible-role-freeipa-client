#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# These variables must be set before execution.  See the
# configure_setup_freeipa.sh script for an example of how
# this is accomplished.

# The password for the IPA server's Kerberos admin role
ADMIN_PW=""
# The hostname of this IPA client (e.g. client.example.com)
HOSTNAME=""
# The realm for the IPA server (e.g. EXAMPLE.COM)
REALM=""

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
