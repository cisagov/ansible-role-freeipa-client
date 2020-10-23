# ansible-role-freeipa-client #

[![GitHub Build Status](https://github.com/cisagov/ansible-role-freeipa-client/workflows/build/badge.svg)](https://github.com/cisagov/ansible-role-freeipa-client/actions)
[![Total alerts](https://img.shields.io/lgtm/alerts/g/cisagov/ansible-role-freeipa-client.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/cisagov/ansible-role-freeipa-client/alerts/)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/cisagov/ansible-role-freeipa-client.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/cisagov/ansible-role-freeipa-client/context:python)

This is an Ansible role for installing the prerequisites for a
[FreeIPA](https://www.freeipa.org) client.

Users of this role are responsible for pushing the freeipa credentials
to the server via cloud-init.  See the
[`freeipa-creds.tpl.yml`](files/freeipa-creds.tpl.yml)
file for an example of how to do this.

## Requirements ##

None.

## Role Variables ##

None.

## Dependencies ##

None.

## Example Playbook ##

Here's how to use it in a playbook:

```yaml
- hosts: freeipa_clients
  become: yes
  become_method: sudo
  roles:
    - freeipa_client
```

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.

## Author Information ##

Shane Frasier - <jeremy.frasier@trio.dhs.gov>
