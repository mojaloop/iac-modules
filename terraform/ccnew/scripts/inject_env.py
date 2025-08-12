import os
import sys
import yaml
import textwrap

# Only this class is emitted as a YAML literal block (|)
class LiteralString(str):
    pass

def literal_string_representer(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")

yaml.add_representer(LiteralString, literal_string_representer)

def normalize_private_key(raw: str) -> LiteralString:
    # Trim outer whitespace and remove common indentation from all lines
    cleaned = textwrap.dedent(raw.strip("\n")).strip()
    return LiteralString(cleaned)

def inject_env(file_path: str) -> None:
    with open(file_path, "r") as f:
        data = yaml.safe_load(f) or {}

    updated = False
    for env_key, env_val in os.environ.items():
        if not env_key.startswith("CC_VAR_"):
            continue
        key = env_key[len("CC_VAR_"):]
        value = normalize_private_key(env_val) if key == "ssh_private_key" else env_val
        if data.get(key) != value:
            data[key] = value
            updated = True

    if not updated:
        return

    with open(file_path, "w") as f:
        yaml.safe_dump(
            data,
            f,
            default_flow_style=False,
            sort_keys=False,
            indent=2,
        )

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python inject_env.py <file_path>")
        sys.exit(1)
    inject_env(sys.argv[1])
