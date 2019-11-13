
# mydict = {"sound": "1", "sound and visual" : "2", "sound and visual and theme" : "15", "visual": "3", "theme": "7", "visual and theme": "9"}


# mydict_copy = mydict.copy()
# # Combine all visual key:
# total = 0
# for key in mydict_copy:
#     if "visual" in key:
#         total += int(mydict_copy[key])
#         mydict.pop(key, 0)
# mydict["visual"] = total
# print(mydict["visual"])


# # merge all audio key:
# total = 0
# for key in mydict_copy:
#     if "sound" in key:
#         total += int(mydict_copy[key])
#         mydict.pop(key, 0)
# mydict["sound"] = total
# print(mydict["sound"])

# # merge all theme key:
# total = 0
# for key in mydict_copy:
#     if "theme" in key:
#         total += int(mydict_copy[key])
#         mydict.pop(key, 0)
# mydict["theme"] = total
# print(mydict["theme"])


import pandas as pd
import numpy as np
import csv
import os

df2 = pd.read_csv('dataset/jams1.csv')
df2['jam_criteria'] = df2['jam_criteria'].replace(np.nan, '', regex=True)

max_no = 0
url = ""
for i, row in df2.iterrows():
    num_criteria = len(row['jam_criteria'].lower().split("||"))

    if (num_criteria > max_no):
        max_no = num_criteria
        url = row['jam_url']

print(max_no)
print(url)