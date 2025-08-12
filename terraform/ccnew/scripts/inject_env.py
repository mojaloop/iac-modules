import yaml
import os
import sys

def inject_env_vars(file_path):
    with open(file_path, 'r') as f:
        data = yaml.safe_load(f) or {}

    for key, value in os.environ.items():
        if key.startswith('CC_VAR_'):
            actual_key = key[len('CC_VAR_'):]
            if actual_key in data:
                data[actual_key] = value

    with open(file_path, 'w') as f:
        yaml.dump(data, f, indent=4, default_flow_style=False)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python inject_env.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    inject_env_vars(file_path)
