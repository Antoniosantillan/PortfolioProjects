#Library Import
import numpy as np
import re
import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
plt.style.use("ggplot")
from matplotlib.pyplot import figure
matplotlib.rcParams['figure.figsize']=(12,8)#-->Adjusting the size of the graphs
df=pd.read_csv("D:\Proyectos\movies_Clean.csv")#-->reading the document
######DATAFRAME INFORMATION#####
print(df)
print(df.shape)
print(df.dtypes)
# print(df.iloc[0][0])
#print(df.head(10))
#pd.set_option('display.max_rows',None)
#####DATA CLEANING#####
df["budget"]=df["budget"].astype("float")#-->Change data type
df["gross"]=df["gross"].astype("float")
#--Find missing values--#
print(df.isnull().sum())
for col in df.columns:
    Pct_missing=np.mean(df[col].isnull())
    print('{} - {}%'.format(col, Pct_missing*100))
df=df[df["budget"].notna()]
df=df[df["gross"].notna()]
#--Remove duplicates--#
#df['company']=df['company'].drop_duplicates()
def take_year(x):#-->Subtract and replace year values
    pattern=r'\b\d{4}\b'
    coincidences=re.findall(pattern,x)
    if coincidences:
        return coincidences[0]
    else:
        return None
df["year"]=df["released"].apply(take_year)
df.sort_values(by=['gross'],inplace=True,ascending=False)#-->Sort Data
#####INFORMATION CORRELATION#####
correlation_matrix1=df.corr(method='pearson',numeric_only=True)
df_numerized=df
for col_name in df_numerized:
    if(df_numerized[col_name].dtype=='object'):
        df_numerized[col_name]=df_numerized[col_name].astype('category')
        df_numerized[col_name]=df_numerized[col_name].cat.codes
correlation_matrix2=df_numerized.corr(method='pearson')
corr_pairs=df_numerized.corr().unstack()
sorted_pairs=corr_pairs.sort_values()
high_corr=sorted_pairs[(sorted_pairs>0.5) & (sorted_pairs<1.0)]
print(high_corr)
#####INFORMATION REPRESENTATION#####
plt.scatter(x=df["budget"],y=df["gross"])#-->Scatter plot
#sns.regplot(x='budget', y='gross',data=df, scatter_kws={"color":"red"},line_kws={"color":"blue"})#-->Scatter plot Function with regression line
#sns.heatmap(correlation_matrix1,annot=True)#--> Correlation Matrix for Numeric Features
#sns.heatmap(correlation_matrix2,annot=True)#--> Correlation Matric for Numeric Features in df_numerized
#plt.title("Correlation Values")
plt.title("Budget VS Gross Earnings")
plt.xlabel("Gross Earnigs")
plt.ylabel("Budget for film")
plt.show()