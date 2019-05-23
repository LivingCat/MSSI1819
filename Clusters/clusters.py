from sklearn.cluster import KMeans
from sklearn.cluster import AgglomerativeClustering
from sklearn.cluster import Birch
import pandas as pd
from yellowbrick.cluster import SilhouetteVisualizer
from sklearn.metrics import silhouette_score
import matplotlib.pyplot as plt
import numpy

data = pd.read_csv('newDatasetWith9.csv', sep=';', header=None)
print(data)
# model = SilhouetteVisualizer(KMeans(n_clusters=8))
# model.fit(data)
# model.poof()

# iterations=30
# array = []
# for it in range(iterations):
#     range_n_clusters=range(2,15)
#     scores = []

#     for n_clusters in range_n_clusters:
#         clusterer = KMeans(n_clusters=n_clusters)
#         preds = clusterer.fit_predict(data)
#         print(preds)
#         # centers = clusterer.cluster_centers_
#         score = silhouette_score(data, preds, metric='euclidean')
#         scores.append(score)
#         # print("For n_clusters = {}, silhouette score is {})".format(n_clusters, score))
#     array.append(scores)
#     # plt.scatter(range_n_clusters, scores)
#     # plt.plot(range_n_clusters, scores)
#     # plt.title('Scree Plot')
#     # plt.xlabel('number of clusters')
#     # plt.ylabel('score mean')
#     # plt.grid()
#     # plt.show()

# master = []
# cena = len(array[0])
# for c in range(cena):
#     value = 0
#     for it in range(iterations):
#         value += array[it][c]
#     value = value/iterations
#     master.append(value)
    
# print(master)
# plt.scatter(range_n_clusters, master)
# plt.plot(range_n_clusters, master)
# plt.title('KMeans 30 iterations average score')
# plt.xlabel('Number of clusters')
# plt.ylabel('Score mean')
# plt.grid()
# plt.show()

clusterer = KMeans(n_clusters=8)
preds = clusterer.fit_predict(data)
score = silhouette_score(data, preds, metric='euclidean')
print(score)
data['Cluster'] = pd.Series(preds, index=data.index)
numpy.savetxt("newDatasetWithClusters.csv",data,delimiter=";",fmt='%f')
