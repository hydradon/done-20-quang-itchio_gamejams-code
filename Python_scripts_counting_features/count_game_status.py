import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/non_competitive_game_details.csv')

df2['game_status'] = df2['game_status'].replace(np.nan, '', regex=True)
status_count = {}
                   
for i, row in df2.iterrows():
    statuses = row['game_status'].lower().split("||")
    for status in statuses:
        if status not in status_count:
            status_count[status] = 0      
        status_count[status] += 1  

print(status_count)
print("========================")
print(len(status_count))
# print(host_count['game maker\'s toolkit'])
# print(host_count['visuals'])

header = ["game_status", "count"]

output = "dataset/game_status_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in status_count:
        writer.writerow({'game_status': key, 
                         'count': status_count[key]})

f.close()