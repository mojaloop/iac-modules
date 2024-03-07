import yaml
import json
import sys
import os

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

if len(sys.argv) == 4:
    default_config_file = sys.argv[1]
    custom_config_file = sys.argv[2]
    outputPath = sys.argv[3]
    outputFilename = outputPath+"/"+os.path.basename(default_config_file).split('/')[-1]
    defaultExt = os.path.splitext(default_config_file)[1]
    customExt = os.path.splitext(custom_config_file)[1]
    if defaultExt != customExt:
        print("Please pass same type of files to merge")  
        exit(1)
else:
    print("Please pass valid parameters usage : dictmerge.py defaultConfigFilePath customConfigFilePath outputPath")  
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

if os.path.isfile(custom_config_file):
    if customExt == ".yaml":
        with open(custom_config_file, 'r') as f:
            data2 = yaml.load(f, Loader=yaml.SafeLoader)
    elif defaultExt == ".json":
        with open(custom_config_file, 'r') as f:
            data2 = json.load(f)    

    else:
       print("File type not supported")
       exit(1)                        
else:
    print("Custom config file "+custom_config_file+" file does not exist. Assigning empty data dict")
    data2 = {}


if defaultExt == ".yaml":
    #result = yaml.dump(dict(mergedicts(data1, data2)), indent=4, sort_keys=True)
    with open(outputFilename, 'w') as file:
        yaml.dump(dict(mergedicts(data1, data2)), file)
elif defaultExt == ".json":
    with open(outputFilename, 'w') as file:
        json.dumps(dict(mergedicts(data1, data2)), file)

