import yaml
import os
import sys
from yaml.dumper import Dumper

# Custom Dumper to control indentation
class CustomDumper(Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(CustomDumper, self).increase_indent(flow, False)

def literal_string_representer(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')

yaml.add_representer(str, literal_string_representer)

def inject_env_vars(file_path):
    with open(file_path, 'r') as f:
        data = yaml.safe_load(f) or {}

    for key, value in os.environ.items():
        if key.startswith('CC_VAR_'):
            actual_key = key[len('CC_VAR_'):]
            if actual_key in data:
                if actual_key == 'ssh_private_key':
                    data[actual_key] = value.strip()
                else:
                    data[actual_key] = value

    with open(file_path, 'w') as f:
        yaml.dump(data, f, Dumper=CustomDumper, default_flow_style=False, indent=2)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python inject_env.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    inject_env_vars(file_path)
