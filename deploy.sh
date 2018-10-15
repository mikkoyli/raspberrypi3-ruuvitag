#!/bin/bash
set -e

echo "*** Starting deployment"

ip_addr=''
while [ ! $ip_addr ]
do
  echo "IP address:"
  read ip_addr
done

scp ./cron.txt ./handle_buffer.py ./config.json ./run.py pi@$ip_addr:/home/pi
ssh -t pi@$ip_addr "cat cron.txt | crontab"
