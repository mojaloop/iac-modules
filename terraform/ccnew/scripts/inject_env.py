import yaml
import os
import sys

# Custom string class to tell PyYAML how to format our private key
class LiteralString(str):
    pass

def literal_string_representer(dumper, data):
    # Use the literal block style (|) for our multi-line string
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')

# Register the custom representer with PyYAML
yaml.add_representer(LiteralString, literal_string_representer)


def inject_env_vars(file_path):
    with open(file_path, 'r') as f:
        data = yaml.safe_load(f) or {}

    for key, value in os.environ.items():
        if key.startswith('CC_VAR_'):
            actual_key = key[len('CC_VAR_'):]
            if actual_key in data:
                # If we're processing the private key, wrap it in our custom class
                if actual_key == 'ssh_private_key':
                    data[actual_key] = LiteralString(value.strip())
                else:
                    data[actual_key] = value

    with open(file_path, 'w') as f:
        yaml.dump(data, f, indent=2, default_flow_style=False)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python inject_env.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    inject_env_vars(file_path)
