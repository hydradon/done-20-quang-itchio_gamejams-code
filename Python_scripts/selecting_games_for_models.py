import pandas as pd
from datetime import datetime, timedelta
import os
import numpy as np
from natsort import index_natsorted, order_by_index
import math
# import category_encoders as ce

# df_jams = pd.read_csv('../dataset/jams-with-lang1.csv')
df_jams = pd.read_csv('../dataset/jams.csv')
df_games = pd.read_csv('../dataset/all_games_details_cleaned.csv')

# only get jams with 10 submissions and above
df_jams = df_jams[pd.to_numeric(df_jams.jam_no_submissions) >= 10]

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

# Write new cleaned jam dataset for debugging purpose only
output_jam = "../dataset/jams_cleaned_for_debugging_purpose.csv"
if os.path.exists(output_jam):
    os.remove(output_jam)
df_jams.to_csv(output_jam, encoding='utf-8-sig', index=False)

# Add www to jam_url in game dataset
df_games['jam_url'] = df_games['jam_url'].str.replace('https://itch.io', 'https://www.itch.io')
df_games = df_games[df_games.jam_url.isin(df_jams.jam_url)]
print(len(df_games))

# Remove games without ranking
df_games['game_ranks'].replace('', np.nan, inplace=True)
df_games.dropna(subset=['game_ranks'], inplace=True)
print(len(df_games))

#Remove games with less than 10 rating
df_games = df_games[df_games.game_no_ratings > 9]

# Extract only Overall ranking or game with one criteria
for i, row in df_games.iterrows():
    criteria = row['game_criteria'].split("||")

    # print(criteria)
    rank = ""

    if len(criteria) > 1:
        # print("There are many criteria")
        for criterion in criteria:
            # print("Processing criterion:..." + criterion)
            # input(".....")
            if "Overall" == criterion:
                # print("Found Overall criterion")
                rankings = row['game_ranks'].split("||")
                # print(rankings)
                # print("Index of Overall criterion: " + str(criteria.index(criterion)))
                rank = rankings[criteria.index(criterion)]
                # print(rank)
                break
            elif "Overall" in criterion:
                # print("Found Overall IN criterion")
                rankings = row['game_ranks'].split("||")
                # print(rankings)
                # print("Index of Overall criterion: " + str(criteria.index(criterion)))
                rank = rankings[criteria.index(criterion)]
                # print(rank)
    
    else:
        rank = row['game_ranks']

    df_games.loc[i, 'overall_rank'] = rank

# Drop rows with no Overall ranking
df_games = df_games[df_games.overall_rank != '']



# Extract top and bottom 20% ranked games
frames = []

for i, row in df_jams.iterrows():
    jam_url = row['jam_url']
    # print(jam_url)
    games_in_jam = df_games[df_games.jam_url.isin([row['jam_url']])]

    if (len(games_in_jam) > 0):
        # print("Found jams with games")
      
        games_in_jam = games_in_jam.reindex(index=order_by_index(games_in_jam.index,
                                                                 index_natsorted(games_in_jam['overall_rank'],
                                            reverse=False)))

        top_n = math.ceil(len(games_in_jam)*(20/100))

        top_20_games = games_in_jam.head(top_n)
        top_20_games.insert(len(top_20_games.columns), 
                            'high_ranking',
                            pd.Series("Yes",  index=top_20_games.index))
        frames.append(top_20_games)

        bottom_20_games = games_in_jam.tail(top_n)
        bottom_20_games.insert(len(bottom_20_games.columns), 
                               'high_ranking',
                               pd.Series("No",  index=bottom_20_games.index))
        frames.append(bottom_20_games)
        # break

df_concat = pd.concat(frames)

# Calculate number of developer
df_concat["num_devs"] = df_concat["game_developers"].map(lambda a: len(a.split("||")))

# Calculate number of supported platforms
df_concat["num_platforms"] = df_concat["game_platforms"].map(lambda a: len(a.split("||")) if pd.notna(a) else 0)

# Calculate number of game genres
df_concat["num_genres"] = df_concat["game_genres"].map(lambda a: len(a.split("||")) if pd.notna(a) else 0)

# Calculate number of supported input
df_concat["num_inputs"] = df_concat["game_inputs"].map(lambda a: len(a.split("||")) if pd.notna(a) else 0)

# Calculate number of madeWith
df_concat["num_madeWiths"] = df_concat["game_made_with"].map(lambda a: len(a.split("||")) if pd.notna(a) else 0)


output_game = "../dataset/games_cleaned_before_encoding.csv"
if os.path.exists(output_game):
    os.remove(output_game)
df_concat.to_csv(output_game, encoding='utf-8-sig', index=False)

# Encoding categorical variables
df_final = pd.concat([df_concat,
                      df_concat.game_platforms.str.get_dummies().add_prefix('platform_'),
                      df_concat.game_genres.str.get_dummies().add_prefix('genre_'),
                      df_concat.game_inputs.str.get_dummies().add_prefix('input_'),
                      df_concat.game_ave_session.str.get_dummies().add_prefix('aveSession_'),
                      df_concat.game_made_with.str.get_dummies().add_prefix('madeWith_')
                     ],
                     axis=1)

# Encoding game_ave_session
# import category_encoders as ce
# encoder = ce.BinaryEncoder(cols=['game_ave_session'])
# df_final['game_ave_session'] = df_final['game_ave_session'].astype('category')
# df_final = encoder.fit_transform(df_final)
# df_final['game_ave_session_encode'] = df_final['game_ave_session'].cat.codes

# Combining accessibility, MIT license, asset license
# df_final['has_accesibility'] = pd.notnull(df_final["game_accessibility"]) 
df_final['has_accesibility'] = df_final["game_accessibility"].apply(lambda x: 0 if pd.isnull(x) else 1)
df_final['has_license'] = df_final["game_license"].apply(lambda x: 0 if pd.isnull(x) else 1)
df_final['has_asset_license'] = df_final["game_asset_license"].apply(lambda x: 0 if pd.isnull(x) else 1)

# Dropping not neccessary columns
# removed_made_with = [c for c in df_final.columns if "madeWith_" in c and "Unity" not in c]
# df_final.drop(removed_made_with +
#               ["platform_Java"], 
#               axis = 1, inplace=True)

# Dropping redundant columns
df_final.drop(["jam_name", 
               "game_tags", 
               "game_release_date",
               "game_raw_scores",
               "game_scores",
               "game_publish_date",
               "game_size",
               "game_status",
               "game_last_update",
               "game_developers",
               "game_genres",
               "game_inputs",
               "game_license",
               "game_asset_license",
               "game_made_with",
               "game_name",
               "game_platforms",
               "game_price",
               "game_ranks",
               "game_submission_page",
               "game_url",
               "jam_url",
               "game_developers_url",
               "game_language",
               "game_no_ratings",
               "game_criteria",
               "game_accessibility",
               "game_ave_session",
               "game_source_code",
               "overall_rank"
               ], 
              axis=1, inplace=True) 



# this works!
# from sklearn.feature_extraction.text import CountVectorizer
# cv = CountVectorizer()
# t = pd.DataFrame(cv.fit_transform(df_concat.game_platforms.fillna('').str.replace(r'\|\|', ' ')).A,
#                      columns=cv.get_feature_names(),
#                      index=df_concat.index).add_prefix('platform_')

# df_final = pd.concat([df_concat, t], axis=1, sort=False)

# This works too!!
# s = [df_concat[col].str.get_dummies().add_prefix(f'{col.lower()}_') 
#         for col in ['game_platforms']]
# df_final = pd.concat([df_concat] + s, axis=1)


# Write new cleaned game dataset
output_game = "../dataset/games_cleaned.csv"
if os.path.exists(output_game):
    os.remove(output_game)
df_final.to_csv(output_game, encoding='utf-8-sig', index=False)

