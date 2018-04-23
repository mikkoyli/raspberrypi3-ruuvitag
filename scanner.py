import sys
import argparse
import json
import urllib.request
import time
import uuid

import ruuvitag_sensor
from ruuvitag_sensor.log import log
from ruuvitag_sensor.ruuvi import RuuviTagSensor
from ruuvitag_sensor.ruuvitag import RuuviTag

ruuvitag_sensor.log.enable_console()

datas = RuuviTagSensor.get_data_for_sensors(bt_device='')
log.info(datas)

for key, value in datas.items():
    # Beacon mac address
    sensor = RuuviTag(key)
    # Unique identifier generated from hostname
    uuid = uuid.uuid3(uuid.NAMESPACE_DNS, 'localhost')
    # Table name for saving data
    table = "RuuviTag"

    # update state from the device
    state = sensor.update()

    # get latest state (does not get it from the device)
    state = sensor.state

    # double encode json
    double_encode = json.dumps(state)

    # generate json
    serverUrl = ''
    jsonData = {"deviceId": str(uuid),
        "tableName": table,
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
        f = open('data.txt', 'a')
        f.write(str(json.dumps(jsonData)) + '\n' )
        print('data written to file')
        f.close

to_be_inserted = []

try:
    with open('./data.txt') as f:
        for line in f:
            print(line)
            try:
                b = line.encode('utf-8')
                req = urllib.request.Request(serverUrl, data=b,
                    headers={'content-type': 'application/json'})
    
                response = urllib.request.urlopen(req)
                #print output
                resp_string = response.read().decode('utf8')
                print(resp_string)
                resp_json = json.loads(resp_string)
    
                if str(resp_json['success']) is 'True':
                     print('Succesfully inserted data')
                elif str(resp_json['success']) is 'False':
                    print('Data insertion failed')
                    raise ValueError('result false')
                else:
                    print('wtf')
                    raise ValueError('wtf error')
            except:
                to_be_inserted.append(line)
    f.close
except IOError:
      print("Buffer file doesn't exist")

if len(to_be_inserted) > 0:
    f = open('data.txt', 'w')
    i = 0
    while i < len(to_be_inserted):
        print(to_be_inserted[i])
        f.write(to_be_inserted[i])
        print('data written to file')
        i += 1
    f.close
else:
    print('nothing to insert in file')
