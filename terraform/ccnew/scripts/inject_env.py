#!/usr/bin/env python3
"""
Environment variable injection script for YAML configuration files.

This script reads YAML files and injects values from environment variables
prefixed with 'CC_VAR_'. The ssh_private_key is handled specially to ensure
proper PEM formatting using YAML literal block style.
"""

import os
import sys
import yaml
import textwrap
from typing import Any, Dict
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__name__)


class LiteralString(str):
    """Custom string class that forces YAML literal block (|) style output."""
    pass


def literal_string_representer(dumper: yaml.Dumper, data: LiteralString) -> yaml.Node:
    """YAML representer that outputs LiteralString as literal block style."""
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")


# Register the custom representer
yaml.add_representer(LiteralString, literal_string_representer)


def normalize_private_key(raw_key: str) -> LiteralString:
    """
    Normalize a private key string for proper PEM formatting.

    Args:
        raw_key: Raw private key string that may have inconsistent indentation

    Returns:
        LiteralString: Cleaned private key with proper formatting
    """
        if not raw_key.strip():
        return LiteralString("")

    # Split into lines and remove leading whitespace from each line
    lines = raw_key.strip().split('\n')
    cleaned_lines = [line.lstrip() for line in lines]
    cleaned = '\n'.join(cleaned_lines)

    # Validate basic PEM structure
    if not (cleaned.startswith('-----BEGIN') and cleaned.endswith('-----')):
        logger.warning("Private key does not appear to be in PEM format")

    return LiteralString(cleaned)


def inject_env_vars(file_path: str) -> None:
    """
    Inject CC_VAR_ environment variables into a YAML file.

    Args:
        file_path: Path to the YAML file to modify

    Raises:
        FileNotFoundError: If the specified file doesn't exist
        yaml.YAMLError: If the file contains invalid YAML
    """
        try:
        with open(file_path, "r", encoding='utf-8') as f:
            data = yaml.safe_load(f) or {}
    except FileNotFoundError:
        logger.error(f"File not found: {file_path}")
        raise
    except yaml.YAMLError as e:
        logger.error(f"Invalid YAML in {file_path}: {e}")
        raise

    updated = False

    # Process all CC_VAR_ environment variables
    for env_key, env_val in os.environ.items():
        if not env_key.startswith("CC_VAR_"):
            continue

        yaml_key = env_key[len("CC_VAR_"):]

        # Check if this key exists in the YAML file
        if yaml_key not in data:
            continue

        # Special handling for ssh_private_key
        if yaml_key == "ssh_private_key":
            new_value = normalize_private_key(env_val)
        else:
            new_value = env_val

        # Only update if the value has changed
        if data[yaml_key] != new_value:
            data[yaml_key] = new_value
            logger.info(f"Updated {yaml_key} in {file_path}")
            updated = True

    # Return early if no changes were made
    if not updated:
        return

    # Write the updated YAML file
    try:
        with open(file_path, "w", encoding='utf-8') as f:
            yaml.dump(
                data,
                f,
                default_flow_style=False,
                sort_keys=False,
                indent=2,
                allow_unicode=True,
            )
    except IOError as e:
        logger.error(f"Failed to write {file_path}: {e}")
        raise


def main() -> None:
    """Main entry point for the script."""
    if len(sys.argv) != 2:
        print("Usage: python inject_env.py <file_path>", file=sys.stderr)
        print("", file=sys.stderr)
        print("This script injects CC_VAR_ environment variables into YAML files.", file=sys.stderr)
        print("Example: CC_VAR_ssh_private_key will update the 'ssh_private_key' key.", file=sys.stderr)
        sys.exit(1)

    file_path = sys.argv[1]

    try:
        inject_env_vars(file_path)
    except (FileNotFoundError, yaml.YAMLError, IOError) as e:
        logger.error(f"Script failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
