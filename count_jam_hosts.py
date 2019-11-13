import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/jams1.csv')

# df2['jam_criteria'] = df2['jam_criteria'].replace(np.nan, '', regex=True)
host_count = {}
host_submissions = {}
                   
for i, row in df2.iterrows():
    hosts = row['jam_host'].lower().split("||")
    for host in hosts:
        if host not in host_count:
            host_count[host] = 0
        if host not in host_submissions:
            host_submissions[host] = 0
        host_count[host] += 1
        host_submissions[host] += row['jam_no_submissions']

# print(host_count)
# print("========================")
print(len(host_count))
print(host_count['game maker\'s toolkit'])
# print(host_count['visuals'])

header = ["host", "count", "total_submissions", "average_submissions_per_jam"]

output = "dataset/host_count_submissions.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in host_count:
        writer.writerow({'host': key, 
                         'count': host_count[key], 
                         'total_submissions': host_submissions[key],
                         'average_submissions_per_jam': host_submissions[key] / host_count[key]})

f.close()