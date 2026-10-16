#!/usr/bin/env python3
"""Validate deploy-env-onboard PushSecret refresh interval rendering."""

import re
import unittest
from pathlib import Path

import yaml


MANIFEST = Path(__file__).with_name("push-storage-secrets-vault.yaml")
ENV_PATTERN = re.compile(r"\$\{(?P<name>[A-Za-z_][A-Za-z0-9_]*)(?::-?(?P<default>[^}]*))?}")


def render_manifest(refresh_interval=None):
    environment = {
        "ARGOCD_ENV_env_name": "test-env",
        "ARGOCD_ENV_storage_namespace": "rook-ceph",
    }
    if refresh_interval is not None:
        environment["ARGOCD_ENV_eso_refresh_interval"] = refresh_interval

    def replace(match):
        return environment.get(match.group("name"), match.group("default") or "")

    return list(yaml.safe_load_all(ENV_PATTERN.sub(replace, MANIFEST.read_text())))


class RefreshIntervalTest(unittest.TestCase):
    def assert_all_intervals(self, expected):
        resources = render_manifest(None if expected == "15m" else expected)
        self.assertEqual(13, len(resources))
        self.assertTrue(all(resource["kind"] == "PushSecret" for resource in resources))
        self.assertEqual(
            {expected},
            {resource["spec"]["refreshInterval"] for resource in resources},
        )

    def test_omitted_value_defaults_to_15m(self):
        self.assert_all_intervals("15m")

    def test_explicit_value_is_preserved(self):
        self.assert_all_intervals("10m")


if __name__ == "__main__":
    unittest.main()
