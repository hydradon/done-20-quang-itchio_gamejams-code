import pandas as pd
import numpy as np
import csv
import codecs

criteria_lang = {}

# f = codecs.open('dataset/jam-criteria-lang1.csv',"rb","utf-16-le")
# csvread = csv.reader(f)
# next(csvread, None)
# for row in csvread:
#     # criteria_lang[row[0].strip(u'\u200b')] = row[2]
#     print(row)

df_criteria_lang = pd.read_csv('../dataset/misc/jam-criteria-lang1.csv')
df_criteria_lang['criteria'] = df_criteria_lang['criteria'].replace(np.nan, '', regex=True)
for i, row in df_criteria_lang.iterrows():
    criteria_lang[row[0].strip(u'\u200b')] = row[2]

print(criteria_lang['"i didn\'t expect that" rating'])
print(criteria_lang['•strong connection to the theme'])
print(criteria_lang[''])
# print(criteria_lang)

for key in criteria_lang.keys():
    if "strong connection to the theme" in key:
        print(key)

df_jam = pd.read_csv('../dataset/jams.csv')
df_jam['jam_criteria'] = df_jam['jam_criteria'].replace(np.nan, '', regex=True)
df_jam.columns = df_jam.columns.str.strip()
for i, row in df_jam.iterrows():
    criteria = row['jam_criteria'].lower().split("||")
    if (criteria[0] == ''):
        df_jam.loc[i, 'jam_english'] = 'u'
        continue
    
    for criterion in criteria:
        criterion = criterion.replace('•  ', '•').replace('•\t', '•')
        if (criteria_lang[criterion.strip(u'\u200b')] == 'n'):
            df_jam.loc[i, 'jam_english'] = 'n'
            break
        df_jam.loc[i, 'jam_english'] = 'y'

print(df_jam.head(15))
df_jam.to_csv('../dataset/jams-with-lang.csv', encoding='utf-8-sig', index=False)