import numpy as np
import random
import matplotlib.pyplot as plt
walkers=20
NSteps=100
walks=[]
j=0
while j<=walkers:
    x=random.choices([-1,0,1],weights=(1/3,1/3,1/3),k=NSteps)
    nx=np.array(x)
    i=0
    y=0
    walk=[]
    while i<NSteps:
        y=y+nx[i]
        walk.append(y)
        i=i+1
    c=np.array(walk)
    walks.append(c)
    j=j+1
r=np.array(walks)
print(r)
#Functions corresponding to the standard deviation
def f1(x):
    return np.sqrt(2*x/3)
def f2(x):
    return -np.sqrt(2*x/3)
x=range(0,100)
plt.figure(figsize=(12,5))
plt.plot(r.T,'k')
plt.plot(x,[f1(i) for i in x],'r')
plt.plot(x,[f2(i) for i in x],'r')
plt.xlabel('Steps')
plt.ylabel('Position')
plt.show()