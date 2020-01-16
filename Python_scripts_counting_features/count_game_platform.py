import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/games_cleaned.csv')

df2['game_platforms'] = df2['game_platforms'].replace(np.nan, '', regex=True)
platform_count = {}
                   
for i, row in df2.iterrows():
    platforms = row['game_platforms'].lower().split("||")
    for platform in platforms:
        if platform not in platform_count:
            platform_count[platform] = 0      
        platform_count[platform] += 1  

header = ["game_platform", "count"]

output = "dataset/sub_set_game_platforms_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in platform_count:
        writer.writerow({'game_platform': key, 
                         'count': platform_count[key]})

f.close()