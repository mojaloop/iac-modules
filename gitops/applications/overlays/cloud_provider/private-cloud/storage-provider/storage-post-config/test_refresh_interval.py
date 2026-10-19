#!/usr/bin/env python3
"""Validate storage-post-config ExternalSecret refresh interval rendering."""

import re
import unittest
from pathlib import Path

import yaml


MANIFEST = Path(__file__).with_name("storage-external-secrets.yaml")
REPOSITORY_ROOT = MANIFEST.parents[7]
COMMON_VARS = REPOSITORY_ROOT / "terraform/ccnew/default-config/common-vars.yaml"
ARGO_APPS_TEMPLATE = REPOSITORY_ROOT / "terraform/ccnew/ansible-k8s-deploy/templates/argoapps.yaml.tpl"
APPLICATION = REPOSITORY_ROOT / "gitops/argo-apps/base/storage-post-config.yaml"
ENV_PATTERN = re.compile(r"\$\{(?P<name>[A-Za-z_][A-Za-z0-9_]*)(?::-?(?P<default>[^}]*))?}")


def render_manifest(refresh_interval=None):
    environment = {"ARGOCD_ENV_storage_namespace": "storage"}
    if refresh_interval is not None:
        environment["ARGOCD_ENV_eso_refresh_interval"] = refresh_interval

    def replace(match):
        return environment.get(match.group("name"), match.group("default") or "")

    return list(yaml.safe_load_all(ENV_PATTERN.sub(replace, MANIFEST.read_text())))


class RefreshIntervalTest(unittest.TestCase):
    def assert_all_intervals(self, expected):
        resources = [resource for resource in render_manifest(None if expected == "15m" else expected)
                     if resource["kind"] == "ExternalSecret"]
        self.assertEqual(13, len(resources))
        self.assertEqual({expected}, {resource["spec"]["refreshInterval"] for resource in resources})

    def test_omitted_value_defaults_to_15m(self):
        self.assert_all_intervals("15m")

    def test_explicit_value_is_preserved(self):
        self.assert_all_intervals("10m")

    def test_configuration_chain_uses_the_utils_storage_namespace(self):
        common_vars = yaml.safe_load(COMMON_VARS.read_text())
        self.assertEqual("15m", common_vars["storage_eso_refresh_interval"])
        self.assertIn(
            'eso_refresh_interval: "${storage_eso_refresh_interval}"',
            ARGO_APPS_TEMPLATE.read_text(),
        )
        self.assertIn('value: "${ARGOCD_ENV_utils_storage_eso_refresh_interval}"', APPLICATION.read_text())


if __name__ == "__main__":
    unittest.main()
