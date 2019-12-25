import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/games_cleaned_before_encoding.csv')

df2['game_made_with'] = df2['game_made_with'].replace(np.nan, '', regex=True)
engine_count = {}
                   
for i, row in df2.iterrows():
    engines = row['game_made_with'].lower().split("||")
    for engine in engines:
        if engine not in engine_count:
            engine_count[engine] = 0      
        engine_count[engine] += 1  

print(engine_count)
print("========================")
print(len(engine_count))
# print(host_count['game maker\'s toolkit'])
# print(host_count['visuals'])

header = ["game_made_with", "count"]

output = "dataset/sub_set_game_made_with_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in engine_count:
        writer.writerow({'game_made_with': key, 
                         'count': engine_count[key]})

f.close()