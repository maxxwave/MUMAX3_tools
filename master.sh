# author: Razvan Ababei
# This script will produce the files necesarry for classification by merging the mumax3 output files

for i in $(seq 1 1 1280)
	do 
	# in this step we gather all files in a single one
	tail -n 8 field.$i/task$i.out/table.txt|awk '{printf("%f\n", $2)}' >aicix
	tail -n 8 field.$i/task$i.out/table.txt|awk '{printf("%f\n", $9)}' >aiciy
	done 

# in this step we generate a file containing the magnetisation responses
# second column is the one corresponding to mx
xargs -n8 < aicix >xdata
head -n 640 xdata>trainx
tail -n 640 xdata>validatex
xargs -n8 < aiciy >ydata
head -n 640 ydata>trainy
tail -n 640 ydata>validatey


cat <-EOF > Classification.py
#!/bin/python
import numpy as np
#from numpy.linalg import inv
import csv
from numpy.linalg import inv 
from numpy.linalg import det 
f = open ( 'X_data' , 'r')
g = open ( 'Y_data' , 'r')
x = [8]
x = [ line.split() for line in f]
x=np.array(x).astype('float')
y= [8]
y= [ line.split() for line in g]
y= np.array(y).astype('float') 
#print (l) 
#print l
print 'valorule lui x'
#print x
print 'valorile lui x_t'
x_t = x.transpose()
#print x_t
l=np.matmul(x_t,x)
#print l       
l= np.add(l, 0.001*np.identity(len(l)))
d=det(l)
#print d
l=np.linalg.pinv(l)
#print l
y0=y[:,0]
print len(y0.transpose()) 
print y0
W=np.matmul(y0.transpose(),np.matmul(x,l))
print 'weights matrix'
print W
trainx = open ( 'xtrain_data' , 'r')
trainy = open ( 'ytrain_data' , 'r')
xtrain = [8]
xtrain = [ line.split() for line in trainx]
xtrain=np.array(xtrain).astype('float')
ytrain= [8]
ytrain= [ line.split() for line in trainy]
ytrain= np.array(ytrain).astype('float') 

ytrain=ytrain[:,0]
print len(xtrain)
count=0
for i in  range(len(xtrain)):

	y=np.matmul(W,xtrain[i])
	print y, ytrain[i]
	if y<0.5 and ytrain[i]==0:
		count+=1
	elif y>0.5 and ytrain[i]==1:
		count+=1
print count 
EOF

python Classification.py 
