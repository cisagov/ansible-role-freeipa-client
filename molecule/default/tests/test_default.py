"""Module containing the tests for the default scenario."""

# Standard Python Libraries
import os

# Third-Party Libraries
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


@pytest.mark.parametrize("pkg", ["ipa-client", "sssd-tools"])
def test_packages_amazon(host, pkg):
    """Test that the appropriate packages were installed."""
    if host.system_info.distribution == "amzn":
        assert host.package(pkg).is_installed


@pytest.mark.parametrize("pkg", ["freeipa-client", "sssd-tools"])
def test_packages_not_amazon(host, pkg):
    """Test that the appropriate packages were installed."""
    if host.system_info.distribution != "amzn":
        assert host.package(pkg).is_installed


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
