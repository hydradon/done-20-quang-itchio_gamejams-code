
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



