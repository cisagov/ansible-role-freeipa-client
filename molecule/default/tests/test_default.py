"""Module containing the tests for the default scenario."""

import os
import pytest

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


@pytest.mark.parametrize("pkg", ["freeipa-client"])
def test_packages(host, pkg):
    """Test that the appropriate packages were installed."""
    assert host.package(pkg).is_installed


@pytest.mark.parametrize(
    "f,mode,content",
    [
        ("/usr/local/sbin/setup_freeipa.sh", 0o500, ""),
        ("/lib/systemd/system/freeipa-enroll.service", 0o644, "freeipa-enroll"),
    ],
)
def test_files(host, f, mode, content):
    """Test that the appropriate files were installed."""
    assert host.file(f).exists
    assert host.file(f).is_file
    assert host.file(f).user == "root"
    assert host.file(f).group == "root"
    assert host.file(f).mode == mode
    assert host.file(f).contains(content)


@pytest.mark.parametrize("service,isEnabled", [("freeipa-enroll", True)])
def test_services(host, service, isEnabled):
    """Test that the expected services were enabled or disabled as intended."""
    if (
        host.system_info.distribution == "debian"
        or host.system_info.distribution == "ubuntu"
    ):
        svc = host.service(service)
        assert svc.is_enabled == isEnabled
