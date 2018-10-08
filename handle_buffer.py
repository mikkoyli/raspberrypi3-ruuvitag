import json
import urllib.request

with open('./config.json') as json_data_file:
    data = json.load(json_data_file)

serverUrl=data['variables']['server-url']
bufferFile=data['variables']['buffer-file']
tableName=data['variables']['table-name']

to_be_inserted = []

try:
    with open(bufferFile) as f:
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
      print("buffer file doesn't exist")

if len(to_be_inserted) > 0:
    f = open(bufferFile, 'w')
    i = 0
    while i < len(to_be_inserted):
        print(to_be_inserted[i])
        f.write(to_be_inserted[i])
        print('data written to file')
        i += 1
    f.close
else:
    open(bufferFile, 'w').close()
    print('nothing to insert in file')