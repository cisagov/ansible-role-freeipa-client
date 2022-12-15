# ansible-role-freeipa-client #

[![GitHub Build Status](https://github.com/cisagov/ansible-role-freeipa-client/workflows/build/badge.svg)](https://github.com/cisagov/ansible-role-freeipa-client/actions)
[![CodeQL](https://github.com/cisagov/ansible-role-freeipa-client/workflows/CodeQL/badge.svg)](https://github.com/cisagov/ansible-role-freeipa-client/actions/workflows/codeql-analysis.yml)

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

<!--
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| optional_variable | Describe its purpose. | `default_value` | No |
| required_variable | Describe its purpose. | n/a | Yes |
-->

## Dependencies ##

- [cisagov/ansible-role-backports](https://github.com/cisagov/ansible-role-backports):
  On Debian Bullseye the `freeipa-client` package is only available
  from the backports package repo.

## Example Playbook ##

Here's how to use it in a playbook:

```yaml
- hosts: freeipa_clients
  become: yes
  become_method: sudo
  tasks:
    - name: Install FreeIPA client
      ansible.builtin.include_role:
        name: freeipa_client
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
