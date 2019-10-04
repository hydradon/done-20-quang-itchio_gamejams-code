import pandas as pd
import numpy as np

df1 = pd.read_csv('jams - old.csv')
df2 = pd.read_csv('jams1.csv')

jams_old_names = df1["jam_name"].tolist()
jams1_names = df2["jam_name"].tolist()

print(len(jams_old_names))
print(len(jams1_names))

in_old_not_in_1 = np.setdiff1d(jams_old_names, jams1_names)
in_1_not_in_old = np.setdiff1d(jams1_names, jams_old_names)
print(len(in_old_not_in_1))
print(len(in_1_not_in_old))

print(in_old_not_in_1)
print("===================================================")
print("===================================================")
print("===================================================")
print("===================================================")
print(in_1_not_in_old)




