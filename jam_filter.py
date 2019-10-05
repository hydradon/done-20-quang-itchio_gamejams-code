import pandas as pd
import numpy as np

df2 = pd.read_csv('itchiocrawler/jams.csv')
df2.dropna(subset=['jam_criteria'], inplace=True)
df2['jam_no_rating'].fillna('0', inplace = True)

df2['jam_no_rating'] = df2['jam_no_rating'].str.replace(',', '')

df2['jam_no_rating'] = (df2['jam_no_rating'].replace(r'[km]+$', '', regex=True).astype(float) * \
                        df2['jam_no_rating'].str.extract(r'[\d\.]+([km]+)', expand=False)
                                            .fillna(1)
                                            .replace(['k','m'], [10**3, 10**6]).astype(int)).astype(int)

print(len(df2))
print(df2.head(15))
df2.to_csv('jams-filter.csv', encoding='utf-8-sig', index=False)