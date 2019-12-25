import pandas as pd
import numpy as np
import csv
import os
import sys

game_field = sys.argv[1]
datafile = sys.argv[2]
print("Counting game field: " + game_field + 
      "\nin data file: " + datafile)

df2 = pd.read_csv(datafile)
total = len(df2)

df2[game_field] = df2[game_field].replace(np.nan, '', regex=True)
field_count = {}
                   
for i, row in df2.iterrows():
    items = row[game_field].lower().split("||")
    for item in items:
        if item not in field_count:
            field_count[item] = 0      
        field_count[item] += 1  

header = [game_field, "count", "percentage"]

output = "dataset/" + game_field + "_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in field_count:
        writer.writerow({game_field: key, 
                         'count': field_count[key],
                         'percentage': field_count[key] * 100.0 / total})

f.close()