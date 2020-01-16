import pandas as pd
import numpy as np
import os

df2 = pd.read_csv('../dataset/all_game_details.csv')

# Remove games with no developes => This is an indication of games with inaccessible private pages.
df2.dropna(subset=['game_developers'], inplace=True)
df2['game_no_ratings'] = df2['game_no_ratings'].str.replace(' rating', '')
df2['jam_url'] = df2['jam_url'].str.replace('https://itch.io', 'https://www.itch.io')

output = "../dataset/all_games_details_cleaned.csv"
if os.path.exists(output):
    os.remove(output)

df2.to_csv(output, encoding='utf-8-sig', index=False)