import pandas as pd
import matplotlib.pyplot as plt

csv_name = 'total_results.csv'
matchings = ["Random", "Min Distance", "Best!"]

report_compare = "report-number-walking-turtles"


data = pd.read_csv(csv_name, sep=';', header=None, index_col=0)
number_people = data.loc["number_people", :].values
for mathing in matchings:
  plt.plot(number_people, data.loc[mathing+report_compare, :].values)

plt.legend(['Random', 'Min Distance', 'Real Life'], loc='upper left')
plt.title("Number of unmatched people")
plt.xlabel("Number of People")
plt.ylabel("Number of unmatched people")
plt.show()
