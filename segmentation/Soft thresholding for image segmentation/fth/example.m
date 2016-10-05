%EXAMPLE OF USE WITH 3 DIFFERENT AGGREGATIONS

load phantom_circle.mat
I=abs(255.*If+(If>0).*filter2(ones(1)/1,30.*randn(size(If)))); 


%Number of sets;
Nth=3;
%Smooth
sm=1.5;

%Default use
B0=fth(I,Nth,[1,4],sm);  
%Max-Med 3x3 window
B1=fth(I,Nth,[0 3],sm);
%Mean
B2=fth(I,Nth,[2 5],sm); 

imagesc([B0 B1 B2])
