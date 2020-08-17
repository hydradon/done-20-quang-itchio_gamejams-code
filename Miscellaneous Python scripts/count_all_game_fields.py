import os
dataset = "../dataset/all_games_details_cleaned.csv"

game_fields = [
               "game_accessibility",
               "game_genres",
               "game_inputs",
               "game_made_with",
               "game_platforms",
               "game_status",
               "game_tags",
               "game_license",
               "game_asset_license",
               "game_language",
               "game_ave_session",
               "game_source_code"
              ]

for game_field in game_fields:
    command = "python count_game_fields.py " + game_field + " " + dataset
    os.system(command)



