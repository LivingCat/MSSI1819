from factor_analyzer.factor_analyzer import calculate_bartlett_sphericity
from factor_analyzer.factor_analyzer import calculate_kmo
import pandas as pd
from sklearn.datasets import load_iris
from factor_analyzer import FactorAnalyzer
import matplotlib.pyplot as plt
import numpy

data = pd.read_csv('InqueritoRideSharingSemCelulasBrancas.csv', sep=';')
data.drop(['Numero Viagens', 'Ride Sharing Conceito'], axis=1, inplace=True)
# print(data.info)
########STEP 1########
#check to see if we can use factor analyze in our dataset
#kmo_all,kmo_model = calculate_kmo(data)
#chi_square_value, p_value = calculate_bartlett_sphericity(data)

########STEP 2########
# Create factor analysis object and perform factor analysis
# fa = FactorAnalyzer()
# fa.analyze(data, 21, rotation=None)
# Check Eigenvalues - we need 7 factors
# ev, v = fa.get_eigenvalues()

# Create scree plot using matplotlib
# plt.scatter(range(1, data.shape[1]+1), ev)
# plt.plot(range(1, data.shape[1]+1), ev)
# plt.title('Scree Plot')
# plt.xlabel('Factors')
# plt.ylabel('Eigenvalue')
# plt.grid()
# plt.show()


########STEP 3########
#Performing the factor analysis

cumulativeVariances = []
# Create factor analysis object and perform factor analysis
minFactor = 5;
maxFactor = 14;
fa = FactorAnalyzer()
for index in range(minFactor, maxFactor):
  fa.analyze(data, index, rotation="varimax")
  #print(fa.loadings)

  ########STEP 4########
  # print(fa.get_factor_variance())
  cumulativeVariances.append(
      fa.get_factor_variance().iloc[2]['Factor%d' % index])

xPoints = range(minFactor, maxFactor)
plt.scatter(xPoints, cumulativeVariances)
plt.plot(xPoints, cumulativeVariances)
plt.title('Cumulative Variance Dependent on Number of Factors')
plt.xlabel('Factors')
plt.ylabel('Cumulative Variance')
plt.grid()
plt.show()

########Step 5########
# #get new dataset with values for each factor
# fa = FactorAnalyzer(rotation="varimax",n_factors=8)
# fa.fit(data)
# result = fa.transform(data)
# numpy.savetxt("newDataset.csv",result,delimiter=";",fmt='%f')
# print(result)

# transformer = FactorAnalysis(n_components=7, random_state=0)
# X_transformed = transformer.fit_transform(data)
# X_transformed.shape
# print(X_transformed.shape)

##Tutorial followed: https://www.datacamp.com/community/tutorials/introduction-factor-analysis
