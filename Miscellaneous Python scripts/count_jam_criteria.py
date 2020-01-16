import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('../dataset/jams.csv')

df2['jam_criteria'] = df2['jam_criteria'].replace(np.nan, '', regex=True)
criteria_count = {}
                   
for i, row in df2.iterrows():
    criteria = row['jam_criteria'].lower().split("||")
    for item in criteria:

        if item not in criteria_count:
            criteria_count[item] = 0
        criteria_count[item] += 1

# print(criteria_count)
print("========================")
print(len(criteria_count))
print(criteria_count['visual'])
print(criteria_count['visuals'])

output = "../dataset/features_count/criteria_count.csv"
if os.path.exists(output):
    os.remove(output)


header = ["criteria", "count"]

with open(output, 'w', encoding='utf-8-sig', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=header)
    writer.writeheader()
    for key in criteria_count:
        writer.writerow({'criteria': key, 'count': criteria_count[key]})

f.close()