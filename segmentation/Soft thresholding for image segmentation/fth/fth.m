function [MG, S, TM, Nmax]=fth(I,Nth,method,smooth,OPTS)

%
% FTH  Fuzzy thresholding segmentation of 2D data
%
% V. 4.0 (Overwrites old SEG_fuzzy.m)
%
% Usage
%
%   MG=fch(I);
%   MG=fch(I,3,1,1.5);  
%
% INPUT
%		I input image (2D, double or uint8)
%       Nth: 	Number of output centroids
%		        (Default is the maximum posible)
%               =0 Default
%              
%
% OPTIONAL
%
%   method: fuzzy spatial aggregation method. Default = 1
%
%      MG = fth(I);
%         = fth(I,0,1);
%         = fth(I,0,[1,3]);
%
%           = 0 Maximum Median aggregation (3x3 window)
%           = [0 Ws] Maximum Median (WsxWs window)
%               MG=fth(I,0,[0 3]);
%           = 1 Recursive average with 3 iterations      (default)
%           = [1 N] Recursive average  with N iterations
%                MG=fth(I,0,[1 2]);
%           = 2 Average agregation (5x5 window)
%           = [2 Ws] Average agregation (WsxWs window)
%               MG=fth(I,0,[2 5]);           
%           = 3 Median Max. aggregation (3x3 window)
%           = [3 Ws] Median Max aggregation (WsxWs window)
%               MG=fth(I,0,[3 5]);
%           = 4 Absolute maximum aggregation
%
%   smooth: gaussian smoothing of data for centroid search (default)
%           =0 No smoothing
%           >0 smoothing. (sigma of the filter = smooth)
%               MG=fth(I,0,2,1.5);
%
%   OPTS:   for Nth=0, OPTS is a height threshold for centroid search
%              (default = 0.008, 0.8% of the total height) 
%               MG=fth(I,0,2,1.5,0.02);
%
%   OUTPUT
%       	
%	    MG:	    Output Thresholded image
%       S:      Output value based only on maximum (No aggregation)
%	    TM:	    Membership to each output set
%	    Nmax    Number of maxima in histogram
%               (Number of fuzzy sets)
%
% Implementation done up to Nth maxima in histogram output sets. 
% If histogram shows more than Nth maxima reduced to the top Nth. 
%
% Algorithm proposed in:
%
%       Santiago Aja-Fernández, Gonzalo Vegas-Sánchez-Ferrero, 
%       Miguel A. Martín Fernández, Soft thresholding for medical 
%       image segmentation, EMBC'2010, Buenos Aires, Sept. 2010.
%
% Modified and extended. (New version to be submitted to IEEE Tr. Image Proc)
%
%
% Santiago Aja-Fernandez (V1.0), Ariel Hernan Curiale (V4.0)
% LPI V4.0
% www.lpi.tel.uva.es/~santi
% sanaja@tel.uva.es
% LPI Valladolid, Spain
% Original: 06/05/2012, 
% V4.0 06/02/2014

if(~exist('Nth','var'))
    Nth = 0;
end
if(~exist('method','var'))
    MODE = 1;
    Niter=   3;
else
    if length(method)==2
        argum=method(2);
        MODE=method(1);
    else
         MODE=method;   
    end
end
if(~exist('smooth','var'))
    smooth=1.5;
end
if(~exist('OPTS','var'))
        TH=0.008;
else
   TH=OPTS;
end




I=double(I);


%1.- Signal preprocessing---------------------

if Nth==0 %Automatic maxima search
    Nth=maxima_search(I,TH);
    disp(['Number of centroids: ' num2str(Nth)])
end

%Normalization------------

S1=std(I(:));              
M1=mean(I(:));
Mw=max(I((I>(M1-2.*S1))&(I<(M1+2.*S1))));
I=I./Mw;

%Smoothing------------------

if smooth>0
    window = fspecial('gaussian', 11, 1.5);
    I2=filter2B(window,I);
else
    I2=I;
end


%2-Centroids extraction (clustering)

Med=fcm(I2(:),Nth,[2,100,1e-5,0]);    	
MaxX=max(I2(:));
MinX=min(I2(:));
Med=sort(Med);

%2. PTS membership functions---------------

for iNmax=1:Nth
    if iNmax==1 %First set
        a1=MinX;
        a2=MinX;
        a3=Med(1);
        a4=Med(2);
    elseif iNmax==Nth %Last set
        a1=Med(Nth-1);
        a2=Med(Nth);
        a3=MaxX;
        a4=MaxX;
    else 
        a1=Med(iNmax-1);
        a2=Med(iNmax);
        a3=Med(iNmax);
        a4=Med(iNmax+1);
    end
    
    %3. MF of the image I
    Aci=trapmf_mat(I,a1,a2,a3,a4);
    TM(:,:,iNmax)=Aci; 
end 
   
[Mx My Mz]=size(TM);


[Vx S]=max(TM,[],3);%AGREGRATION by MAX

  
if MODE==0              %0-Max Median aggregation
    if (exist('argum','var'))
        Ws=argum;
    else
        Ws=3;
    end
    MG=medfilt2(S,[Ws,Ws]);
    Nmax=max(S(:));
elseif MODE==1          %1- Recursive average
    h=[0 1 0; 1 1 1; 0 1 0]./5;
        %h=[0 0.5 0; 0.5 1 0.5; 0 0.5 0]./3;       
        %h=ones(3)./9;
    if (exist('argum','var'))
        Nr=max(argum-1,0);
    else
        Nr=2;
    end
        for ii=1:Mz 
            TM2(:,:,ii)=filter2B(h,TM(:,:,ii));      
        end %end FOR
        for rep=1:Nr
        for ii=1:Mz 
            TM2(:,:,ii)=filter2B(h,TM2(:,:,ii));      
        end %end FOR
        end
        [Vx MG]=max(TM2,[],3);       
      
elseif MODE==2          %2-Average aggregation
    if (exist('argum','var'))
        Ws=argum;
    else
        Ws=5;
    end
    h=ones([Ws,Ws])./Ws.^2;
    for ii=1:Mz 
        TM2(:,:,ii)=filter2B(h,TM(:,:,ii));      
    end 
    [Vx MG]=max(TM2,[],3);
    
elseif MODE==3          %3-Median-max aggregation
    if (exist('argum','var'))
        Ws=argum;
    else
        Ws=3;
    end
    for ii=1:Mz
       TM2(:,:,ii)=medfilt2(TM(:,:,ii),[Ws,Ws]);    
    end
    [Vx MG]=max(TM2,[],3);  
elseif MODE==4         %4-Absolute max aggregation
    for ii=1:Mz
        Q1=TM(:,:,ii);
        id=0;
        for jj=-1:1:1
            M_tmp = shiftmat(Q1,jj,1);
            for kk=-1:1:1
                id = id+1;
                S2(:,:,id) = shiftmat(M_tmp,kk,2);
            end
        end 
        Mod(:,:,ii)=max(S2,[],3);
      end
      [Vx MG]=max(Mod,[],3); 

  
else
    error('Option not valid')
end %MODE

%Correct any possible side effect of median operator
MG=MG.*(MG>0)+(MG==0);
