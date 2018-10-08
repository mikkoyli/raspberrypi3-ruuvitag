import json
import urllib.request
import time
import uuid

import ruuvitag_sensor
from ruuvitag_sensor.log import log
from ruuvitag_sensor.ruuvi import RuuviTagSensor
from ruuvitag_sensor.ruuvitag import RuuviTag

with open('./config.json') as json_data_file:
    data = json.load(json_data_file)

serverUrl=data['variables']['server-url']
bufferFile=data['variables']['buffer-file']
tableName=data['variables']['table-name']

ruuvitag_sensor.log.enable_console()

# Beacon mac address
sensor = RuuviTag('E0:F2:07:84:6D:11')

# Unique identifier generated from hostname
uuid = uuid.uuid3(uuid.NAMESPACE_DNS, 'localhost')
# Table name for saving data

# update state from the device
state = sensor.update()

# get latest state (does not get it from the device)
state = sensor.state

# double encode json
double_encode = json.dumps(state)

# generate json
jsonData = {"deviceId": str(uuid),
    "tableName": tableName,
    "timestamp": int(time.time()),
    "data": double_encode
}

try:
    # insert request
    params = json.dumps(jsonData).encode('utf8')
    #print(params)
    req = urllib.request.Request(serverUrl, data=params,
        headers={'content-type': 'application/json'})
    response = urllib.request.urlopen(req)
    #print output
    resp_string = response.read().decode('utf8')
    print(resp_string)
    resp_json = json.loads(resp_string)
    #print(resp_json['success'])

    if str(resp_json['success']) is 'True':
        print('Succesfully inserted data')
    elif str(resp_json['success']) is 'False':
        print('Data insertion failed')
        raise ValueError('result false')
    else:
        print('wtf')
        raise ValueError('wtf error')

except:
    f = open(bufferFile, 'a')
    f.write(str(json.dumps(jsonData)) + '\n' )
    print('data written to file')
    f.close
