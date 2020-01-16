import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('../dataset/misc/jam-criteria-lang1.csv')

df2['criteria'] = df2['criteria'].replace(np.nan, '', regex=True)

df2.drop(df2[(df2.jam_english == 'n') | (df2.jam_english == 'u')].index, inplace=True)
# print(len(df2))
criteria_count = {}

for i, row in df2.iterrows():
    criteria_count[row["criteria"]] = int(row["count"])


criteria_copy = criteria_count.copy()
# Combine all visual key:
total = 0
for key in criteria_copy:
    if ("visual" in key or 
        "graphic" in key or 
        "aesthetic" in key or 
        "art " in key or
        " art" in key or
        "arts" in key or
        "art" == key or
        "looks" in key or
        "artwork" in key or
        "graphisms" in key or
        "user interface" in key or
        "artist" in key or
        "appearance" in key or
        "presentation" in key or
        "animation" in key):

        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["visual"] = total
print(criteria_count["visual"])


# merge all audio key:
total = 0
for key in criteria_copy:
    if ("audio" in key or 
        "sound" in key or 
        "music" in key):

        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["sound"] = total
print(criteria_count["sound"])

# merge all theme key:
total = 0
for key in criteria_copy:
    if ("theme" in key or
        "relevan" in key or
        "topic" in key):
        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["theme"] = total
print(criteria_count["theme"])

# Combine all innovative, creativity key:
total = 0
for key in criteria_copy:
    if ("innovat" in key or 
        "creativ" in key or 
        "original" in key or 
        "unique" in key or
        "idea" in key or
        "eccentric" in key or
        "concept" in key):

        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["innovation/creativity"] = total
print(criteria_count["innovation/creativity"])

# Combine all overall key:
total = 0
for key in criteria_copy:
    if ("overall" in key or 
        ("best" in key and "game" in key) or
        "quality" == key or
        "favorite" in key):
        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["overall"] = total
print(criteria_count["overall"])


# Combine all gameplay/experience key:
total = 0
for key in criteria_copy:
    if ("gameplay" in key or 
        "experience" in key or
        "playab" in key or # playability/playable
        "game play" in key or
        "immersive" in key or
        "replay" in key or 
        "mood" in key or
        "atmosphere" in key or
        "feel" in key): 

        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["gameplay/experience"] = total
print(criteria_count["gameplay/experience"])

# Combine all fun/enjoyment key:
total = 0
for key in criteria_copy:
    if ("fun" in key or 
        "enjoy" in key or 
        "entertain" in key or
        "humor" in key):
        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["fun/entertainment"] = total
print(criteria_count["fun/entertainment"])

# Combine all writing/narrative key:
total = 0
for key in criteria_copy:
    if ("write" in key or 
        "writing" in key or 
        "plot" in key or
        "narrati" in key or
        "story" in key or
        "content" in key):

        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["plot/story/writing"] = total
print(criteria_count["plot/story/writing"])

# Combine all control/mechanics key:
total = 0
for key in criteria_copy:
    if ("control" in key or 
        "mechanic" in key or 
        "technical" in key or
        "programming" in key or
        "stability" in key or
        "code" in key or
        "bug-free" in key):

        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["technical/mechanic"] = total
print(criteria_count["technical/mechanic"])

# Combine all design key:
total = 0
for key in criteria_copy:
    if ("design" in key):

        # print(key)
        # print(criteria_count[key])
        total += criteria_copy[key]
        criteria_count.pop(key, 0)
criteria_count["design"] = total
print(criteria_count["design"])

output = "../dataset/misc/criteria_combined.csv"
if os.path.exists(output):
    os.remove(output)

header = ["criteria", "count"]
with open(output, 'w', encoding='utf-8-sig', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=header)
    writer.writeheader()
    for key in criteria_count:
        writer.writerow({'criteria': key, 'count': criteria_count[key]})

f.close()