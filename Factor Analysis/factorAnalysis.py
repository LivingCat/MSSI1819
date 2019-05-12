from factor_analyzer.factor_analyzer import calculate_bartlett_sphericity
from factor_analyzer.factor_analyzer import calculate_kmo
import pandas as pd
from sklearn.datasets import load_iris
from factor_analyzer import FactorAnalyzer
import matplotlib.pyplot as plt
import numpy

data = pd.read_csv('InqueritoRideSharingComMedia.csv', sep=';')

########STEP 1########
#check to see if we can use factor analyze in our dataset
# kmo_all,kmo_model = calculate_kmo(data)
# chi_square_value, p_value = calculate_bartlett_sphericity(data)

########STEP 2########
# Create factor analysis object and perform factor analysis
# fa = FactorAnalyzer()
# fa.analyze(data, 23, rotation=None)
# Check Eigenvalues - we need 8 factors
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

# Create factor analysis object and perform factor analysis
# fa = FactorAnalyzer()
# fa.analyze(data, 8, rotation="varimax")
# print(fa.loadings)

#After checking the factor loadings we think that we only have 7 factors, so we need to calculate the factor loadings again
# Create factor analysis object and perform factor analysis using 7 factors
# fa = FactorAnalyzer()
# fa.analyze(data, 8, rotation="varimax")
# print(fa.loadings)

##Actually we think the 8 factors maybe were better

########STEP 4########
# print(fa.get_factor_variance())

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