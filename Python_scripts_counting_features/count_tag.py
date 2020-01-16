import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/non_competitive_game_details.csv')

df2['game_tags'] = df2['game_tags'].replace(np.nan, '', regex=True)
tag_count = {}
                   
for i, row in df2.iterrows():
    tags = row['game_tags'].lower().split("||")
    for tag in tags:
        if tag not in tag_count:
            tag_count[tag] = 0      
        tag_count[tag] += 1  

print(tag_count)
print("========================")
print(len(tag_count))
# print(host_count['game maker\'s toolkit'])
# print(host_count['visuals'])

header = ["game_tag", "count"]

output = "dataset/game_tags_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in tag_count:
        writer.writerow({'game_tag': key, 
                         'count': tag_count[key]})

f.close()