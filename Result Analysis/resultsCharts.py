import pandas as pd
import matplotlib.pyplot as plt

csv_name = 'total_results.csv'
matchings = ["Best!", "Random", "Min Distance", "None"]

# report-total-co-emissions
# report-number-riders
# report-num-cars-stopped
# report-mean-speed-cars
# report-average-wait-time-cars
# report-average-rider-score-group
# report-average-walking-turtle-score
# report-number-walking-turtles

report_compare = "report-number-walking-turtles"
title = "Number of unmatched people"
ylabel = "Number of unmatched people"

data = pd.read_csv(csv_name, sep=';', header=None, index_col=0)
number_people = data.loc["number_people", :].values
for mathing in matchings:
  plt.plot(number_people, data.loc[mathing+report_compare, :].values)

plt.legend(["Real life", "Random", "Min Distance", "None"], loc='upper left')
plt.title(title)
plt.ylabel(ylabel)
plt.xlabel("Number of People")
plt.show()
