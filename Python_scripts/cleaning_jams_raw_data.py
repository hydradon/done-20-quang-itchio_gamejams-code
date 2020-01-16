import pandas as pd
import numpy as np
import os

df2 = pd.read_csv('../dataset/jams-raw.csv')

# Fill jams with no ratings information with 0
df2['jam_no_rating'].fillna('0', inplace = True)

# Remove ',' from the number
df2['jam_no_rating'] = df2['jam_no_rating'].str.replace(',', '')

# Convert k, m to 000 and 000000
df2['jam_no_rating'] = (df2['jam_no_rating'].replace(r'[km]+$', '', regex=True).astype(float) * \
                        df2['jam_no_rating'].str.extract(r'[\d\.]+([km]+)', expand=False)
                                            .fillna(1)
                                            .replace(['k','m'], [10**3, 10**6]).astype(int)).astype(int)

# TODO
# Overall||Gameplay||Theme||Graphics||Audio for jam: GC Jam 3
# df2.loc[(df2['jam_no_rating'] == 'GC Jam 3'), 'C'] = df.A * df.B
output = "../dataset/jams.csv"
if os.path.exists(output):
    os.remove(output)

df2.to_csv(output, encoding='utf-8-sig', index=False)