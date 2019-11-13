import pandas as pd
import numpy as np
import csv
import codecs

criteria_lang = {}
f = codecs.open('dataset/jam_criteria_lang.csv',"rb","utf-16")
csvread = csv.reader(f, delimiter='\t')
next(csvread, None)
for row in csvread:
    criteria_lang[row[0]] = row[2]


df_jam = pd.read_csv('dataset/criteria_count.csv')
df_jam['criteria'] = df_jam['criteria'].replace(np.nan, '', regex=True)
for i, row in df_jam.iterrows():
    if (row['criteria'] in criteria_lang):
        df_jam.loc[i, 'jam_english'] = criteria_lang[row['criteria']]

df_jam.to_csv('dataset/jam-criteria-lang1.csv', encoding='utf-8-sig', index=False)