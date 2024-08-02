mkdir -p $CONFIG_PATH
SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
for configFile in $(ls default-config/)
do
    echo $configFile
    python3 $SCRIPTS_DIR/dictmerge.py default-config/$configFile custom-config/$configFile $CONFIG_PATH;
done;