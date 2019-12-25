import pandas as pd
import numpy as np

df1 = pd.DataFrame(np.array([
[1202, 2007, 99.34,'12||34||4||4||2'],
[9321, 2009, 61.21,'12||34'],
[3832, 2012, 12.32,'12||12||34'],
[1723, 2017, 873.74,'28||13||51']]),
columns=['ID', 'YEAR', 'AMT','PARTS'])

print(pd.get_dummies(df1.set_index(['ID','YEAR','AMT']).PARTS.str.split('\|\|', expand=True)\
                  .stack(dropna=False), prefix='Part')\
  .sum(level=0))