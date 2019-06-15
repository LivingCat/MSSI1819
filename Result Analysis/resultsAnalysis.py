import csv
import pandas as pd

# inputs
reports = ["report-total-co-emissions", "report-number-riders", "report-num-cars-stopped", "report-mean-speed-cars",
           "report-average-wait-time-cars", "report-average-rider-score-group", "report-average-walking-turtle-score", "report-number-walking-turtles"]
number_runs = 120
number_clusters = 8
inputCSV = "./Runs/351People.csv"
csv_name = "results_351People.csv"


#outputs
number_persons = 0
infos_sum = {
    "number_people": 0,
    "Random": {
        "counter": 0,
        "report-total-co-emissions": 0,
        "report-number-riders": 0,
        "report-num-cars-stopped": 0,
        "report-mean-speed-cars": 0,
        "report-average-wait-time-cars": 0,
        "report-average-rider-score-group": 0,
        "report-average-walking-turtle-score": 0,
        "report-number-walking-turtles": 0
    },
    "Min Distance": {
        "counter": 0,
        "report-total-co-emissions": 0,
        "report-number-riders": 0,
        "report-num-cars-stopped": 0,
        "report-mean-speed-cars": 0,
        "report-average-wait-time-cars": 0,
        "report-average-rider-score-group": 0,
        "report-average-walking-turtle-score": 0,
        "report-number-walking-turtles": 0
    },
    "Best!": {
        "counter": 0,
        "report-total-co-emissions": 0,
        "report-number-riders": 0,
        "report-num-cars-stopped": 0,
        "report-mean-speed-cars": 0,
        "report-average-wait-time-cars": 0,
        "report-average-rider-score-group": 0,
        "report-average-walking-turtle-score": 0,
        "report-number-walking-turtles": 0
    }
}

df = pd.read_csv(inputCSV, skiprows=6,  sep=',',index_col=0)
for cluster_number in range(number_clusters):
    infos_sum["number_people"] += int(df.loc["cluster-{}".format(cluster_number)].iloc[0])

for index in range(1,number_runs + 1):
    run = df.filter(regex='^({}|{}\..*)$'.format(index,index))
    matching = run.loc["matching-algorythm", :].iloc[0]
    infos_sum[matching]["counter"] += 1
    reporters = run.loc['[reporter]', :]
    for report in reports:      
        column_score = pd.Index(reporters).get_loc(report)
        if report == "report-total-co-emissions" or report == "report-number-riders" or report == "report-total-co-emissions":
            infos_sum[matching][report] += float(run.loc["[max]"].iloc[column_score])
        else:
            infos_sum[matching][report] += float(run.loc["[mean]"].iloc[column_score])


for matching in infos_sum:
    counter = 0
    if(matching == "number_people"):
        continue
    for report in infos_sum[matching]:
        if(report == "counter"):
            counter = infos_sum[matching][report]
        else:
            if(counter != 0):
                infos_sum[matching][report] = infos_sum[matching][report]/counter

# infos_sum = {
#     "number_people": 0,
#     "Random": {
#         "counter": 0,
#         "report-total-co-emissions": 0,
#         "report-number-riders": 0,
#         "report-num-cars-stopped": 0,
#         "report-mean-speed-cars": 0,
#         "report-average-wait-time-cars": 0,
#         "report-average-rider-score-group": 0,
#         "report-average-walking-turtle-score": 0,
#         "report-number-walking-turtles": 0
#     },
#     "Min Distance": {
#         "counter": 0,
#         "report-total-co-emissions": 0,
#         "report-number-riders": 0,
#         "report-num-cars-stopped": 0,
#         "report-mean-speed-cars": 0,
#         "report-average-wait-time-cars": 0,
#         "report-average-rider-score-group": 0,
#         "report-average-walking-turtle-score": 0,
#         "report-number-walking-turtles": 0
#     },
#     "Best!": {
#         "counter": 0,
#         "report-total-co-emissions": 0,
#         "report-number-riders": 0,
#         "report-num-cars-stopped": 0,
#         "report-mean-speed-cars": 0,
#         "report-average-wait-time-cars": 0,
#         "report-average-rider-score-group": 0,
#         "report-average-walking-turtle-score": 0,
#         "report-number-walking-turtles": 0
#     }
# }
with open(csv_name, 'w') as f:
    for matching in infos_sum:
        if(matching == "number_people"):
            f.write("%s,%s\n" % (matching, infos_sum[matching]))
        else:
            for report in infos_sum[matching]:
                f.write("%s,%s\n" % (matching+report, infos_sum[matching][report]))
