import pandas as pd
import numpy
from matplotlib.pyplot import subplots, show, title

n_clusters = range(0,8)

# for cluster in n_clusters:
#     data = pd.read_csv('newDatasetWithClusters.csv', sep=';')
#     # data.query('Cluster == {cluster}')
#     filters=data[data.Cluster==cluster]
#     print("\n\n hello sou o cluster" + str(cluster))
#     print(filters.describe())
#     # print(data.describe())


for cluster in n_clusters:
    data = pd.read_csv('InqueritoRideSharingSemCelulasBrancasClustersInicial.csv', sep=';')
    # data.query('Cluster == {cluster}')
    filters=data[data.Cluster==cluster]
    # print("\n\n hello sou o cluster" + str(cluster))
    # print(filters.describe())
    filters.hist(column='Distancia trajeto')
    title('Travel Distance Distribution - Cluster ' + str(cluster))
    show()
    # numpy.savetxt("InqueritoInicialDescribe.csv", filters.describe(), delimiter=";", fmt='%f', )
    # print(data.describe())
    # with open('InqueritoInicialDescribe.csv', 'a') as f:
    #     filters.describe().to_csv(f)
