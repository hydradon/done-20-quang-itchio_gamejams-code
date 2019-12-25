import pandas as pd

df2 = pd.read_csv("dataset/all_games_details_cleaned.csv")

max_no = 0
url = ""
name = ""
for i, row in df2.iterrows():
    num_dev = len(row["game_developers"].split("||"))

    if (num_dev > max_no):
        max_no = num_dev
        url = row["game_url"]
        name = row["game_name"]

print(max_no)
print(url)
print(name)
