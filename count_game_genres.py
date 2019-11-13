import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/non_competitive_game_details.csv')

df2['game_genres'] = df2['game_genres'].replace(np.nan, '', regex=True)
genre_count = {}
                   
for i, row in df2.iterrows():
    genres = row['game_genres'].lower().split("||")
    for genre in genres:
        if genre not in genre_count:
            genre_count[genre] = 0      
        genre_count[genre] += 1  

print(genre_count)
print("========================")
print(len(genre_count))
# print(host_count['game maker\'s toolkit'])
# print(host_count['visuals'])

header = ["game_genre", "count"]

output = "dataset/game_genre_count.csv"
if os.path.exists(output):
    os.remove(output)

with open(output, 'w', encoding='utf-8-sig', newline='') as f:  # Just use 'w' mode in 3.x
    writer = csv.DictWriter(f, fieldnames=header)

    writer.writeheader()
    for key in genre_count:
        writer.writerow({'game_genre': key, 
                         'count': genre_count[key]})

f.close()