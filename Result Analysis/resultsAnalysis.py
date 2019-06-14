import pandas as pd

df = pd.read_csv('20Random.csv', skiprows=6,  sep=';',index_col=0)

print(df.filter(regex='^(1|1\..*)$'))