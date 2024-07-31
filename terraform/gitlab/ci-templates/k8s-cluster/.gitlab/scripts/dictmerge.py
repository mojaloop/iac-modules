import yaml
import json
import sys
import os

#def str_presenter(dumper, data):
#    """configures yaml for dumping multiline strings
#    Ref: https://stackoverflow.com/questions/8640959/how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data"""
#    if len(data.splitlines()) > 1:  # check for multiline string
#        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
#    return dumper.represent_scalar('tag:yaml.org,2002:str', data)

#yaml.add_representer(str, str_presenter)
#yaml.representer.SafeRepresenter.add_representer(str, str_presenter) # to use with safe_dum

yaml.Dumper.ignore_aliases = lambda *args : True

# Custom Dumper to handle single quoted integers
class CustomDumper(yaml.Dumper):
    def represent_data(self, data):
        if isinstance(data, str) and data.isdigit():
            return self.represent_scalar('tag:yaml.org,2002:str', data, style="'")

        return super(CustomDumper, self).represent_data(data)

def mergedicts(dict1, dict2):
    for k in set(dict1.keys()).union(dict2.keys()):
        if k in dict1 and k in dict2:
            if isinstance(dict1[k], dict) and isinstance(dict2[k], dict):
                yield (k, dict(mergedicts(dict1[k], dict2[k])))
            else:
                # Value from custom dict overrides one in default
                #print("wrong one : k = " , k, " and dict2[k] = ", dict2[k], "and dict1[k] = ", dict1[k])
                yield (k, dict2[k])
        elif k in dict1:
            yield (k, dict1[k])
        else:
            yield (k, dict2[k])

def writeDict(mergedItems, fileType, outputFilename):
    if fileType == ".json":
        with open(outputFilename, 'w') as file:
            json.dump(mergedItems, file, indent=4)
    elif fileType == ".yaml":
        with open(outputFilename, 'w') as file:
            yaml.dump(mergedItems, file, indent=4,default_flow_style=False)


def mergeListOfDicts(data1, data2, fileName, outputFilename, fileType):
    mergedItems=[]

    if len(data2) == 0:
        print("The custom-config file ",fileName, "is empty ,so using the default configuration file")
        mergedItems = data1
        writeDict(mergedItems, fileType, outputFilename)
        exit(0)

    if len(data1) != len(data2):
        print("The number of elements in custom-config and default_config differs for",fileName, ",so using the default configuration file")
        mergedItems = data1
        writeDict(mergedItems, fileType, outputFilename)
        exit(0)

    for item1, item2 in zip(data1, data2):
        mergedItems.append(dict(mergedicts(item1, item2)))
    writeDict(mergedItems, fileType, outputFilename)

if len(sys.argv) >= 4:
    default_config_file = sys.argv[1]
    custom_config_files = sys.argv[2:-1]
    outputPath = sys.argv[-1]
    fileName = os.path.basename(default_config_file).split('/')[-1]
    outputFilename = outputPath+"/"+fileName
    defaultExt = os.path.splitext(default_config_file)[1]
else:
    print("Please pass valid parameters usage : dictmerge.py defaultConfigFilePath ...customConfigFilePath outputPath")
    exit(1)

if os.path.isfile(default_config_file):
    if defaultExt == ".yaml":
        with open(default_config_file, 'r') as f:
            data1 = yaml.load(f, Loader=yaml.SafeLoader)
    elif defaultExt == ".json":
        with open(default_config_file, 'r') as f:
            data1 = json.load(f)
    else:
       print("File type not supported")
       exit(1)
else:
    print("Default config file "+default_config_file+" file does not exist")
    exit(1)

def load_custom_config(custom_config_file):
    customExt = os.path.splitext(custom_config_file)[1]
    if defaultExt != customExt:
        print("Please pass same type of files to merge")
        exit(1)
    if os.path.isfile(custom_config_file):
        if customExt == ".yaml":
            with open(custom_config_file, 'r') as f:
                return yaml.load(f, Loader=yaml.SafeLoader) or {}
        elif customExt == ".json":
            try:
                with open(custom_config_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                print("Could not parse the custom config file", custom_config_file," so assigning empty dict")
                return {}

        else:
            print("File type not supported:", custom_config_file)
            exit(1)
    else:
        print("Custom config file "+custom_config_file+" file does not exist. Assigning empty data dict")
        return {}

if fileName in ( "common-stateful-resources.json" , "mojaloop-stateful-resources.json" , "mojaloop-rbac-api-resources.yaml","vnext-stateful-resources.json" ):
    if len(sys.argv) == 4:
        mergeListOfDicts(data1, load_custom_config(custom_config_files[0]), fileName, outputFilename, defaultExt)
    else:
        print("Please pass valid parameters usage : dictmerge.py defaultConfigFilePath customConfigFilePath outputPath")
        exit(1)
else:
    merged = {}
    for custom_config_file in custom_config_files:
        if fileName == "pm4ml-vars.yaml":
            data2 = load_custom_config(custom_config_file)
            if "pm4mls" in data2 and len(data2["pm4mls"]) > 0:
                merged = dict(mergedicts(merged, {'pm4mls': {name: dict(mergedicts(data1, pm4ml)) for name, pm4ml in data2['pm4mls'].items()}}))
        elif fileName == "proxy-pm4ml-vars.yaml":
            data2 = load_custom_config(custom_config_file)
            if "proxy_pm4mls" in data2 and len(data2["proxy_pm4mls"]) > 0:
                merged = dict(mergedicts(merged, {'proxy_pm4mls': {name: dict(mergedicts(data1, pm4ml)) for name, pm4ml in data2['proxy_pm4mls'].items()}}))
        else:
            data1 = dict(mergedicts(data1, load_custom_config(custom_config_file)))
            merged = data1
    if defaultExt == ".yaml":
        #result = yaml.dump(dict(data1), indent=4, sort_keys=True)
        with open(outputFilename, 'w') as file:
            yaml.dump(merged, file, indent=4, default_flow_style=False, Dumper=CustomDumper)
    elif defaultExt == ".json":
        with open(outputFilename, 'w') as file:
            json.dump(merged, file, indent=4)
