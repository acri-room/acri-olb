#!/usr/bin/env python3
# public key updater / 2024-12-16 Naoki F., AIT

import os
import sys
import json
from datetime import datetime
import urllib.request

server_url  = 'http://172.16.2.5:20080/keys-process.cgi'
time_file   = os.path.dirname(__file__) + '/DB/time.json'
log_file    = '/var/log/update-keys.log'
key_dir     = '/var/ssh/keys/'
date_format = '%Y-%m-%d %H:%M:%S'

date_now = datetime.now().strftime(date_format)
log = open(log_file, mode='w')
print(f"Update key process started at {date_now}", file=log)

# read local list of lastly updated time
times = {}
try:
    with open(time_file) as f:
        times = json.load(f)
except OSError as err:
    print(f"Failed to read local database ({err}). Rebuilding", file=log)
except json.JSONDecodeError as err:
    print(f"Local database is invalid ({err}). Rebuilding", file=log)

# fetch recent keys from Web server
req = urllib.request.Request(server_url)
try:
    with urllib.request.urlopen(req) as res:
        keys = json.load(res)
except urllib.error.HTTPError as err:
    print(f"Server returns {err.code} error", file=log)
    sys.exit(1)
except urllib.error.URLError as err:
    print(f"Cannot access to server: {err.reason}", file=log)
    sys.exit(1)
except json.JSONDecodeError as err:
    print(f"Server returns invalid JSON: {err}", file=log)
    sys.exit(1)
print(f"Server returns {len(keys)} key(s)", file=log)

# update key files
results = {}
for key in keys:
    ftime = times[key['nicename']] if key['nicename'] in times else '2000-01-01 00:00:00'
    ftime = datetime.strptime(ftime, date_format)
    ktime = datetime.strptime(key['updated'], date_format)
    if ftime >= ktime:
        print(f"Keys for user {key['nicename']} is already updated", file=log)
        continue
    with open(key_dir + key['nicename'], mode='w') as f:
        for k in key['keys']:
            print(k, file=f)
    times[key['nicename']] = key['updated']
    results[key['nicename']] = date_now
    print(f"Keys for user {key['nicename']} has been updated", file=log)

# send ack to Web server
if len(results) != 0:
    try:
        with open(time_file, mode="w") as f:
            json.dump(times, f)
    except OSError as err:
        print(f"Failed to write local database ({err}). Ignored", file=log)

    header = {"Content-Type": "application/json"}
    req = urllib.request.Request(server_url, json.dumps(results).encode(), header)
    try:
        with urllib.request.urlopen(req) as res:
            body = res.read()
    except urllib.error.HTTPError as err:
        print(f"Server returns {err.code} error", file=log)
        sys.exit(1)
    except urllib.error.URLError as err:
        print(f"Cannot access to server: {err.reason}", file=log)
        sys.exit(1)
    print(f"Ack was sent to server: {body}", file=log)

print(f"Update key process finished", file=log)