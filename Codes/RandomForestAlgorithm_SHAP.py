#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
University of Chicago, 2023
Please cite the following article:
'Improved rate capability for dry thick electodes through finite elements
method and machine learning coupling', M.Chouchane et al. (2024)
"""


import numpy as np
import numpy.matlib
from os import listdir
from scipy.io import *
import pandas as pd

def k_fold(x,k,seed): #%% function to divide into k sub-datasets the dataset x, with the random seed seed
    temp = np.reshape(np.concatenate(x,0),np.shape(x))
    np.random.seed(seed)
    np.random.shuffle(temp)
    size_set = np.shape(temp)[0] ; 
    sub_size = int(np.floor(size_set/k))+1
    modulo = np.mod(size_set,k)
    Subset = {}
    for i in range (k-1):
        # print(i)
        # print(i*sub_size)
        # print(sub_size*(i+1))
        if i == modulo or (modulo==0 and i ==0):
            sub_size += -1
        if i<modulo:
            Subset[i] = temp[i*sub_size:sub_size*(i+1),:]
        else:
            Subset[i] = temp[i*sub_size+modulo:sub_size*(i+1)+modulo,:]
    Subset[k-1] = temp[-sub_size:,:]
    return Subset
#%% Convert the .mat files into .pkl Dataframe
dir_SOD = '/media/meng/Elements/LESC_2022_2024/COMSOl_ML/Python/Iso2Mesh/SoL/mat/150um/' # Location of the .mat dataset files 
dir_pkl = '/media/meng/Elements/LESC_2022_2024/COMSOl_ML/Python/Iso2Mesh/SoL/pkl/150um/'# Location where to save the .pkl dataframe files 
listdir_SOD = listdir(dir_SOD)
for i in range(1,len(listdir_SOD)+1):
            ID = listdir_SOD[i-1][0:2] # Get the first 2 characters of the pkl file to know the ID
            print(ID)
            SOD = loadmat(dir_SOD+listdir_SOD[i-1])
            dataSOD = SOD['tosave']
            dataset=pd.DataFrame({
                'AM Id':dataw[:,0],
                'Volume NMC':dataw[:,1],
                'Active Surface':dataw[:,2],
                'CBD Contact':dataw[:,3],
                'Thickness Position':dataw[:,6],
                'Tortuosity Electrolyte':dataw[:,5],
                'DoD':dataw[:,4],
                'SoD':dataw[:,7]
            })       
            dataset.to_pickle(dir_pkl+ID+'_SoD.pkl')  
#%% Import Custom database 
dir_pkl = '/media/meng/Elements/LESC_2022_2024/COMSOl_ML/Python/Iso2Mesh/SoL/pkl/150um/' # Location of the .pkl dataframe files
list_id = [1,2,3,4,5,6,7,8,9,10] # ID of the pkl files you want to import
objs = [] 
for i in list_id:
    ID = '0'+str(i)
    ID = ID[-2:]    
    data = pd.read_pickle(dir_pkl+ID+'_SoD.pkl')
    objs += [data]
dataset = pd.concat(objs,ignore_index=True)
#%%
"""
Optimization of the Random Forest algorithm
"""

from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn import metrics
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from sklearn.preprocessing import StandardScaler
# INPUTS ---------------
kfold = 10 # Apply the 10-fold approach
list_tree = [50,250,500]  # Number of trees to screen
list_branch = [2,3,4] # Maximal number of branches per tree to screen
list_seed = [0,10] # Randomization seeds to screen
# ----------------------
Data = dataset.iloc[:,:].values
sc = StandardScaler()
subData = k_fold(Data,kfold,0)
MAE = np.zeros([len(list_tree) ,len(list_branch),len(list_seed) ]) # Mean Average Error
RAE = np.zeros([len(list_tree) ,len(list_branch),len(list_seed) ]) # Relative Average Error
ct,cb,cs = 0,0,0
for t in list_tree:   # Loop through the number of trees
    print(t)
    for b in list_branch: # Loop through the number of branches
        print(b)
        temp_MAE = np.zeros([kfold,len(list_seed)])
        temp_RAE = np.zeros([kfold,len(list_seed)])
        for k in range(kfold):    # Applying the k-fold approach   
            selector = np.array([i for i in range(len(subData)) if i != k])
            X_test = subData[k][:,1:-1]
            y_test = subData[k][:,-1]
            X_train = subData[selector[0]][:,1:-1]
            y_train = subData[selector[0]][:,-1]
            for i in selector[1:]:
                X_train = np.concatenate((X_train,subData[i][:,1:-1]),0)
                y_train = np.concatenate((y_train,subData[i][:,-1]),0)
            X_train = sc.fit_transform(X_train)
            X_test = sc.transform(X_test)
            cs = 0
            for s in list_seed: # Loop through the number of seeds                      
                regressor = RandomForestRegressor(n_estimators=t, random_state=s,max_features = b)
                regressor.fit(X_train, y_train)
                y_pred = regressor.predict(X_test)    
                temp_MAE[k][cs] = metrics.mean_absolute_error(y_test, y_pred)
                temp_RAE[k][cs] = np.mean((abs(y_test-np.reshape(y_pred,np.shape(y_test)))/y_test))
                cs += 1
        mean_std = np.mean(np.std(temp_MAE,1))
        plt.scatter(y_test,y_pred)
        plt.plot(y_test,y_test)
        plt.show()
        MAE[ct][cb][:] = np.mean(temp_MAE,0)
        RAE[ct][cb][:] = np.mean(temp_RAE,0)
        cb += 1
    ct += 1
    cb = 0
plt.show()    
    
    
ind_min = np.argmin(MAE)
ind1 = ind_min // (len(list_branch)*len(list_seed))
temp = ind_min % (len(list_branch)*len(list_seed))
ind2 = temp // len(list_seed) 
ind3 = ind_min % len(list_seed)

print('Best Candidate with a mean average error of = ',MAE[ind1][ind2][ind3])
print('is ',list_tree[ind1], ' trees, with ',list_branch[ind2],'branches each, with seed =',list_seed[ind3])

meanp = np.min(RAE,2)
meanmae = np.min(MAE,2)

fig = plt.figure()
ax1 = fig.add_subplot(2, 2, 1)
im1 = ax1.imshow(meanmae,cmap='coolwarm_r')
plt.title("Mean Error SOD")
plt.xlabel('Max. #Features per Tree')
plt.ylabel('Number of Trees')
plt.xticks(ticks = range(len(list_branch)),labels=list_branch)
plt.yticks(ticks = range(len(list_tree)),labels=list_tree)
cbar = plt.colorbar(im1,cmap='cooltowarm')

ax2 = fig.add_subplot(2, 2, 2)
im2 = ax2.imshow(meanp,cmap='coolwarm_r')
plt.title("Relative Error SOD")
plt.xlabel('Max. #Features per Tree')
plt.ylabel('Number of Trees')
plt.xticks(ticks = range(len(list_branch)),labels=list_branch)
plt.yticks(ticks = range(len(list_tree)),labels=list_tree)
cbar = plt.colorbar(im2)
plt.subplots_adjust(left=0.125, bottom=0.1, right=0.9, top=0.9, wspace=0.5, hspace=0.7)
plt.show()
#%%
"""
Optimized Random Forest algorithm
"""
# INPUTS ---------------
kfold = 10 # Apply the 10-fold approach
list_tree = 500  # Number of trees to screen
list_branch = 4 # Maximal number of branches per tree to screen
list_seed = 10 # Randomization seeds to screen
# ----------------------
Data = dataset.iloc[:,:].values
sc = StandardScaler()
subData = k_fold(Data,kfold,0)
selector = np.array([i for i in range(len(subData)) if i != 1])
X_test = subData[1][:,1:-1]
y_test = subData[1][:,-1]
X_train = subData[selector[0]][:,1:-1]
y_train = subData[selector[0]][:,-1]
for i in selector[1:]:
    X_train = np.concatenate((X_train,subData[i][:,1:-1]),0)
    y_train = np.concatenate((y_train,subData[i][:,-1]),0)
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
regressor = RandomForestRegressor(n_estimators=list_tree, random_state=list_seed,max_features = list_branch)
regressor.fit(X_train, y_train)
y_pred = regressor.predict(X_test)    
               
#%%
"""
Visualization SHAP
"""
sns.color_palette('pastel')
lbl = ['NMC Particle Size',
'Active Surface Area',
'CBD Contact',
'Thickness position',
'Electrolyte Tortuosity',
'Depth of Discharge'
]
import shap as shap
X_shap = X_test
explainer = shap.TreeExplainer(regressor)
shap_values = explainer.shap_values(X_shap)
shap.summary_plot(shap_values, X_shap,feature_names=lbl)
