import pandas as pd
import io
import os

df = pd.read_csv('../dataset/all_game_details.csv')
df.dropna(subset=['game_size'], inplace = True) # process game with size only
print("Number of games with size: {}".format(len(df)))

fields = ['game_url', 'game_upload_filename', 'game_file_extension', 'game_upload_filesize', 'game_upload_date', 'game_upload_platforms']

items = []

for game_url, game_size in zip(df['game_url'], df['game_size']): 
    all_uploads = game_size.split('<>')
    for upload in all_uploads:
       
        item = {}
        item['game_url'] = game_url
        details = upload.split('||')

        if ". " not in details[0] and "." in details[0]:
            item['game_file_extension'] = details[0].split(".")[-1]
            item['game_upload_filename'] = ".".join(details[0].split(".")[:-1])
        else:
            item['game_file_extension'] = ""
            item['game_upload_filename'] = details[0]

        item['game_upload_filesize'] = details[1]
        item['game_upload_date'] = details[2]
        item['game_upload_platforms'] = "||".join(details[3:])

        items.append(item)

output = "../dataset/misc/game_size.csv"
if os.path.exists(output):
    os.remove(output)

with io.open(output, 'a+', encoding='utf-8-sig') as f: # handle the source file
    f.write("{}\n".format('\t'.join(str(field) for field in fields))) # write header 

    for item in items:
        f.write("{}\n".format('\t'.join(str(item[field]) for field in fields))) # write items
f.close()
