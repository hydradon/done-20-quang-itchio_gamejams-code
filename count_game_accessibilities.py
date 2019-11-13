import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/non_competitive_game_details.csv')

df2['game_accessibility'] = df2['game_accessibility'].replace(np.nan, '', regex=True)
game_accessibility_count = {}
                   
for i, row in df2.iterrows():
    supports = row['game_accessibility'].lower().split("||")
    for support in supports:
        if support not in game_accessibility_count:
            game_accessibility_count[support] = 0      
        game_accessibility_count[support] += 1  

print(game_accessibility_count)
print("========================")
print(len(game_accessibility_count))
# print(host_count['game maker\'s toolkit'])
# print(host_count['visuals'])

header = ["game_accessibility", "count"]

output = "dataset/game_accessibility_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in game_accessibility_count:
        writer.writerow({'game_accessibility': key, 
                         'count': game_accessibility_count[key]})

f.close()