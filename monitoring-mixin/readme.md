# Setup up environment
```
go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
brew install jsonnet
```

# Update config
- `main.jsonnet` is the main file
- update config variables in module files e.g. mimir.libsonnet

# Build resources
```
bash build.sh
```
