"""Module containing the tests for the default scenario."""

# Standard Python Libraries
import os

# Third-Party Libraries
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


def test_packages(host):
    """Test that the appropriate packages were installed."""
    distribution = host.system_info.distribution
    if distribution in ["amzn"]:
        pkgs = ["ipa-client", "sssd-tools"]
    elif distribution in ["debian", "fedora", "kali", "ubuntu"]:
        pkgs = ["freeipa-client", "sssd-tools"]
    else:
        # We don't support this distribution
        assert False, f"Unknown distribution {distribution}"
    packages = [host.package(pkg) for pkg in pkgs]
    installed = [package.is_installed for package in packages]
    assert len(pkgs) != 0
    assert all(installed)


@pytest.mark.parametrize(
    "f,mode",
    [("/usr/local/sbin/00_setup_freeipa.sh", 0o500)],
)
def test_files(host, f, mode):
    """Test that the appropriate files were installed."""
    assert host.file(f).exists
    assert host.file(f).is_file
    assert host.file(f).user == "root"
    assert host.file(f).group == "root"
    assert host.file(f).mode == mode
