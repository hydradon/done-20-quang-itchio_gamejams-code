import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/games_cleaned_before_encoding.csv')

df2['game_inputs'] = df2['game_inputs'].replace(np.nan, '', regex=True)
game_input_count = {}
                   
for i, row in df2.iterrows():
    inputs = row['game_inputs'].lower().split("||")
    for inp in inputs:
        if inp not in game_input_count:
            game_input_count[inp] = 0      
        game_input_count[inp] += 1  

print(game_input_count)
print("========================")
print(len(game_input_count))
header = ["game_input", "count"]

output = "dataset/sub_set_game_input_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in game_input_count:
        writer.writerow({'game_input': key, 
                         'count': game_input_count[key]})

f.close()