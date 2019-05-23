import matplotlib.pyplot as plt
import random
import numpy
import pandas as pd



def gamma_random_sample(mean, variance, size):
    """Yields a list of random numbers following a gamma distribution defined by mean and variance"""
    g_alpha = mean*mean/variance
    g_beta = mean/variance
    for i in range(size):
        yield numpy.random.gamma(g_alpha, 1./g_beta, 1)


print(gamma_random_sample(2, 2, 1))
# shape, scale = 20., 2.  # mean=4, std=2*sqrt(2)
# data = numpy.random.gamma(shape, scale, 10000)

data = pd.read_csv('InqueritoRideSharingSemCelulasBrancasClustersInicial.csv', sep=';')
n_clusters = range(8)
for cluster in n_clusters:
    filters = data[data.Cluster == cluster]
    columnStart = filters.loc[:, "Distancia trajeto"]

    mean_of_distribution = numpy.mean(columnStart)
    variance_of_distribution = numpy.var(columnStart)
    print(mean_of_distribution, variance_of_distribution ,"cluster " + str(cluster))
    grs = [float(i) for i in gamma_random_sample(
        mean_of_distribution, variance_of_distribution, len(columnStart))]
    plt.hist(columnStart, bins=20, histtype='stepfilled',
                        ls='dashed', lw=3, fc=(0, 0, 1, 0.5))
    plt.hist(grs, bins=11, histtype='stepfilled',
             ls='dotted', lw=3, fc=(0, 1, 0, 0.5))

    plt.title('Travel Distance Distribution vs Predicted Gamma Distribution - Cluster ' + str(cluster))
    plt.show()
    # numpy.savetxt("InqueritoInicialDescribe.csv", filters.describe(), delimiter=";", fmt='%f', )
    # print(data.describe())
    # with open('InqueritoInicialDescribe.csv', 'a') as f:
    #     filters.describe().to_csv(f)






# Fit gamma distribution through mean and average
# mean_of_distribution = numpy.mean(data)
# variance_of_distribution = numpy.var(data)


# # force integer values to get integer sample
# grs = [int(i) for i in gamma_random_sample(
#     mean_of_distribution, variance_of_distribution, len(data))]



# print("Original data: ", sorted(data))
# print("Random sample: ", sorted(grs))

# original = plt.hist(data, bins=20, histtype='stepfilled',ls='dashed', lw=3, fc=(0, 0, 1, 0.5))
# made = plt.hist(grs, bins=20, histtype='stepfilled', ls='dotted', lw=3, fc=(0, 1, 0, 0.5))
# # plt.legend([original, made], ['Original', 'Reconstructed'])

# plt.show()
