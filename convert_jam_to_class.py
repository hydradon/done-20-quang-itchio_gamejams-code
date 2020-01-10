import pandas as pd
from datetime import datetime, timedelta
import os
import numpy as np
from natsort import index_natsorted, order_by_index
import math

df_jams = pd.read_csv('dataset/jams-with-lang1.csv')
df_jam_desc = pd.read_csv('dataset/jam_desc_x.csv')

# get jams with duration 1hour and truncate top 1% jams
# 2016-11-14 12:00:00	
date_pattern = "%Y-%m-%d %H:%M:%S"
df_jams["jam_duration"] = (pd.to_datetime(df_jams['jam_end_date'], format=date_pattern) - \
                           pd.to_datetime(df_jams['jam_start_date'], format=date_pattern)) / \
                           timedelta(hours = 1)
df_jams = df_jams[df_jams['jam_duration'] > 1] # only get jams lasting more than 1 hour
df_jams.sort_values(by=['jam_duration'], 
                    ascending=True, 
                    inplace=True)
df_jams = df_jams.head(int(len(df_jams)*(99/100))) # remove top 1% in length

# join jam and jam desc
df_jam_all = pd.merge(df_jams, df_jam_desc, on='jam_url', how='inner')

# Calculate number of hosts
df_jam_all["num_hosts"] = df_jam_all["jam_host"].map(lambda a: len(a.split("||")))

# Separate into competitive jam and non-competitive jam
# competitive_jams = df_jam_all.dropna(subset=['jam_criteria'])
competitive_jams = df_jam_all[df_jam_all['jam_criteria'].notnull()]
non_competitive_jams = df_jam_all[df_jam_all['jam_criteria'].isnull()]

# Calculate number of criteria for competitive jam
competitive_jams["num_criteria"] = competitive_jams["jam_criteria"].map(lambda a: len(a.split("||")))

print(len(df_jam_all))
print(len(competitive_jams))
print(len(non_competitive_jams))


# Get top and bottom 20% jam by popularity (number of submissions) - Competitive jams
top_n = math.ceil(len(competitive_jams)*(20/100))
competitive_jams = competitive_jams.reindex(index=order_by_index(competitive_jams.index,
                                                                index_natsorted(competitive_jams['jam_no_submissions'],
                                            reverse=True)))
top_20_jam = competitive_jams.head(top_n)
top_20_jam.insert(len(top_20_jam.columns), 
                    'popular',
                    pd.Series("Yes", index=top_20_jam.index))
# frames.append(top_20_jam)

bottom_20_jam = competitive_jams.tail(top_n)
bottom_20_jam.insert(len(bottom_20_jam.columns), 
                        'popular',
                        pd.Series("No", index=bottom_20_jam.index))
# frames.append(bottom_20_jam)
final_competitive_jams = pd.concat([top_20_jam, bottom_20_jam])


# Get top and bottom 20% jam by popularity (number of submissions) - Non-Competitive jams
top_n = math.ceil(len(non_competitive_jams)*(20/100))
non_competitive_jams = non_competitive_jams.reindex(index=order_by_index(non_competitive_jams.index,
                                                                        index_natsorted(non_competitive_jams['jam_no_submissions'],
                                                    reverse=True)))
top_20_jam = non_competitive_jams.head(top_n)
top_20_jam.insert(len(top_20_jam.columns), 
                    'popular',
                    pd.Series("Yes", index=top_20_jam.index))
# frames.append(top_20_jam)

bottom_20_jam = non_competitive_jams.tail(top_n)
bottom_20_jam.insert(len(bottom_20_jam.columns), 
                        'popular',
                        pd.Series("No", index=bottom_20_jam.index))
# frames.append(bottom_20_jam)
final_non_competitive_jams = pd.concat([top_20_jam, bottom_20_jam])


# Write competitive_jams dataset
output_file = "dataset/competitive_jams_cleaned.csv"
if os.path.exists(output_file):
    os.remove(output_file)
final_competitive_jams.to_csv(output_file, encoding='utf-8-sig', index=False)

# Write non competitive_jams dataset
output_file = "dataset/non_competitive_jams_cleaned.csv"
if os.path.exists(output_file):
    os.remove(output_file)
final_non_competitive_jams.to_csv(output_file, encoding='utf-8-sig', index=False)