function [Iout,intensity,fitness,time]=segmentation(I,level,method)
tic;
% segmentation - MatLab function for Multiple Image Segmentation using PSO
% (Particle Swarm Optimization), DPSO (Darwinian PSO), FO-DPSO (Fractional-Order 
% DPSO) and exhaustive methods based on the image histogram shape. 
% (The exhaustive method is still in development)
%
% Iout = segmentation(I)
% Iout - segmented image.
% I - any type of image with multiple intensity levels(e.g., grayscale,
% color).
%
% [Iout,intensity] = segmentation(I)
% intensity - returns the intensity that maximizes the between-class
% variance. size(intensity)=[size(I,3) level].
%
% [Iout,intensity,fitness] = segmentation(I)
% fitness - returns the fitness of the between-class variance. 
% size(fitness)=[size(I,3) 1]
%
% [Iout,intensity,fitness,time] = segmentation(I)
% time - returns the CPU computation time
% size(time)=[1 1]
%
% [Iout,intensity] = segmentation(I,level)
% level - segmentation level. Must be integer ... (Default 2). If level>2
% then the segmented image Iout will be an RGB image.
%
% [Iout,intensity] = segmentation(I,level,method)
% method - choose the method to perform the multi-segmentation of the
% image. The pso, dpso and exhaustive are the only ones implemented yet. (Default
% pso).
% ...
% 
% Example:  Iout = segmentation(I,4,'pso')
%
% Micael S. Couceiro & J. Miguel A. Luz
% v4.0
% Created 15/11/2010
% Last Update 16/01/2012

if (nargin<2)   %didn't choose level and method
    level=2;
    method='pso';
end
if (nargin<3)   %didn't choose method
    method='pso';
end

if size(I,3)==1 %grayscale image
    [n_countR,x_valueR] = imhist(I(:,:,1));
elseif size(I,3)==3 %RGB image
    [n_countR,x_valueR] = imhist(I(:,:,1));
    [n_countG,x_valueG] = imhist(I(:,:,2));
    [n_countB,x_valueB] = imhist(I(:,:,3));
end

Nt=size(I,1)*size(I,2);
Lmax=256;   %256 different maximum levels are considered in an image (i.e., 0 to 255)

for i=1:Lmax
    if size(I,3)==1 %grayscale image
        probR(i)=n_countR(i)/Nt;
    elseif size(I,3)==3 %RGB image    
        probR(i)=n_countR(i)/Nt;
        probG(i)=n_countG(i)/Nt;
        probB(i)=n_countB(i)/Nt;
    end
end

if strcmpi(method,'pso') %PSO method

    N = 150; %predefined PSO population for multi-segmentation

    N_PAR = level-1;  %number of thresholds (number of levels-1)

    N_GER = 150; %number of iterations of the PSO algorithm

    PHI1 = 0.8;  %individual weight of particles
    PHI2 = 0.8;  %social weight of particles
    W = 1.2;   %inertial factor

    vmin=-5;
    vmax=5;
    
    if size(I,3)==1 %grayscale image
        vR=zeros(N,N_PAR);  %velocities of particles
        X_MAXR = Lmax*ones(1,N_PAR);
        X_MINR = ones(1,N_PAR);
        gBestR = zeros(1,N_PAR);
        gbestvalueR = -10000;
        gauxR = ones(N,1);
        xBestR=zeros(N,N_PAR);
        fitBestR=zeros(N,1);
        fitR = zeros(N,1);
        xR = zeros(N,N_PAR);
        for i = 1: N
            for j = 1: N_PAR
                xR(i,j) = fix(rand(1,1) * ( X_MAXR(j)-X_MINR(j) ) + X_MINR(j));
            end
        end
        for si=1:length(xR)
           xR(si,:)=sort(xR(si,:)); 
        end
    elseif size(I,3)==3 %RGB image    
        vR=zeros(N,N_PAR);  %velocities of particles
        vG=zeros(N,N_PAR);
        vB=zeros(N,N_PAR);
        X_MAXR = Lmax*ones(1,N_PAR);
        X_MINR = ones(1,N_PAR);
        X_MAXG = Lmax*ones(1,N_PAR);
        X_MING = ones(1,N_PAR);
        X_MAXB = Lmax*ones(1,N_PAR);
        X_MINB = ones(1,N_PAR);
        gBestR = zeros(1,N_PAR);
        gbestvalueR = -10000;
        gauxR = ones(N,1);
        xBestR=zeros(N,N_PAR);
        fitBestR=zeros(N,1);
        fitR = zeros(N,1);
        gBestG = zeros(1,N_PAR);
        gbestvalueG = -10000;
        gauxG = ones(N,1);
        xBestG=zeros(N,N_PAR);
        fitBestG=zeros(N,1);
        fitG = zeros(N,1);
        gBestB = zeros(1,N_PAR);
        gbestvalueB = -10000;
        gauxB = ones(N,1);
        xBestB=zeros(N,N_PAR);
        fitBestB=zeros(N,1);
        fitB = zeros(N,1);
        xR = zeros(N,N_PAR);
        for i = 1: N
            for j = 1: N_PAR
                xR(i,j) = fix(rand(1,1) * ( X_MAXR(j)-X_MINR(j) ) + X_MINR(j));
            end
        end
        xG = zeros(N,N_PAR);
        for i = 1: N
            for j = 1: N_PAR
                xG(i,j) = fix(rand(1,1) * ( X_MAXG(j)-X_MING(j) ) + X_MING(j));
            end
        end
        xB = zeros(N,N_PAR);
        for i = 1: N
            for j = 1: N_PAR
                xB(i,j) = fix(rand(1,1) * ( X_MAXB(j)-X_MINB(j) ) + X_MINB(j));
            end
        end
        for si=1:length(xR)
           xR(si,:)=sort(xR(si,:)); 
        end
        for si=1:length(xG)
           xG(si,:)=sort(xG(si,:));
        end
        for si=1:length(xB)
           xB(si,:)=sort(xB(si,:)); 
        end
    end
    
    nger=1;

    for j=1:N
        if size(I,3)==1 %grayscale image
            fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
            end
            fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
            fitBestR(j)=fitR(j);
        elseif size(I,3)==3 %RGB image
            fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
            end
            fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
            fitBestR(j)=fitR(j);
            fitG(j)=sum(probG(1:xG(j,1)))*(sum((1:xG(j,1)).*probG(1:xG(j,1))/sum(probG(1:xG(j,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitG(j)=fitG(j)+sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel)))*(sum((xG(j,jlevel-1)+1:xG(j,jlevel)).*probG(xG(j,jlevel-1)+1:xG(j,jlevel))/sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
            end
            fitG(j)=fitG(j)+sum(probG(xG(j,level-1)+1:Lmax))*(sum((xG(j,level-1)+1:Lmax).*probG(xG(j,level-1)+1:Lmax)/sum(probG(xG(j,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
            fitBestG(j)=fitG(j);
            fitB(j)=sum(probB(1:xB(j,1)))*(sum((1:xB(j,1)).*probB(1:xB(j,1))/sum(probB(1:xB(j,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitB(j)=fitB(j)+sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel)))*(sum((xB(j,jlevel-1)+1:xB(j,jlevel)).*probB(xB(j,jlevel-1)+1:xB(j,jlevel))/sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
            end
            fitB(j)=fitB(j)+sum(probB(xB(j,level-1)+1:Lmax))*(sum((xB(j,level-1)+1:Lmax).*probB(xB(j,level-1)+1:Lmax)/sum(probB(xB(j,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
            fitBestB(j)=fitB(j);
        end
    end

    if size(I,3)==1 %grayscale image
        [aR,bR]=max(fitR);
        gBestR=xR(bR,:);
        gbestvalueR = fitR(bR);
        xBestR = xR;
    elseif size(I,3)==3 %RGB image
        [aR,bR]=max(fitR);
        gBestR=xR(bR,:);
        gbestvalueR = fitR(bR);
        [aG,bG]=max(fitG);
        gBestG=xG(bG,:);
        gbestvalueG = fitG(bG);
        [aB,bB]=max(fitB);
        gBestB=xR(bB,:);
        gbestvalueB = fitB(bB);
        xBestR = xR;
        xBestG = xG;
        xBestB = xB;
    end
    
    while(nger<=N_GER)
        i=1;
        
        randnum1 = rand ([N, N_PAR]);
        randnum2 = rand ([N, N_PAR]);
    
        if size(I,3)==1 %grayscale image
            vR = fix(W.*vR + randnum1.*(PHI1.*(xBestR-xR)) + randnum2.*(PHI2.*(gauxR*gBestR-xR)));
            vR = ( (vR <= vmin).*vmin ) + ( (vR > vmin).*vR );
            vR = ( (vR >= vmax).*vmax ) + ( (vR < vmax).*vR );
            xR = xR+vR;
        elseif size(I,3)==3 %RGB image    
            vR = fix(W.*vR + randnum1.*(PHI1.*(xBestR-xR)) + randnum2.*(PHI2.*(gauxR*gBestR-xR)));
            vR = ( (vR <= vmin).*vmin ) + ( (vR > vmin).*vR );
            vR = ( (vR >= vmax).*vmax ) + ( (vR < vmax).*vR );
            xR = xR+vR;
            vG = fix(W.*vG + randnum1.*(PHI1.*(xBestG-xG)) + randnum2.*(PHI2.*(gauxG*gBestG-xG)));
            vG = ( (vG <= vmin).*vmin ) + ( (vG > vmin).*vG );
            vG = ( (vG >= vmax).*vmax ) + ( (vG < vmax).*vG );
            xG = xG+vG;
            vB = fix(W.*vB + randnum1.*(PHI1.*(xBestB-xB)) + randnum2.*(PHI2.*(gauxB*gBestB-xB)));
            vB = ( (vB <= vmin).*vmin ) + ( (vB > vmin).*vB );
            vB = ( (vB >= vmax).*vmax ) + ( (vB < vmax).*vB );        
            xB = xB+vB;
        end
        
        if size(I,3)==1 %grayscale image
            xR = ( (xR <= X_MINR(1)).*X_MINR(1) ) + ( (xR > X_MINR(1)).*xR );
            xR = ( (xR >= X_MAXR(1)).*X_MAXR(1) ) + ( (xR < X_MAXR(1)).*xR );
        elseif size(I,3)==3 %RGB image  
            xR = ( (xR <= X_MINR(1)).*X_MINR(1) ) + ( (xR > X_MINR(1)).*xR );
            xR = ( (xR >= X_MAXR(1)).*X_MAXR(1) ) + ( (xR < X_MAXR(1)).*xR );
            xG = ( (xG <= X_MING(1)).*X_MING(1) ) + ( (xG > X_MING(1)).*xG );
            xG = ( (xG >= X_MAXG(1)).*X_MAXG(1) ) + ( (xG < X_MAXG(1)).*xG );
            xB = ( (xB <= X_MINB(1)).*X_MINB(1) ) + ( (xB > X_MINB(1)).*xB );
            xB = ( (xB >= X_MAXB(1)).*X_MAXB(1) ) + ( (xB < X_MAXB(1)).*xB );
        end
            

        for j = 1:N
            for k = 1:N_PAR
                if size(I,3)==1 %grayscale image
                    if (k==1)&&(k~=N_PAR)
                        if xR(j,k) < X_MINR(k)
                            xR(j,k) = X_MINR(k);
                        elseif xR(j,k) > xR(j,k+1)
                            xR(j,k) = xR(j,k+1);
                        end
                    end
                    if ((k>1)&&(k<N_PAR))
                        if xR(j,k) < xR(j,k-1)
                            xR(j,k) = xR(j,k-1);
                        elseif xR(j,k) > xR(j,k+1)
                            xR(j,k) = xR(j,k+1);
                        end
                    end
                    if (k==N_PAR)&&(k~=1)
                        if xR(j,k) < xR(j,k-1)
                            xR(j,k) = xR(j,k-1);
                        elseif xR(j,k) > X_MAXR(k)
                            xR(j,k) = X_MAXR(k);
                        end
                    end
                    if (k==1)&&(k==N_PAR)
                        if xR(j,k) < X_MINR(k)
                            xR(j,k) = X_MINR(k);
                        elseif xR(j,k) > X_MAXR(k)
                            xR(j,k) = X_MAXR(k);
                        end
                    end
                elseif size(I,3)==3 %RGB image     
                    if (k==1)&&(k~=N_PAR)
                        if xR(j,k) < X_MINR(k)
                            xR(j,k) = X_MINR(k);
                        elseif xR(j,k) > xR(j,k+1)
                            xR(j,k) = xR(j,k+1);
                        end
                    end
                    if ((k>1)&&(k<N_PAR))
                        if xR(j,k) < xR(j,k-1)
                            xR(j,k) = xR(j,k-1);
                        elseif xR(j,k) > xR(j,k+1)
                            xR(j,k) = xR(j,k+1);
                        end
                    end
                    if (k==N_PAR)&&(k~=1)
                        if xR(j,k) < xR(j,k-1)
                            xR(j,k) = xR(j,k-1);
                        elseif xR(j,k) > X_MAXR(k)
                            xR(j,k) = X_MAXR(k);
                        end
                    end
                    if (k==1)&&(k==N_PAR)
                        if xR(j,k) < X_MINR(k)
                            xR(j,k) = X_MINR(k);
                        elseif xR(j,k) > X_MAXR(k)
                            xR(j,k) = X_MAXR(k);
                        end
                    end
                    if (k==1)&&(k~=N_PAR)
                        if xG(j,k) < X_MING(k)
                            xG(j,k) = X_MING(k);
                        elseif xG(j,k) > xG(j,k+1)
                            xG(j,k) = xG(j,k+1);
                            %                         disp ('passou o max');
                        end
                    end
                    if ((k>1)&&(k<N_PAR))
                        if xG(j,k) < xG(j,k-1)
                            xG(j,k) = xG(j,k-1);
                            %                         disp ('passou o min');
                        elseif xG(j,k) > xG(j,k+1)
                            xG(j,k) = xG(j,k+1);
                            %                         disp ('passou o max');
                        end
                    end
                    if (k==N_PAR)&&(k~=1)
                        if xG(j,k) < xG(j,k-1)
                            xG(j,k) = xG(j,k-1);
                            %                         disp ('passou o min');
                        elseif xG(j,k) > X_MAXG(k)
                            xG(j,k) = X_MAXG(k);
                            %                         disp ('passou o max');
                        end
                    end
                    if (k==1)&&(k==N_PAR)
                        if xG(j,k) < X_MING(k)
                            xG(j,k) = X_MING(k);
                        elseif xG(j,k) > X_MAXG(k)
                            xG(j,k) = X_MAXG(k);
                        end
                    end
                    if (k==1)&&(k~=N_PAR)
                        if xB(j,k) < X_MINB(k)
                            xB(j,k) = X_MINB(k);
                            %                         disp ('passou o min');
                        elseif xB(j,k) > xB(j,k+1)
                            xB(j,k) = xB(j,k+1);
                            %                         disp ('passou o max');
                        end
                    end
                    if ((k>1)&&(k<N_PAR))
                        if xB(j,k) < xB(j,k-1)
                            xB(j,k) = xB(j,k-1);
                            %                         disp ('passou o min');
                        elseif xB(j,k) > xB(j,k+1)
                            xB(j,k) = xB(j,k+1);
                            %                         disp ('passou o max');
                        end
                    end
                    if (k==N_PAR)&&(k~=1)
                        if xB(j,k) < xB(j,k-1)
                            xB(j,k) = xB(j,k-1);
                            %                         disp ('passou o min');
                        elseif xB(j,k) > X_MAXB(k)
                            xB(j,k) = X_MAXB(k);
                            %                         disp ('passou o max');
                        end
                    end
                    if (k==1)&&(k==N_PAR)
                        if xB(j,k) < X_MINB(k)
                            xB(j,k) = X_MINB(k);
                        elseif xB(j,k) > X_MAXB(k)
                            xB(j,k) = X_MAXB(k);
                        end
                    end
                end
            end
        end

        while(i<=N)
            if(i==N)
                for j=1:N
                    if size(I,3)==1 %grayscale image
                        fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        if fitR(j) > fitBestR(j)
                            fitBestR(j) = fitR(j);
                            xBestR(j,:) = xR(j,:);
                        end
                    elseif size(I,3)==3 %RGB image
                        fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            
                            fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        fitG(j)=sum(probG(1:xG(j,1)))*(sum((1:xG(j,1)).*probG(1:xG(j,1))/sum(probG(1:xG(j,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fitG(j)=fitG(j)+sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel)))*(sum((xG(j,jlevel-1)+1:xG(j,jlevel)).*probG(xG(j,jlevel-1)+1:xG(j,jlevel))/sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        end
                        fitG(j)=fitG(j)+sum(probG(xG(j,level-1)+1:Lmax))*(sum((xG(j,level-1)+1:Lmax).*probG(xG(j,level-1)+1:Lmax)/sum(probG(xG(j,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        fitB(j)=sum(probB(1:xB(j,1)))*(sum((1:xB(j,1)).*probB(1:xB(j,1))/sum(probB(1:xB(j,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            
                            fitB(j)=fitB(j)+sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel)))*(sum((xB(j,jlevel-1)+1:xB(j,jlevel)).*probB(xB(j,jlevel-1)+1:xB(j,jlevel))/sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        end
                        fitB(j)=fitB(j)+sum(probB(xB(j,level-1)+1:Lmax))*(sum((xB(j,level-1)+1:Lmax).*probB(xB(j,level-1)+1:Lmax)/sum(probB(xB(j,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        if fitR(j) > fitBestR(j)
                            fitBestR(j) = fitR(j);
                            xBestR(j,:) = xR(j,:);
                        end
                        if fitG(j) > fitBestG(j)
                            fitBestG(j) = fitG(j);
                            xBestG(j,:) = xG(j,:);
                        end
                        if fitB(j) > fitBestB(j)
                            fitBestB(j) = fitB(j);
                            xBestB(j,:) = xB(j,:);
                        end
                    end
                end
                
                if size(I,3)==1 %grayscale image
                    [aR,bR] = max (fitR);
                    if (fitR(bR) > gbestvalueR)
                        gBestR=xR(bR,:)-1;
                        gbestvalueR = fitR(bR);
                    end
                elseif size(I,3)==3 %RGB image
                    [aR,bR] = max (fitR);
                    [aG,bG] = max (fitG);
                    [aB,bB] = max (fitB);
                    if (fitR(bR) > gbestvalueR)
                        gBestR=xR(bR,:)-1;
                        gbestvalueR = fitR(bR);
                    end
                    if (fitG(bG) > gbestvalueG)
                        gBestG=xG(bG,:)-1;
                        gbestvalueG = fitG(bG);
                    end
                    if (fitB(bB) > gbestvalueB)
                        gBestB=xB(bB,:)-1;
                        gbestvalueB = fitB(bB);
                    end
                end
                nger=nger+1;
            end
            i=i+1;
        end
    end
%     gbestvalueR
end

if strcmpi(method,'dpso') %DPSO method
    
    N = 30;          % current population of the swarm
    MIN_POP = 10;    % minimum population
    MAX_POP = 50;   % maximum population
    POP_INICIAL = N; % population from new swarms
    
    N_SWARMS = 4;
    N_SWARMSR = N_SWARMS;      % current number of swarms
    N_SWARMSG = N_SWARMS;      % current number of swarms
    N_SWARMSB = N_SWARMS;      % current number of swarms
    
    MIN_SWARMS = 2;     % minimum number of swarms
    MAX_SWARMS = 6;   % maximum number of swarms
    
    STAGNANCY = 10;      % maximum number of iterations without improving
    
    N_PAR = level-1;      %number of thresholds (number of levels-1)
    N_GER = 150;    %number of iterations of the PSO algorithm
    
    % weights:
    PHI1 = 0.8;  %individual weight of particles
    PHI2 = 0.8;  %social weight of particles
    W = 1.2;   %inertial factor
    
    vmin=-1.5;          % Velocidade Máxima por iteração
    vmax=1.5;           % Velocidade Mínima por iteração
    
    if size(I,3)==1 %grayscale image
        vR=zeros(N*N_SWARMS,N_PAR);  %velocities of particles
        X_MAXR = Lmax*ones(1,N_PAR);
        X_MINR = ones(1,N_PAR);
        gBestR = zeros(N_SWARMS,N_PAR);
        gbestvalueR = -1000*ones(N_SWARMS,1);
        gauxR = ones(N*N_SWARMS,1);
        xBestR=zeros(N*N_SWARMS,N_PAR);
        fitBestR=zeros(N*N_SWARMS,1);
        fitR = zeros(N*N_SWARMS,1);
        xR = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xR(i,j) = fix(rand(1,1) * ( X_MAXR(j)-X_MINR(j) ) + X_MINR(j));
            end
        end
        for si=1:length(xR)
           xR(si,:)=sort(xR(si,:)); 
        end
    elseif size(I,3)==3 %RGB image    
        vR=zeros(N*N_SWARMS,N_PAR);  %velocities of particles
        vG=zeros(N*N_SWARMS,N_PAR);
        vB=zeros(N*N_SWARMS,N_PAR);
        X_MAXR = Lmax*ones(1,N_PAR);
        X_MINR = ones(1,N_PAR);
        X_MAXG = Lmax*ones(1,N_PAR);
        X_MING = ones(1,N_PAR);
        X_MAXB = Lmax*ones(1,N_PAR);
        X_MINB = ones(1,N_PAR);
        gBestR = zeros(N_SWARMS,N_PAR);
        gbestvalueR = -1000*ones(N_SWARMS,1);
        gauxR = ones(N*N_SWARMS,1);
        xBestR=zeros(N*N_SWARMS,N_PAR);
        fitBestR=zeros(N*N_SWARMS,1);
        fitR = zeros(N*N_SWARMS,1);
        gBestG = zeros(N_SWARMS,N_PAR);
        gbestvalueG = -1000*ones(N_SWARMS,1);
        gauxG = ones(N*N_SWARMS,1);
        xBestG=zeros(N*N_SWARMS,N_PAR);
        fitBestG=zeros(N*N_SWARMS,1);
        fitG = zeros(N*N_SWARMS,1);
        gBestB = zeros(N_SWARMS,N_PAR);
        gbestvalueB = -1000*ones(N_SWARMS,1);
        gauxB = ones(N*N_SWARMS,1);
        xBestB=zeros(N*N_SWARMS,N_PAR);
        fitBestB=zeros(N*N_SWARMS,1);
        fitB = zeros(N*N_SWARMS,1);
        xR = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xR(i,j) = fix(rand(1,1) * ( X_MAXR(j)-X_MINR(j) ) + X_MINR(j));
            end
        end
        xG = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xG(i,j) = fix(rand(1,1) * ( X_MAXG(j)-X_MING(j) ) + X_MING(j));
            end
        end
        xB = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xB(i,j) = fix(rand(1,1) * ( X_MAXB(j)-X_MINB(j) ) + X_MINB(j));
            end
        end
        for si=1:length(xR)
           xR(si,:)=sort(xR(si,:)); 
        end
        for si=1:length(xG)
           xG(si,:)=sort(xG(si,:));
        end
        for si=1:length(xB)
           xB(si,:)=sort(xB(si,:)); 
        end
    end
    
    nger=1;

    for j=1:N*N_SWARMS
        if size(I,3)==1 %grayscale image
            fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
            end
            fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
            fitBestR(j)=fitR(j);
        elseif size(I,3)==3 %RGB image
            fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
            end
            fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
            fitBestR(j)=fitR(j);
            fitG(j)=sum(probG(1:xG(j,1)))*(sum((1:xG(j,1)).*probG(1:xG(j,1))/sum(probG(1:xG(j,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitG(j)=fitG(j)+sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel)))*(sum((xG(j,jlevel-1)+1:xG(j,jlevel)).*probG(xG(j,jlevel-1)+1:xG(j,jlevel))/sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
            end
            fitG(j)=fitG(j)+sum(probG(xG(j,level-1)+1:Lmax))*(sum((xG(j,level-1)+1:Lmax).*probG(xG(j,level-1)+1:Lmax)/sum(probG(xG(j,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
            fitBestG(j)=fitG(j);
            fitB(j)=sum(probB(1:xB(j,1)))*(sum((1:xB(j,1)).*probB(1:xB(j,1))/sum(probB(1:xB(j,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitB(j)=fitB(j)+sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel)))*(sum((xB(j,jlevel-1)+1:xB(j,jlevel)).*probB(xB(j,jlevel-1)+1:xB(j,jlevel))/sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
            end
            fitB(j)=fitB(j)+sum(probB(xB(j,level-1)+1:Lmax))*(sum((xB(j,level-1)+1:Lmax).*probB(xB(j,level-1)+1:Lmax)/sum(probB(xB(j,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
            fitBestB(j)=fitB(j);
        end
    end

    if size(I,3)==1 %grayscale image
        for i=1:N_SWARMS            % global best of each swarm and best fit of the DPSO
            
            k=i*N;      % end of swarm i
            j=k-N+1;    % start of swarm i
            
            [aR,bR]=max(fitR(j:k,:));
            
            gBestR(i,:)=xR(j-1+bR,:);
            gbestvalueR(i,1)= fitR(j-1+bR);
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(fitR);
            end
        end
        xBestR = xR;
    elseif size(I,3)==3 %RGB image
        for i=1:N_SWARMS            % global best of each swarm and best fit of the DPSO
            
            k=i*N;      % end of swarm i
            j=k-N+1;    % start of swarm i
            
            [aR,bR]=max(fitR(j:k,:));
            
            gBestR(i,:)=xR(j-1+bR,:);
            gbestvalueR(i,1)= fitR(j-1+bR);
            
            xBestR = xR;
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(fitR);
            end
            
            [aG,bG]=max(fitG(j:k,:));
            
            gBestG(i,:)=xG(j-1+bG,:);
            gbestvalueG(i,1)= fitG(j-1+bG);
            
            xBestG = xG;
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOG,i_gbestvalue_DPSOG]=max(fitG);
            end
            
            [aB,bB]=max(fitB(j:k,:));
            
            gBestB(i,:)=xB(j-1+bB,:);
            gbestvalueB(i,1)= fitB(j-1+bB);
            
            xBestB = xB;
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOB,i_gbestvalue_DPSOB]=max(fitB);
            end
        end
        xBestR = xR;
        xBestG = xG;
        xBestB = xB;
    end
        
    % N change depending on the swarm and the color component
    NR(1:N_SWARMSR,1)=N;
    NG(1:N_SWARMSG,1)=N;
    NB(1:N_SWARMSB,1)=N;
    
    %stagancy of each swarm
    stagnancy_counterR=zeros(N_SWARMSR,1);
    stagnancy_counterG=zeros(N_SWARMSG,1);
    stagnancy_counterB=zeros(N_SWARMSB,1);
    
    %number of particles deleted
    already_deletedR=zeros(N_SWARMSR,1);
    already_deletedG=zeros(N_SWARMSG,1);
    already_deletedB=zeros(N_SWARMSB,1);
    
    nger=1;                 % current iteration
    
    while(nger<=N_GER)
        
        i=1;
        while ((i<=max([N_SWARMSR,N_SWARMSG, N_SWARMSB])))
           
            if (i<=N_SWARMSR)
                kR=(sum(NR(1:i)));              % end of swarm i R
                jR=kR-NR(i)+1;                   % start of swarm i R
            end
            
            if (i<=N_SWARMSG)
                kG=(sum(NG(1:i)));              % end of swarm i G 
                jG=kG-NG(i)+1;                   % start of swarm i G
            end
            
            if (i<=N_SWARMSB)
                kB=(sum(NB(1:i)));              % end of swarm i B
                jB=kB-NB(i)+1;                   % start of swarm i B
            end
            
            % current swarm
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    v_swarmR = vR(jR:kR,:);
                    gBest_swarmR = gBestR(i,:);
                    gbestvalue_swarmR = gbestvalueR(i,1);
                    x_swarmR = xR(jR:kR,:);
                    xBest_swarmR = xBestR(jR:kR,:);
                    fit_swarmR = fitR(jR:kR,:);
                    fitBest_swarmR = fitBestR(jR:kR,:);
                    gaux_swarmR = ones(NR(i),1);
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    v_swarmR = vR(jR:kR,:);
                    gBest_swarmR = gBestR(i,:);
                    gbestvalue_swarmR = gbestvalueR(i,1);
                    x_swarmR = xR(jR:kR,:);
                    xBest_swarmR = xBestR(jR:kR,:);
                    fit_swarmR = fitR(jR:kR,:);
                    fitBest_swarmR = fitBestR(jR:kR,:);
                    gaux_swarmR = ones(NR(i),1);
                end
                
                if (i<=N_SWARMSG)
                    v_swarmG = vG(jG:kG,:);
                    gBest_swarmG = gBestG(i,:);
                    gbestvalue_swarmG = gbestvalueG(i,1);
                    x_swarmG = xG(jG:kG,:);
                    xBest_swarmG = xBestG(jG:kG,:);
                    fit_swarmG = fitG(jG:kG,:);
                    fitBest_swarmG = fitBestG(jG:kG,:);
                    gaux_swarmG = ones(NG(i),1);
                end
                
                if (i<=N_SWARMSB)
                    v_swarmB = vB(jB:kB,:);
                    gBest_swarmB = gBestB(i,:);
                    gbestvalue_swarmB = gbestvalueB(i,1);
                    x_swarmB = xB(jB:kB,:);
                    xBest_swarmB = xBestB(jB:kB,:);
                    fit_swarmB = fitB(jB:kB,:);
                    fitBest_swarmB = fitBestB(jB:kB,:);
                    gaux_swarmB = ones(NB(i),1);
                end
            end
            
            if (i<=N_SWARMSR)
                randnum1R = rand ([NR(i), N_PAR]);
                randnum2R = rand ([NR(i), N_PAR]);
            end
            
            if (i<=N_SWARMSG)
                randnum1G = rand ([NG(i), N_PAR]);
                randnum2G = rand ([NG(i), N_PAR]);
            end
            
            if (i<=N_SWARMSB)
                randnum1B = rand ([NB(i), N_PAR]);
                randnum2B = rand ([NB(i), N_PAR]);
            end
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    v_swarmR = fix(W.*v_swarmR + randnum1R.*(PHI1.*(xBest_swarmR-x_swarmR)) + randnum2R.*(PHI2.*(gaux_swarmR*gBest_swarmR-x_swarmR)));
                    v_swarmR = ( (v_swarmR <= vmin).*vmin ) + ( (v_swarmR > vmin).*v_swarmR );
                    v_swarmR = ( (v_swarmR >= vmax).*vmax ) + ( (v_swarmR < vmax).*v_swarmR );
                    x_swarmR = round(x_swarmR+v_swarmR);
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    v_swarmR = fix(W.*v_swarmR + randnum1R.*(PHI1.*(xBest_swarmR-x_swarmR)) + randnum2R.*(PHI2.*(gaux_swarmR*gBest_swarmR-x_swarmR)));
                    v_swarmR = ( (v_swarmR <= vmin).*vmin ) + ( (v_swarmR > vmin).*v_swarmR );
                    v_swarmR = ( (v_swarmR >= vmax).*vmax ) + ( (v_swarmR < vmax).*v_swarmR );
                    x_swarmR = round(x_swarmR+v_swarmR);
                end
                
                if (i<=N_SWARMSG)
                    v_swarmG = fix(W.*v_swarmG + randnum1G.*(PHI1.*(xBest_swarmG-x_swarmG)) + randnum2G.*(PHI2.*(gaux_swarmG*gBest_swarmG-x_swarmG)));
                    v_swarmG = ( (v_swarmG <= vmin).*vmin ) + ( (v_swarmG > vmin).*v_swarmG );
                    v_swarmG = ( (v_swarmG >= vmax).*vmax ) + ( (v_swarmG < vmax).*v_swarmG );
                    x_swarmG = round(x_swarmG+v_swarmG);
                end
                
                if (i<=N_SWARMSB)
                    v_swarmB = fix(W.*v_swarmB + randnum1B.*(PHI1.*(xBest_swarmB-x_swarmB)) + randnum2B.*(PHI2.*(gaux_swarmB*gBest_swarmB-x_swarmB)));
                    v_swarmB = ( (v_swarmB <= vmin).*vmin ) + ( (v_swarmB > vmin).*v_swarmB );
                    v_swarmB = ( (v_swarmB >= vmax).*vmax ) + ( (v_swarmB < vmax).*v_swarmB );
                    x_swarmB = round(x_swarmB+v_swarmB);
                end
            end
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    x_swarmR = ( (x_swarmR <= X_MINR(1)).*X_MINR(1) ) + ( (x_swarmR > X_MINR(1)).*x_swarmR );
                    x_swarmR = ( (x_swarmR >= X_MAXR(1)).*X_MAXR(1) ) + ( (x_swarmR < X_MAXR(1)).*x_swarmR );
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    x_swarmR = ( (x_swarmR <= X_MINR(1)).*X_MINR(1) ) + ( (x_swarmR > X_MINR(1)).*x_swarmR );
                    x_swarmR = ( (x_swarmR >= X_MAXR(1)).*X_MAXR(1) ) + ( (x_swarmR < X_MAXR(1)).*x_swarmR );
                end
                
                if (i<=N_SWARMSG)
                    x_swarmG = ( (x_swarmG <= X_MING(1)).*X_MING(1) ) + ( (x_swarmG > X_MING(1)).*x_swarmG );
                    x_swarmG = ( (x_swarmG >= X_MAXG(1)).*X_MAXG(1) ) + ( (x_swarmG < X_MAXG(1)).*x_swarmG );
                end
                
                if (i<=N_SWARMSB)
                    x_swarmB = ( (x_swarmB <= X_MINB(1)).*X_MINB(1) ) + ( (x_swarmB > X_MINB(1)).*x_swarmB );
                    x_swarmB = ( (x_swarmB >= X_MAXB(1)).*X_MAXB(1) ) + ( (x_swarmB < X_MAXB(1)).*x_swarmB );
                end
            end
            
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    for jj = 1:NR(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                        end
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    for jj = 1:NR(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                        end
                    end
                end
                
                if (i<=N_SWARMSG)
                    for jj = 1:NG(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmG(jj,kk) < X_MING(kk)
                                    x_swarmG(jj,kk) = X_MING(kk);
                                elseif x_swarmG(jj,kk) > x_swarmG(jj,kk+1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmG(jj,kk) < x_swarmG(jj,kk-1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmG(jj,kk) > x_swarmG(jj,kk+1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmG(jj,kk) < x_swarmG(jj,kk-1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmG(jj,kk) > X_MAXG(kk)
                                    x_swarmG(jj,kk) = X_MAXG(kk);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmG(jj,kk) < X_MING(kk)
                                    x_swarmG(jj,kk) = X_MING(kk);
                                elseif x_swarmG(jj,kk) > X_MAXG(kk)
                                    x_swarmG(jj,kk) = X_MAXG(kk);
                                end
                            end
                        end
                    end
                end
                   
                if (i<=N_SWARMSB)
                    for jj = 1:NB(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmB(jj,kk) < X_MINB(kk)
                                    x_swarmB(jj,kk) = X_MINB(kk);
                                    %                         disp ('passou o min');
                                elseif x_swarmB(jj,kk) > x_swarmB(jj,kk+1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmB(jj,kk) < x_swarmB(jj,kk-1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmB(jj,kk) > x_swarmB(jj,kk+1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmB(jj,kk) < x_swarmB(jj,kk-1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmB(jj,kk) > X_MAXB(kk)
                                    x_swarmB(jj,kk) = X_MAXB(kk);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmB(jj,kk) < X_MINB(kk)
                                    x_swarmB(jj,kk) = X_MINB(kk);
                                elseif x_swarmB(jj,kk) > X_MAXB(kk)
                                    x_swarmB(jj,kk) = X_MAXB(kk);
                                end
                            end
                        end
                    end
                end
            end

            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    for jj=1:NR(i)
                        fit_swarmR(jj)=sum(probR(1:x_swarmR(jj,1)))*(sum((1:x_swarmR(jj,1)).*probR(1:x_swarmR(jj,1))/sum(probR(1:x_swarmR(jj,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)))*(sum((x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)).*probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))/sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,level-1)+1:Lmax))*(sum((x_swarmR(jj,level-1)+1:Lmax).*probR(x_swarmR(jj,level-1)+1:Lmax)/sum(probR(x_swarmR(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        if fit_swarmR(jj) > fitBest_swarmR(jj)
                            fitBest_swarmR(jj) = fit_swarmR(jj);
                            xBest_swarmR(jj,:) = x_swarmR(jj,:);
                        end
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    for jj=1:NR(i)
                        fit_swarmR(jj)=sum(probR(1:x_swarmR(jj,1)))*(sum((1:x_swarmR(jj,1)).*probR(1:x_swarmR(jj,1))/sum(probR(1:x_swarmR(jj,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)))*(sum((x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)).*probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))/sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,level-1)+1:Lmax))*(sum((x_swarmR(jj,level-1)+1:Lmax).*probR(x_swarmR(jj,level-1)+1:Lmax)/sum(probR(x_swarmR(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        if fit_swarmR(jj) > fitBest_swarmR(jj)
                            fitBest_swarmR(jj) = fit_swarmR(jj);
                            xBest_swarmR(jj,:) = x_swarmR(jj,:);
                        end
                    end
                end
                
                if (i<=N_SWARMSG)
                    for jj=1:NG(i)
                        fit_swarmG(jj)=sum(probG(1:x_swarmG(jj,1)))*(sum((1:x_swarmG(jj,1)).*probG(1:x_swarmG(jj,1))/sum(probG(1:x_swarmG(jj,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmG(jj)=fit_swarmG(jj)+sum(probG(x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel)))*(sum((x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel)).*probG(x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel))/sum(probG(x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        end
                        fit_swarmG(jj)=fit_swarmG(jj)+sum(probG(x_swarmG(jj,level-1)+1:Lmax))*(sum((x_swarmG(jj,level-1)+1:Lmax).*probG(x_swarmG(jj,level-1)+1:Lmax)/sum(probG(x_swarmG(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        if fit_swarmG(jj) > fitBest_swarmG(jj)
                            fitBest_swarmG(jj) = fit_swarmG(jj);
                            xBest_swarmG(jj,:) = x_swarmG(jj,:);
                        end
                    end
                end
                
                if (i<=N_SWARMSB)
                    for jj=1:NB(i)
                        fit_swarmB(jj)=sum(probB(1:x_swarmB(jj,1)))*(sum((1:x_swarmB(jj,1)).*probB(1:x_swarmB(jj,1))/sum(probB(1:x_swarmB(jj,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmB(jj)=fit_swarmB(jj)+sum(probB(x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel)))*(sum((x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel)).*probB(x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel))/sum(probB(x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        end
                        fit_swarmB(jj)=fit_swarmB(jj)+sum(probB(x_swarmB(jj,level-1)+1:Lmax))*(sum((x_swarmB(jj,level-1)+1:Lmax).*probB(x_swarmB(jj,level-1)+1:Lmax)/sum(probB(x_swarmB(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        if fit_swarmB(jj) > fitBest_swarmB(jj)
                            fitBest_swarmB(jj) = fit_swarmB(jj);
                            xBest_swarmB(jj,:) = x_swarmB(jj,:);
                        end
                    end
                end
                    
            end
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    [aR,bR] = max (fit_swarmR);
                    if (fit_swarmR(bR) > gbestvalue_swarmR)
                        gBest_swarmR=x_swarmR(bR,:)-1;
                        gbestvalue_swarmR = fit_swarmR(bR);
                        stagnancy_counterR(i)=0;
                    else
                        stagnancy_counterR(i)=stagnancy_counterR(i)+1;      % didn't improve
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    [aR,bR] = max (fit_swarmR);
                    if (fit_swarmR(bR) > gbestvalue_swarmR)
                        gBest_swarmR=x_swarmR(bR,:)-1;
                        gbestvalue_swarmR = fit_swarmR(bR);
                        stagnancy_counterR(i)=0;
                    else
                        stagnancy_counterR(i)=stagnancy_counterR(i)+1;      % didn't improve
                    end
                end
                
                if (i<=N_SWARMSG)
                    [aG,bG] = max (fit_swarmG);
                    if (fit_swarmG(bG) > gbestvalue_swarmG)
                        gBest_swarmG=x_swarmG(bG,:)-1;
                        gbestvalue_swarmG = fit_swarmG(bG);
                        stagnancy_counterG(i)=0;
                    else
                        stagnancy_counterG(i)=stagnancy_counterG(i)+1;      % didn't improve
                    end
                end
                
                if (i<=N_SWARMSB)
                    [aB,bB] = max (fit_swarmB);
                    if (fit_swarmB(bB) > gbestvalue_swarmB)
                        gBest_swarmB=x_swarmB(bB,:)-1;
                        gbestvalue_swarmB = fit_swarmB(bB);
                        stagnancy_counterB(i)=0;
                    else
                        stagnancy_counterB(i)=stagnancy_counterB(i)+1;      % didn't improve
                    end
                end
            end
            
            % evaluate swarm i:
            manteveR = 1;
            manteveG = 1;
            manteveB = 1;
            
            
            % create a new particle if possible
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && NR(i)<MAX_POP )
                        % create particle
                        NR(i)=NR(i)+1; %new swarm size
                        x_swarmR(NR(i),:) = fix(rand(1,1) * ( X_MAXR(:)-X_MINR(:) ) + X_MINR(:));  %new particle
                        v_swarmR(NR(i),:) = zeros (1,N_PAR);
                        xBest_swarmR(NR(i),:) = x_swarmR(NR(i),:);     %local best
                        fit_swarmR(NR(i))=sum(probR(1:x_swarmR(NR(i),1)))*(sum((1:x_swarmR(NR(i),1)).*probR(1:x_swarmR(NR(i),1))/sum(probR(1:x_swarmR(NR(i),1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)))*(sum((x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)).*probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))/sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),level-1)+1:Lmax))*(sum((x_swarmR(NR(i),level-1)+1:Lmax).*probR(x_swarmR(NR(i),level-1)+1:Lmax)/sum(probR(x_swarmR(NR(i),level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        [aR,bR]=max(fit_swarmR);
                        gBest_swarmR=x_swarmR(bR,:);
                        gbestvalue_swarmR = fit_swarmR(bR);
                        xBest_swarmR = x_swarmR;
                        fitBest_swarmR(NR(i),:)=fit_swarmR(NR(i),:);
                        % re-create tables
                        vR=insertrows(vR,v_swarmR(NR(i),:),k);
                        vR(jR:kR+1,:) = v_swarmR;
                        xR=insertrows(xR,x_swarmR(NR(i),:),k);
                        xR(jR:kR+1,:) = x_swarmR;
                        xBestR=insertrows(xBestR,xBest_swarmR(NR(i),:),k);
                        xBestR(jR:kR+1,:) = xBest_swarmR;
                        fitR=insertrows(fitR,fit_swarmR(NR(i),:),k);
                        fitR(jR:kR+1,:) = fit_swarmR;
                        fitBestR=insertrows(fitBestR,fitBest_swarmR(NR(i),:),k);
                        fitBestR(jR:kR+1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR+1;
                        manteveR = 0;
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && NR(i)<MAX_POP )
                        % create particle
                        NR(i)=NR(i)+1; %new swarm size
                        x_swarmR(NR(i),:) = fix(rand(1,1) * ( X_MAXR(:)-X_MINR(:) ) + X_MINR(:));  %new particle
                        v_swarmR(NR(i),:) = zeros (1,N_PAR);
                        xBest_swarmR(NR(i),:) = x_swarmR(NR(i),:);     %local best
                        fit_swarmR(NR(i))=sum(probR(1:x_swarmR(NR(i),1)))*(sum((1:x_swarmR(NR(i),1)).*probR(1:x_swarmR(NR(i),1))/sum(probR(1:x_swarmR(NR(i),1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)))*(sum((x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)).*probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))/sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),level-1)+1:Lmax))*(sum((x_swarmR(NR(i),level-1)+1:Lmax).*probR(x_swarmR(NR(i),level-1)+1:Lmax)/sum(probR(x_swarmR(NR(i),level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        [aR,bR]=max(fit_swarmR);
                        gBest_swarmR=x_swarmR(bR,:);
                        gbestvalue_swarmR = fit_swarmR(bR);
                        xBest_swarmR = x_swarmR;
                        fitBest_swarmR(NR(i),:)=fit_swarmR(NR(i),:);
                        % re-create tables
                        vR=insertrows(vR,v_swarmR(NR(i),:),kR);
                        vR(jR:kR+1,:) = v_swarmR;
                        xR=insertrows(xR,x_swarmR(NR(i),:),kR);
                        xR(jR:kR+1,:) = x_swarmR;
                        xBestR=insertrows(xBestR,xBest_swarmR(NR(i),:),kR);
                        xBestR(jR:kR+1,:) = xBest_swarmR;
                        fitR=insertrows(fitR,fit_swarmR(NR(i),:),kR);
                        fitR(jR:kR+1,:) = fit_swarmR;
                        fitBestR=insertrows(fitBestR,fitBest_swarmR(NR(i),:),kR);
                        fitBestR(jR:kR+1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR+1;
                        manteveR = 0;
                    end
                end
                
                if (i<=N_SWARMSG)
                    if( stagnancy_counterG(i)==0 && NG(i)<MAX_POP )
                        % create particle
                        NG(i)=NG(i)+1; %new swarm size
                        x_swarmG(NG(i),:) = fix(rand(1,1) * ( X_MAXG(:)-X_MING(:) ) + X_MING(:));  %new particle
                        v_swarmG(NG(i),:) = zeros (1,N_PAR);
                        xBest_swarmG(NG(i),:) = x_swarmG(NG(i),:);     %local best
                        fit_swarmG(NG(i))=sum(probG(1:x_swarmG(NG(i),1)))*(sum((1:x_swarmG(NG(i),1)).*probG(1:x_swarmG(NG(i),1))/sum(probG(1:x_swarmG(NG(i),1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmG(NG(i))=fit_swarmG(NG(i))+sum(probG(x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel)))*(sum((x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel)).*probG(x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel))/sum(probG(x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        end
                        fit_swarmG(NG(i))=fit_swarmG(NG(i))+sum(probG(x_swarmG(NG(i),level-1)+1:Lmax))*(sum((x_swarmG(NG(i),level-1)+1:Lmax).*probG(x_swarmG(NG(i),level-1)+1:Lmax)/sum(probG(x_swarmG(NG(i),level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        [aG,bG]=max(fit_swarmG);
                        gBest_swarmG=x_swarmG(bG,:);
                        gbestvalue_swarmG = fit_swarmG(bG);
                        xBest_swarmG = x_swarmG;
                        fitBest_swarmG(NG(i),:)=fit_swarmG(NG(i),:);
                        % re-create tables
                        vG=insertrows(vG,v_swarmG(NG(i),:),kG);
                        vG(jG:kG+1,:) = v_swarmG;
                        xG=insertrows(xG,x_swarmG(NG(i),:),kG);
                        xG(jG:kG+1,:) = x_swarmG;
                        xBestG=insertrows(xBestG,xBest_swarmG(NG(i),:),kG);
                        xBestG(jG:kG+1,:) = xBest_swarmG;
                        fitG=insertrows(fitG,fit_swarmG(NG(i),:),kG);
                        fitG(jG:kG+1,:) = fit_swarmG;
                        fitBestG=insertrows(fitBestG,fitBest_swarmG(NG(i),:),kG);
                        fitBestG(jG:kG+1,:) = fitBest_swarmG;
                        gBestG(i,:)=gBest_swarmG;
                        gbestvalueG(i,:)=gbestvalue_swarmG;
                        kG=kG+1;
                        manteveG = 0;
                    end
                end
                
                if (i<=N_SWARMSB)
                    if( stagnancy_counterB(i)==0 && NB(i)<MAX_POP )
                        % create particle
                        NB(i)=NB(i)+1; %new swarm size
                        x_swarmB(NB(i),:) = fix(rand(1,1) * ( X_MAXB(:)-X_MINB(:) ) + X_MINB(:));  %new particle
                        v_swarmB(NB(i),:) = zeros (1,N_PAR);
                        xBest_swarmB(NB(i),:) = x_swarmB(NB(i),:);     %local best
                        fit_swarmB(NB(i))=sum(probB(1:x_swarmB(NB(i),1)))*(sum((1:x_swarmB(NB(i),1)).*probB(1:x_swarmB(NB(i),1))/sum(probB(1:x_swarmB(NB(i),1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmB(NB(i))=fit_swarmB(NB(i))+sum(probB(x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel)))*(sum((x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel)).*probB(x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel))/sum(probB(x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        end
                        fit_swarmB(NB(i))=fit_swarmB(NB(i))+sum(probB(x_swarmB(NB(i),level-1)+1:Lmax))*(sum((x_swarmB(NB(i),level-1)+1:Lmax).*probB(x_swarmB(NB(i),level-1)+1:Lmax)/sum(probB(x_swarmB(NB(i),level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        [aB,bB]=max(fit_swarmB);
                        gBest_swarmB=x_swarmB(bB,:);
                        gbestvalue_swarmB = fit_swarmB(bB);
                        xBest_swarmB = x_swarmB;
                        fitBest_swarmB(NB(i),:)=fit_swarmB(NB(i),:);
                        % re-create tables
                        vB=insertrows(vB,v_swarmB(NB(i),:),kB);
                        vB(jB:kB+1,:) = v_swarmB;
                        xB=insertrows(xB,x_swarmB(NB(i),:),kB);
                        xB(jB:kB+1,:) = x_swarmB;
                        xBestB=insertrows(xBestB,xBest_swarmB(NB(i),:),kB);
                        xBestB(jB:kB+1,:) = xBest_swarmB;
                        fitB=insertrows(fitB,fit_swarmB(NB(i),:),kB);
                        fitB(jB:kB+1,:) = fit_swarmB;
                        fitBestB=insertrows(fitBestB,fitBest_swarmB(NB(i),:),kB);
                        fitBestB(jB:kB+1,:) = fitBest_swarmB;
                        gBestB(i,:)=gBest_swarmB;
                        gbestvalueB(i,:)=gbestvalue_swarmB;
                        kB=kB+1;
                        manteveB = 0;
                    end
                end
            end
            
            
            % create a new swarm  
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && already_deletedR(i)==0 && N_SWARMSR < MAX_SWARMS )
                        p=rand/N_SWARMSR;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NR(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NR(i),1);
                                x_nova(n,:) = x_swarmR(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSR,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSR,1);
                            end
                            inicio=sum( NR(1:swarm_aleatoria-1) );
                            for m=1:ceil( NR(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi ( NR(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xR(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXR-X_MINR ) + X_MINR));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSR = N_SWARMSR+1;   % refresh number of swarms
                            NR(N_SWARMSR) = m;        % population of the new swarm
                            n=size(xR,1);
                            o=n;
                            xR=[xR;x_nova];            % positions of the new particles
                            xBestR=[xBestR;x_nova];    % best position of new particles
                            vR=[vR;zeros(m,N_PAR)];    % initial velocity of new particles
                            for n=o+1:o+m
                                fitR(n)=sum(probR(1:xR(n,1)))*(sum((1:xR(n,1)).*probR(1:xR(n,1))/sum(probR(1:xR(n,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitR(n)=fitR(n)+sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel)))*(sum((xR(n,jlevel-1)+1:xR(n,jlevel)).*probR(xR(n,jlevel-1)+1:xR(n,jlevel))/sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                end
                                fitR(n)=fitR(n)+sum(probR(xR(n,level-1)+1:Lmax))*(sum((xR(n,level-1)+1:Lmax).*probR(xR(n,level-1)+1:Lmax)/sum(probR(xR(n,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                fitBestR(n)=fitR(n);
                            end
                            [aR,bR]=max(fitR(o+1:o+m,:));
                            gBestR(N_SWARMSR,:)=xR(o+bR,:);
                            gbestvalueR(N_SWARMSR,1) = fitR(o+bR);
                            already_deletedR(N_SWARMSR)=0;
                            stagnancy_counterR(N_SWARMSR)=0;
                            clear x_nova;
                        end
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && already_deletedR(i)==0 && N_SWARMSR < MAX_SWARMS )
                        p=rand/N_SWARMSR;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NR(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NR(i),1);
                                x_nova(n,:) = x_swarmR(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSR,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSR,1);
                            end
                            inicio=sum( NR(1:swarm_aleatoria-1) );
                            for m=1:ceil( NR(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi ( NR(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xR(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXR-X_MINR ) + X_MINR));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSR = N_SWARMSR+1;   % refresh number of swarms
                            NR(N_SWARMSR) = m;        % population of the new swarm
                            n=size(xR,1);
                            o=n;
                            xR=[xR;x_nova];            % positions of the new particles
                            xBestR=[xBestR;x_nova];    % best position of new particles
                            vR=[vR;zeros(m,N_PAR)];    % initial velocity of new particles
                            for n=o+1:o+m
                                fitR(n)=sum(probR(1:xR(n,1)))*(sum((1:xR(n,1)).*probR(1:xR(n,1))/sum(probR(1:xR(n,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitR(n)=fitR(n)+sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel)))*(sum((xR(n,jlevel-1)+1:xR(n,jlevel)).*probR(xR(n,jlevel-1)+1:xR(n,jlevel))/sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                end
                                fitR(n)=fitR(n)+sum(probR(xR(n,level-1)+1:Lmax))*(sum((xR(n,level-1)+1:Lmax).*probR(xR(n,level-1)+1:Lmax)/sum(probR(xR(n,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                fitBestR(n)=fitR(n);
                            end
                            [aR,bR]=max(fitR(o+1:o+m,:));
                            gBestR(N_SWARMSR,:)=xR(o+bR,:);
                            gbestvalueR(N_SWARMSR,1) = fitR(o+bR);
                            already_deletedR(N_SWARMSR)=0;
                            stagnancy_counterR(N_SWARMSR)=0;
                            clear x_nova;
                        end
                    end
                end
                   
                if (i<=N_SWARMSG)
                    if( stagnancy_counterG(i)==0 && already_deletedG(i)==0 && N_SWARMSG < MAX_SWARMS )
                        p=rand/N_SWARMSG;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NG(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NG(i),1);
                                x_nova(n,:) = x_swarmG(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSG,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSG,1);
                            end
                            inicio=sum( NG(1:swarm_aleatoria-1) );
                            for m=1:ceil( NG(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi( NG(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xG(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXG-X_MING ) + X_MING));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSG = N_SWARMSG+1;   % refresh number of swarms
                            NG(N_SWARMSG) = m;        % population of the new swarm
                            n=size(xG,1);
                            o=n;
                            xG=[xG;x_nova];            % positions of the new particles
                            xBestG=[xBestG;x_nova];    % best position of new particles
                            vG=[vG;zeros(m,N_PAR)];    % initial velocity of new particles
                            for n=o+1:o+m
                                fitG(n)=sum(probG(1:xG(n,1)))*(sum((1:xG(n,1)).*probG(1:xG(n,1))/sum(probG(1:xG(n,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitG(n)=fitG(n)+sum(probG(xG(n,jlevel-1)+1:xG(n,jlevel)))*(sum((xG(n,jlevel-1)+1:xG(n,jlevel)).*probG(xG(n,jlevel-1)+1:xG(n,jlevel))/sum(probG(xG(n,jlevel-1)+1:xG(n,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
                                end
                                fitG(n)=fitG(n)+sum(probG(xG(n,level-1)+1:Lmax))*(sum((xG(n,level-1)+1:Lmax).*probG(xG(n,level-1)+1:Lmax)/sum(probG(xG(n,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
                                fitBestG(n)=fitG(n);
                            end
                            [aG,bG]=max(fitG(o+1:o+m,:));
                            gBestG(N_SWARMSG,:)=xG(o+bG,:);
                            gbestvalueG(N_SWARMSG,1) = fitG(o+bG);
                            already_deletedG(N_SWARMSG)=0;
                            stagnancy_counterG(N_SWARMSG)=0;
                            clear x_nova;
                        end
                    end
                end
                
                if (i<=N_SWARMSB)
                    if( stagnancy_counterB(i)==0 && already_deletedB(i)==0 && N_SWARMSB < MAX_SWARMS )
                        p=rand/N_SWARMSB;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NB(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NB(i),1);
                                x_nova(n,:) = x_swarmB(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSB,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSB,1);
                            end
                            inicio=sum( NB(1:swarm_aleatoria-1) );
                            for m=1:ceil( NB(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi ( NB(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xB(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXB-X_MINB ) + X_MINB));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSB = N_SWARMSB+1;   % refresh number of swarms
                            NB(N_SWARMSB) = m;        % population of the new swarm
                            n=size(xB,1);
                            o=n;
                            xB=[xB;x_nova];            % positions of the new particles
                            xBestB=[xBestB;x_nova];    % best position of new particles
                            vB=[vB;zeros(m,N_PAR)];    % initial velocity of new particles
                            for n=o+1:o+m
                                fitB(n)=sum(probB(1:xB(n,1)))*(sum((1:xB(n,1)).*probB(1:xB(n,1))/sum(probB(1:xB(n,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitB(n)=fitB(n)+sum(probB(xB(n,jlevel-1)+1:xB(n,jlevel)))*(sum((xB(n,jlevel-1)+1:xB(n,jlevel)).*probB(xB(n,jlevel-1)+1:xB(n,jlevel))/sum(probB(xB(n,jlevel-1)+1:xB(n,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
                                end
                                fitB(n)=fitB(n)+sum(probB(xB(n,level-1)+1:Lmax))*(sum((xB(n,level-1)+1:Lmax).*probB(xB(n,level-1)+1:Lmax)/sum(probB(xB(n,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
                                fitBestB(n)=fitB(n);
                            end
                            [aB,bB]=max(fitB(o+1:o+m,:));
                            gBestB(N_SWARMSB,:)=xB(o+bB,:);
                            gbestvalueB(N_SWARMSB,1) = fitB(o+bB);
                            already_deletedB(N_SWARMSB)=0;
                            stagnancy_counterB(N_SWARMSB)=0;
                            clear x_nova;
                        end
                    end
                end
            end
            
            
            % eliminate worst particle
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if (stagnancy_counterR(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmR);
                        % eliminate worst particle
                        NR(i)=NR(i)-1;
                        x_swarmR(idx_pior,:)=[];
                        xBest_swarmR(idx_pior,:)=[];
                        v_swarmR(idx_pior,:)=[];
                        fit_swarmR(idx_pior,:)=[];
                        fitBest_swarmR(idx_pior,:)=[];
                        % re-create tables
                        vR(jR+idx_pior-1,:)=[];
                        vR(jR:kR-1,:) = v_swarmR;
                        xR(jR+idx_pior-1,:)=[];
                        xR(jR:kR-1,:) = x_swarmR;
                        xBestR(jR+idx_pior-1,:)=[];
                        xBestR(jR:kR-1,:) = xBest_swarmR;
                        fitR(jR+idx_pior-1,:)=[];
                        fitR(jR:kR-1,:) = fit_swarmR;
                        fitBestR(jR+idx_pior-1,:)=[];
                        fitBestR(jR:kR-1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR-1;
                        manteveR = 0;
                        already_deletedR(i)=already_deletedR(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterR(i) = round( STAGNANCY * (1- ( 1/(already_deletedR(i)+1) ) ) );
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if (stagnancy_counterR(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmR);
                        % eliminate worst particle
                        NR(i)=NR(i)-1;
                        x_swarmR(idx_pior,:)=[];
                        xBest_swarmR(idx_pior,:)=[];
                        v_swarmR(idx_pior,:)=[];
                        fit_swarmR(idx_pior,:)=[];
                        fitBest_swarmR(idx_pior,:)=[];
                        % re-create tables
                        vR(jR+idx_pior-1,:)=[];
                        vR(jR:kR-1,:) = v_swarmR;
                        xR(jR+idx_pior-1,:)=[];
                        xR(jR:kR-1,:) = x_swarmR;
                        xBestR(jR+idx_pior-1,:)=[];
                        xBestR(jR:kR-1,:) = xBest_swarmR;
                        fitR(jR+idx_pior-1,:)=[];
                        fitR(jR:kR-1,:) = fit_swarmR;
                        fitBestR(jR+idx_pior-1,:)=[];
                        fitBestR(jR:kR-1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR-1;
                        manteveR = 0;
                        already_deletedR(i)=already_deletedR(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterR(i) = round( STAGNANCY * (1- ( 1/(already_deletedR(i)+1) ) ) );
                    end
                end
                
                if (i<=N_SWARMSG)
                    if (stagnancy_counterG(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmG);
                        % eliminate worst particle
                        NG(i)=NG(i)-1;
                        x_swarmG(idx_pior,:)=[];
                        xBest_swarmG(idx_pior,:)=[];
                        v_swarmG(idx_pior,:)=[];
                        fit_swarmG(idx_pior,:)=[];
                        fitBest_swarmG(idx_pior,:)=[];
                        % re-create tables
                        vG(jG+idx_pior-1,:)=[];
                        vG(jG:kG-1,:) = v_swarmG;
                        xG(jG+idx_pior-1,:)=[];
                        xG(jG:kG-1,:) = x_swarmG;
                        xBestG(jG+idx_pior-1,:)=[];
                        xBestG(jG:kG-1,:) = xBest_swarmG;
                        fitG(jG+idx_pior-1,:)=[];
                        fitG(jG:kG-1,:) = fit_swarmG;
                        fitBestG(jG+idx_pior-1,:)=[];
                        fitBestG(jG:kG-1,:) = fitBest_swarmG;
                        gBestG(i,:)=gBest_swarmG;
                        gbestvalueG(i,:)=gbestvalue_swarmG;
                        kG=kG-1;
                        manteveG = 0;
                        already_deletedG(i)=already_deletedG(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterG(i) = round( STAGNANCY * (1- ( 1/(already_deletedG(i)+1) ) ) );
                    end
                end
                
                if (i<=N_SWARMSB)
                    if (stagnancy_counterB(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmB);
                        % eliminate worst particle
                        NB(i)=NB(i)-1;
                        x_swarmB(idx_pior,:)=[];
                        xBest_swarmB(idx_pior,:)=[];
                        v_swarmB(idx_pior,:)=[];
                        fit_swarmB(idx_pior,:)=[];
                        fitBest_swarmB(idx_pior,:)=[];
                        % re-create tables
                        vB(jB+idx_pior-1,:)=[];
                        vB(jB:kB-1,:) = v_swarmB;
                        xB(jB+idx_pior-1,:)=[];
                        xB(jB:kB-1,:) = x_swarmB;
                        xBestB(jB+idx_pior-1,:)=[];
                        xBestB(jB:kB-1,:) = xBest_swarmB;
                        fitB(jB+idx_pior-1,:)=[];
                        fitB(jB:kB-1,:) = fit_swarmB;
                        fitBestB(jB+idx_pior-1,:)=[];
                        fitBestB(jB:kB-1,:) = fitBest_swarmB;
                        gBestB(i,:)=gBest_swarmB;
                        gbestvalueB(i,:)=gbestvalue_swarmB;
                        kB=kB-1;
                        manteveB = 0;
                        already_deletedB(i)=already_deletedB(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterB(i) = round( STAGNANCY * (1- ( 1/(already_deletedB(i)+1) ) ) );
                    end
                end
            end
            
            
            % eliminate swarm
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if (NR(i)==MIN_POP)&&(N_SWARMSR>MIN_SWARMS)
                        vR(jR:kR,:)=[];
                        xR(jR:kR,:)=[];
                        xBestR(jR:kR,:)=[];
                        fitR(jR:kR,:)=[];
                        fitBestR(jR:kR)=[];
                        gBestR(i,:)=[];
                        gbestvalueR(i,:)=[];
                        NR(i)=[];
                        already_deletedR(i)=[];
                        stagnancy_counterR(i)=[];
                        N_SWARMSR = N_SWARMSR - 1;
%                         i = i-1;
                        manteveR=0;
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if (NR(i)==MIN_POP)&&(N_SWARMSR>MIN_SWARMS)
                        vR(jR:kR,:)=[];
                        xR(jR:kR,:)=[];
                        xBestR(jR:kR,:)=[];
                        fitR(jR:kR,:)=[];
                        fitBestR(jR:kR)=[];
                        gBestR(i,:)=[];
                        gbestvalueR(i,:)=[];
                        NR(i)=[];
                        already_deletedR(i)=[];
                        stagnancy_counterR(i)=[];
                        N_SWARMSR = N_SWARMSR - 1;
%                         i = i-1;
                        manteveR=0;
                    end
                end
                
                if (i<=N_SWARMSG)
                    if (NG(i)==MIN_POP)&&(N_SWARMSG>MIN_SWARMS)
                        vG(jG:kG,:)=[];
                        xG(jG:kG,:)=[];
                        xBestG(jG:kG,:)=[];
                        fitG(jG:kG,:)=[];
                        fitBestG(jG:kG)=[];
                        gBestG(i,:)=[];
                        gbestvalueG(i,:)=[];
                        NG(i)=[];
                        already_deletedG(i)=[];
                        stagnancy_counterG(i)=[];
                        N_SWARMSG = N_SWARMSG - 1;
%                         i = i-1;
                        manteveG=0;
                    end
                end
                
                if (i<=N_SWARMSB)&&(N_SWARMSB>MIN_SWARMS)
                    if (NB(i)==MIN_POP)
                        vB(jB:kB,:)=[];
                        xB(jB:kB,:)=[];
                        xBestB(jB:kB,:)=[];
                        fitB(jB:kB,:)=[];
                        fitBestB(jB:kB)=[];
                        gBestB(i,:)=[];
                        gbestvalueB(i,:)=[];
                        NB(i)=[];
                        already_deletedB(i)=[];
                        stagnancy_counterB(i)=[];
                        N_SWARMSB = N_SWARMSB - 1;
%                         i = i-1;
                        manteveB=0;
                    end
                end
            end
            
            % refresh structures
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if (manteveR==1)
                        vR(jR:kR,:) = v_swarmR;
                        gBestR(i,:) = gBest_swarmR;
                        gbestvalueR(i,1) = gbestvalue_swarmR;
                        xR(jR:kR,:) = x_swarmR;
                        xBestR(jR:kR,:) = xBest_swarmR;
                        fitR(jR:kR,:) = fit_swarmR;
                        fitBestR(jR:kR,:) = fitBest_swarmR;
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if (manteveR==1)
                        vR(jR:kR,:) = v_swarmR;
                        gBestR(i,:) = gBest_swarmR;
                        gbestvalueR(i,1) = gbestvalue_swarmR;
                        xR(jR:kR,:) = x_swarmR;
                        xBestR(jR:kR,:) = xBest_swarmR;
                        fitR(jR:kR,:) = fit_swarmR;
                        fitBestR(jR:kR,:) = fitBest_swarmR;
                    end
                end
                
                if (i<=N_SWARMSG)
                    if (manteveG==1)
                        vG(jG:kG,:) = v_swarmG;
                        gBestG(i,:) = gBest_swarmG;
                        gbestvalueG(i,1) = gbestvalue_swarmG;
                        xG(jG:kG,:) = x_swarmG;
                        xBestG(jG:kG,:) = xBest_swarmG;
                        fitG(jG:kG,:) = fit_swarmG;
                        fitBestG(jG:kG,:) = fitBest_swarmG;
                    end
                end
                
                if (i<=N_SWARMSB)
                    if (manteveB==1)
                        vB(jB:kB,:) = v_swarmB;
                        gBestB(i,:) = gBest_swarmB;
                        gbestvalueB(i,1) = gbestvalue_swarmB;
                        xB(jB:kB,:) = x_swarmB;
                        xBestB(jB:kB,:) = xBest_swarmB;
                        fitB(jB:kB,:) = fit_swarmB;
                        fitBestB(jB:kB,:) = fitBest_swarmB;
                    end
                end
            end

            %clear variables
            clear v_swarmR v_swarmG v_swarmB;
            clear gBest_swarmR gBest_swarmG gBest_swarmB;
            clear gbestvalue_swarmR gbestvalue_swarmG gbestvalue_swarmB;
            clear x_swarmR x_swarmG x_swarmB;
            clear xBest_swarmR xBest_swarmG xBest_swarmB;
            clear fit_swarmR fit_swarmG fit_swarmB;
            clear fitBest_swarmR fitBest_swarmG fitBest_swarmB;

            i=i+1; %avança para a próxima Swarm
        end
    
        
        % calculate gbestvalue_DPSO (global best from all swarms):
        
        if size(I,3)==1 %grayscale image
            antigoR = gbestvalue_DPSOR;
            [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(gbestvalueR);
        elseif size(I,3)==3 %RGB image
            antigoR = gbestvalue_DPSOR;
            [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(gbestvalueR);

            antigoG = gbestvalue_DPSOG;
            [gbestvalue_DPSOG,i_gbestvalue_DPSOG]=max(gbestvalueG);

            antigoB = gbestvalue_DPSOB;
            [gbestvalue_DPSOB,i_gbestvalue_DPSOB]=max(gbestvalueB);

        end
        
        nger=nger+1;
    end

    if size(I,3)==1 %grayscale image
        gBestR = round(gBestR(i_gbestvalue_DPSOR,:));
        gbestvalueR=gbestvalue_DPSOR;
    elseif size(I,3)==3 %RGB image
        gBestR = round(gBestR(i_gbestvalue_DPSOR,:));
        gbestvalueR=gbestvalue_DPSOR;
        gBestG = round(gBestG(i_gbestvalue_DPSOG,:));
        gbestvalueG=gbestvalue_DPSOG;
        gBestB = round(gBestB(i_gbestvalue_DPSOB,:));
        gbestvalueB=gbestvalue_DPSOB;
    end
    
    
%     gbestvalue_DPSOR
end


if strcmpi(method,'fodpso') %FO-DPSO method
    
    N = 30;          % current population of the swarm
    MIN_POP = 10;    % minimum population
    MAX_POP = 50;   % maximum population
    POP_INICIAL = N; % population from new swarms
    
    N_SWARMS = 4;
    N_SWARMSR = N_SWARMS;      % current number of swarms
    N_SWARMSG = N_SWARMS;      % current number of swarms
    N_SWARMSB = N_SWARMS;      % current number of swarms
    
    MIN_SWARMS = 2;     % minimum number of swarms
    MAX_SWARMS = 6;   % maximum number of swarms
    
    STAGNANCY = 10;      % maximum number of iterations without improving
    
    N_PAR = level-1;      %number of thresholds (number of levels-1)
    N_GER = 150;    %number of iterations of the PSO algorithm
    
    % weights:
    PHI1 = 0.8;  %individual weight of particles
    PHI2 = 0.8;  %social weight of particles
    
    % FO-DPSO specific parameters
    alfa = 0.6;   %fractional coefficient
    v_swarmR_3=0;
    v_swarmR_2=0;
    v_swarmR_1=0;
    v_swarmG_3=0;
    v_swarmG_2=0;
    v_swarmG_1=0;
    v_swarmB_3=0;
    v_swarmB_2=0;
    v_swarmB_1=0;
    vR_1=zeros(N*N_SWARMS,N_PAR);
    vG_1=zeros(N*N_SWARMS,N_PAR);
    vB_1=zeros(N*N_SWARMS,N_PAR);
    vR_2=zeros(N*N_SWARMS,N_PAR);
    vG_2=zeros(N*N_SWARMS,N_PAR);
    vB_2=zeros(N*N_SWARMS,N_PAR);
    vR_3=zeros(N*N_SWARMS,N_PAR);
    vG_3=zeros(N*N_SWARMS,N_PAR);
    vB_3=zeros(N*N_SWARMS,N_PAR);
    %
    
    vmin=-1.5;          % Velocidade Máxima por iteração
    vmax=1.5;           % Velocidade Mínima por iteração
    
    if size(I,3)==1 %grayscale image
        vR=zeros(N*N_SWARMS,N_PAR);  %velocities of particles
        X_MAXR = Lmax*ones(1,N_PAR);
        X_MINR = ones(1,N_PAR);
        gBestR = zeros(N_SWARMS,N_PAR);
        gbestvalueR = -1000*ones(N_SWARMS,1);
        gauxR = ones(N*N_SWARMS,1);
        xBestR=zeros(N*N_SWARMS,N_PAR);
        fitBestR=zeros(N*N_SWARMS,1);
        fitR = zeros(N*N_SWARMS,1);
        xR = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xR(i,j) = fix(rand(1,1) * ( X_MAXR(j)-X_MINR(j) ) + X_MINR(j));
            end
        end
        for si=1:length(xR)
           xR(si,:)=sort(xR(si,:)); 
        end
    elseif size(I,3)==3 %RGB image    
        vR=zeros(N*N_SWARMS,N_PAR);  %velocities of particles
        vG=zeros(N*N_SWARMS,N_PAR);
        vB=zeros(N*N_SWARMS,N_PAR);
        X_MAXR = Lmax*ones(1,N_PAR);
        X_MINR = ones(1,N_PAR);
        X_MAXG = Lmax*ones(1,N_PAR);
        X_MING = ones(1,N_PAR);
        X_MAXB = Lmax*ones(1,N_PAR);
        X_MINB = ones(1,N_PAR);
        gBestR = zeros(N_SWARMS,N_PAR);
        gbestvalueR = -1000*ones(N_SWARMS,1);
        gauxR = ones(N*N_SWARMS,1);
        xBestR=zeros(N*N_SWARMS,N_PAR);
        fitBestR=zeros(N*N_SWARMS,1);
        fitR = zeros(N*N_SWARMS,1);
        gBestG = zeros(N_SWARMS,N_PAR);
        gbestvalueG = -1000*ones(N_SWARMS,1);
        gauxG = ones(N*N_SWARMS,1);
        xBestG=zeros(N*N_SWARMS,N_PAR);
        fitBestG=zeros(N*N_SWARMS,1);
        fitG = zeros(N*N_SWARMS,1);
        gBestB = zeros(N_SWARMS,N_PAR);
        gbestvalueB = -1000*ones(N_SWARMS,1);
        gauxB = ones(N*N_SWARMS,1);
        xBestB=zeros(N*N_SWARMS,N_PAR);
        fitBestB=zeros(N*N_SWARMS,1);
        fitB = zeros(N*N_SWARMS,1);
        xR = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xR(i,j) = fix(rand(1,1) * ( X_MAXR(j)-X_MINR(j) ) + X_MINR(j));
            end
        end
        xG = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xG(i,j) = fix(rand(1,1) * ( X_MAXG(j)-X_MING(j) ) + X_MING(j));
            end
        end
        xB = zeros(N*N_SWARMS,N_PAR);
        for i = 1: N*N_SWARMS
            for j = 1: N_PAR
                xB(i,j) = fix(rand(1,1) * ( X_MAXB(j)-X_MINB(j) ) + X_MINB(j));
            end
        end
        for si=1:length(xR)
           xR(si,:)=sort(xR(si,:)); 
        end
        for si=1:length(xG)
           xG(si,:)=sort(xG(si,:));
        end
        for si=1:length(xB)
           xB(si,:)=sort(xB(si,:)); 
        end
    end
    
    nger=1;

    for j=1:N*N_SWARMS
        if size(I,3)==1 %grayscale image
            fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
            end
            fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
            fitBestR(j)=fitR(j);
        elseif size(I,3)==3 %RGB image
            fitR(j)=sum(probR(1:xR(j,1)))*(sum((1:xR(j,1)).*probR(1:xR(j,1))/sum(probR(1:xR(j,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitR(j)=fitR(j)+sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel)))*(sum((xR(j,jlevel-1)+1:xR(j,jlevel)).*probR(xR(j,jlevel-1)+1:xR(j,jlevel))/sum(probR(xR(j,jlevel-1)+1:xR(j,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
            end
            fitR(j)=fitR(j)+sum(probR(xR(j,level-1)+1:Lmax))*(sum((xR(j,level-1)+1:Lmax).*probR(xR(j,level-1)+1:Lmax)/sum(probR(xR(j,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
            fitBestR(j)=fitR(j);
            fitG(j)=sum(probG(1:xG(j,1)))*(sum((1:xG(j,1)).*probG(1:xG(j,1))/sum(probG(1:xG(j,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitG(j)=fitG(j)+sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel)))*(sum((xG(j,jlevel-1)+1:xG(j,jlevel)).*probG(xG(j,jlevel-1)+1:xG(j,jlevel))/sum(probG(xG(j,jlevel-1)+1:xG(j,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
            end
            fitG(j)=fitG(j)+sum(probG(xG(j,level-1)+1:Lmax))*(sum((xG(j,level-1)+1:Lmax).*probG(xG(j,level-1)+1:Lmax)/sum(probG(xG(j,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
            fitBestG(j)=fitG(j);
            fitB(j)=sum(probB(1:xB(j,1)))*(sum((1:xB(j,1)).*probB(1:xB(j,1))/sum(probB(1:xB(j,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitB(j)=fitB(j)+sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel)))*(sum((xB(j,jlevel-1)+1:xB(j,jlevel)).*probB(xB(j,jlevel-1)+1:xB(j,jlevel))/sum(probB(xB(j,jlevel-1)+1:xB(j,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
            end
            fitB(j)=fitB(j)+sum(probB(xB(j,level-1)+1:Lmax))*(sum((xB(j,level-1)+1:Lmax).*probB(xB(j,level-1)+1:Lmax)/sum(probB(xB(j,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
            fitBestB(j)=fitB(j);
        end
    end

    if size(I,3)==1 %grayscale image
        for i=1:N_SWARMS            % global best of each swarm and best fit of the DPSO
            
            k=i*N;      % end of swarm i
            j=k-N+1;    % start of swarm i
            
            [aR,bR]=max(fitR(j:k,:));
            
            gBestR(i,:)=xR(j-1+bR,:);
            gbestvalueR(i,1)= fitR(j-1+bR);
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(fitR);
            end
        end
        xBestR = xR;
    elseif size(I,3)==3 %RGB image
        for i=1:N_SWARMS            % global best of each swarm and best fit of the DPSO
            
            k=i*N;      % end of swarm i
            j=k-N+1;    % start of swarm i
            
            [aR,bR]=max(fitR(j:k,:));
            
            gBestR(i,:)=xR(j-1+bR,:);
            gbestvalueR(i,1)= fitR(j-1+bR);
            
            xBestR = xR;
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(fitR);
            end
            
            [aG,bG]=max(fitG(j:k,:));
            
            gBestG(i,:)=xG(j-1+bG,:);
            gbestvalueG(i,1)= fitG(j-1+bG);
            
            xBestG = xG;
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOG,i_gbestvalue_DPSOG]=max(fitG);
            end
            
            [aB,bB]=max(fitB(j:k,:));
            
            gBestB(i,:)=xB(j-1+bB,:);
            gbestvalueB(i,1)= fitB(j-1+bB);
            
            xBestB = xB;
            
            if i==N_SWARMS % (last iteration - save the best particle from all swarms):
                [gbestvalue_DPSOB,i_gbestvalue_DPSOB]=max(fitB);
            end
        end
        xBestR = xR;
        xBestG = xG;
        xBestB = xB;
    end
        
    % N change depending on the swarm and the color component
    NR(1:N_SWARMSR,1)=N;
    NG(1:N_SWARMSG,1)=N;
    NB(1:N_SWARMSB,1)=N;
    
    %stagancy of each swarm
    stagnancy_counterR=zeros(N_SWARMSR,1);
    stagnancy_counterG=zeros(N_SWARMSG,1);
    stagnancy_counterB=zeros(N_SWARMSB,1);
    
    %number of particles deleted
    already_deletedR=zeros(N_SWARMSR,1);
    already_deletedG=zeros(N_SWARMSG,1);
    already_deletedB=zeros(N_SWARMSB,1);
    
    nger=1;                 % current iteration
    
    while(nger<=N_GER)
        
        i=1;
        while ((i<=max([N_SWARMSR,N_SWARMSG, N_SWARMSB])))
           
            if (i<=N_SWARMSR)
                kR=(sum(NR(1:i)));              % end of swarm i R
                jR=kR-NR(i)+1;                   % start of swarm i R
            end
            
            if (i<=N_SWARMSG)
                kG=(sum(NG(1:i)));              % end of swarm i G 
                jG=kG-NG(i)+1;                   % start of swarm i G
            end
            
            if (i<=N_SWARMSB)
                kB=(sum(NB(1:i)));              % end of swarm i B
                jB=kB-NB(i)+1;                   % start of swarm i B
            end
            
            % current swarm
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    v_swarmR = vR(jR:kR,:);
                    v_swarmR_1 = vR_1(jR:kR,:);
                    v_swarmR_2 = vR_2(jR:kR,:);
                    v_swarmR_3 = vR_3(jR:kR,:);
                    gBest_swarmR = gBestR(i,:);
                    gbestvalue_swarmR = gbestvalueR(i,1);
                    x_swarmR = xR(jR:kR,:);
                    xBest_swarmR = xBestR(jR:kR,:);
                    fit_swarmR = fitR(jR:kR,:);
                    fitBest_swarmR = fitBestR(jR:kR,:);
                    gaux_swarmR = ones(NR(i),1);
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    v_swarmR = vR(jR:kR,:);
                    v_swarmR_1 = vR_1(jR:kR,:);
                    v_swarmR_2 = vR_2(jR:kR,:);
                    v_swarmR_3 = vR_3(jR:kR,:);
                    gBest_swarmR = gBestR(i,:);
                    gbestvalue_swarmR = gbestvalueR(i,1);
                    x_swarmR = xR(jR:kR,:);
                    xBest_swarmR = xBestR(jR:kR,:);
                    fit_swarmR = fitR(jR:kR,:);
                    fitBest_swarmR = fitBestR(jR:kR,:);
                    gaux_swarmR = ones(NR(i),1);
                end
                
                if (i<=N_SWARMSG)
                    v_swarmG = vG(jG:kG,:);
                    v_swarmG_1 = vG_1(jG:kG,:);
                    v_swarmG_2 = vG_2(jG:kG,:);
                    v_swarmG_3 = vG_3(jG:kG,:);
                    gBest_swarmG = gBestG(i,:);
                    gbestvalue_swarmG = gbestvalueG(i,1);
                    x_swarmG = xG(jG:kG,:);
                    xBest_swarmG = xBestG(jG:kG,:);
                    fit_swarmG = fitG(jG:kG,:);
                    fitBest_swarmG = fitBestG(jG:kG,:);
                    gaux_swarmG = ones(NG(i),1);
                end
                
                if (i<=N_SWARMSB)
                    v_swarmB = vB(jB:kB,:);
                    v_swarmB_1 = vB_1(jB:kB,:);
                    v_swarmB_2 = vB_2(jB:kB,:);
                    v_swarmB_3 = vB_3(jB:kB,:);
                    gBest_swarmB = gBestB(i,:);
                    gbestvalue_swarmB = gbestvalueB(i,1);
                    x_swarmB = xB(jB:kB,:);
                    xBest_swarmB = xBestB(jB:kB,:);
                    fit_swarmB = fitB(jB:kB,:);
                    fitBest_swarmB = fitBestB(jB:kB,:);
                    gaux_swarmB = ones(NB(i),1);
                end
            end
            
            if (i<=N_SWARMSR)
                randnum1R = rand ([NR(i), N_PAR]);
                randnum2R = rand ([NR(i), N_PAR]);
            end
            
            if (i<=N_SWARMSG)
                randnum1G = rand ([NG(i), N_PAR]);
                randnum2G = rand ([NG(i), N_PAR]);
            end
            
            if (i<=N_SWARMSB)
                randnum1B = rand ([NB(i), N_PAR]);
                randnum2B = rand ([NB(i), N_PAR]);
            end
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    v_swarmR = fix(alfa*v_swarmR + (1/2)*alfa*v_swarmR_1 + (1/6)*alfa*(1-alfa)*v_swarmR_2 + ...
                        (1/24)*alfa*(1-alfa)*(2-alfa)*v_swarmR_3 + randnum1R.*(PHI1.*(xBest_swarmR-x_swarmR)) +...
                        randnum2R.*(PHI2.*(gaux_swarmR*gBest_swarmR-x_swarmR)));
                    v_swarmR = ( (v_swarmR <= vmin).*vmin ) + ( (v_swarmR > vmin).*v_swarmR );
                    v_swarmR = ( (v_swarmR >= vmax).*vmax ) + ( (v_swarmR < vmax).*v_swarmR );
                    v_swarmR_3=v_swarmR_2;
                    v_swarmR_2=v_swarmR_1;
                    v_swarmR_1=v_swarmR;
                    x_swarmR = round(x_swarmR+v_swarmR);
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    v_swarmR = fix(alfa*v_swarmR + (1/2)*alfa*v_swarmR_1 + (1/6)*alfa*(1-alfa)*v_swarmR_2 + ...
                        (1/24)*alfa*(1-alfa)*(2-alfa)*v_swarmR_3 + randnum1R.*(PHI1.*(xBest_swarmR-x_swarmR)) + ...
                        randnum2R.*(PHI2.*(gaux_swarmR*gBest_swarmR-x_swarmR)));
                    v_swarmR = ( (v_swarmR <= vmin).*vmin ) + ( (v_swarmR > vmin).*v_swarmR );
                    v_swarmR = ( (v_swarmR >= vmax).*vmax ) + ( (v_swarmR < vmax).*v_swarmR );
                    v_swarmR_3=v_swarmR_2;
                    v_swarmR_2=v_swarmR_1;
                    v_swarmR_1=v_swarmR;
                    x_swarmR = round(x_swarmR+v_swarmR);
                end
                
                if (i<=N_SWARMSG)
                    v_swarmG = fix(alfa*v_swarmG + (1/2)*alfa*v_swarmG_1 + (1/6)*alfa*(1-alfa)*v_swarmG_2 + ...
                        (1/24)*alfa*(1-alfa)*(2-alfa)*v_swarmG_3 + randnum1G.*(PHI1.*(xBest_swarmG-x_swarmG)) + ...
                        randnum2G.*(PHI2.*(gaux_swarmG*gBest_swarmG-x_swarmG)));
                    v_swarmG = ( (v_swarmG <= vmin).*vmin ) + ( (v_swarmG > vmin).*v_swarmG );
                    v_swarmG = ( (v_swarmG >= vmax).*vmax ) + ( (v_swarmG < vmax).*v_swarmG );
                    v_swarmG_3=v_swarmG_2;
                    v_swarmG_2=v_swarmG_1;
                    v_swarmG_1=v_swarmG;
                    x_swarmG = round(x_swarmG+v_swarmG);
                end
                
                if (i<=N_SWARMSB)
                    v_swarmB = fix(alfa*v_swarmB + (1/2)*alfa*v_swarmB_1 + (1/6)*alfa*(1-alfa)*v_swarmB_2 + ...
                        (1/24)*alfa*(1-alfa)*(2-alfa)*v_swarmB_3 + randnum1B.*(PHI1.*(xBest_swarmB-x_swarmB)) + ...
                        randnum2B.*(PHI2.*(gaux_swarmB*gBest_swarmB-x_swarmB)));
                    v_swarmB = ( (v_swarmB <= vmin).*vmin ) + ( (v_swarmB > vmin).*v_swarmB );
                    v_swarmB = ( (v_swarmB >= vmax).*vmax ) + ( (v_swarmB < vmax).*v_swarmB );
                    v_swarmB_3=v_swarmB_2;
                    v_swarmB_2=v_swarmB_1;
                    v_swarmB_1=v_swarmB;
                    x_swarmB = round(x_swarmB+v_swarmB);
                end
            end
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    x_swarmR = ( (x_swarmR <= X_MINR(1)).*X_MINR(1) ) + ( (x_swarmR > X_MINR(1)).*x_swarmR );
                    x_swarmR = ( (x_swarmR >= X_MAXR(1)).*X_MAXR(1) ) + ( (x_swarmR < X_MAXR(1)).*x_swarmR );
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    x_swarmR = ( (x_swarmR <= X_MINR(1)).*X_MINR(1) ) + ( (x_swarmR > X_MINR(1)).*x_swarmR );
                    x_swarmR = ( (x_swarmR >= X_MAXR(1)).*X_MAXR(1) ) + ( (x_swarmR < X_MAXR(1)).*x_swarmR );
                end
                
                if (i<=N_SWARMSG)
                    x_swarmG = ( (x_swarmG <= X_MING(1)).*X_MING(1) ) + ( (x_swarmG > X_MING(1)).*x_swarmG );
                    x_swarmG = ( (x_swarmG >= X_MAXG(1)).*X_MAXG(1) ) + ( (x_swarmG < X_MAXG(1)).*x_swarmG );
                end
                
                if (i<=N_SWARMSB)
                    x_swarmB = ( (x_swarmB <= X_MINB(1)).*X_MINB(1) ) + ( (x_swarmB > X_MINB(1)).*x_swarmB );
                    x_swarmB = ( (x_swarmB >= X_MAXB(1)).*X_MAXB(1) ) + ( (x_swarmB < X_MAXB(1)).*x_swarmB );
                end
            end
            
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    for jj = 1:NR(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                        end
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    for jj = 1:NR(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > x_swarmR(jj,kk+1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk+1);
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmR(jj,kk) < x_swarmR(jj,kk-1)
                                    x_swarmR(jj,kk) = x_swarmR(jj,kk-1);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmR(jj,kk) < X_MINR(kk)
                                    x_swarmR(jj,kk) = X_MINR(kk);
                                elseif x_swarmR(jj,kk) > X_MAXR(kk)
                                    x_swarmR(jj,kk) = X_MAXR(kk);
                                end
                            end
                        end
                    end
                end
                
                if (i<=N_SWARMSG)
                    for jj = 1:NG(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmG(jj,kk) < X_MING(kk)
                                    x_swarmG(jj,kk) = X_MING(kk);
                                elseif x_swarmG(jj,kk) > x_swarmG(jj,kk+1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmG(jj,kk) < x_swarmG(jj,kk-1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmG(jj,kk) > x_swarmG(jj,kk+1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmG(jj,kk) < x_swarmG(jj,kk-1)
                                    x_swarmG(jj,kk) = x_swarmG(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmG(jj,kk) > X_MAXG(kk)
                                    x_swarmG(jj,kk) = X_MAXG(kk);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmG(jj,kk) < X_MING(kk)
                                    x_swarmG(jj,kk) = X_MING(kk);
                                elseif x_swarmG(jj,kk) > X_MAXG(kk)
                                    x_swarmG(jj,kk) = X_MAXG(kk);
                                end
                            end
                        end
                    end
                end
                   
                if (i<=N_SWARMSB)
                    for jj = 1:NB(i)
                        for kk = 1:N_PAR
                            if (kk==1)&&(kk~=N_PAR)
                                if x_swarmB(jj,kk) < X_MINB(kk)
                                    x_swarmB(jj,kk) = X_MINB(kk);
                                    %                         disp ('passou o min');
                                elseif x_swarmB(jj,kk) > x_swarmB(jj,kk+1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if ((kk>1)&&(kk<N_PAR))
                                if x_swarmB(jj,kk) < x_swarmB(jj,kk-1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmB(jj,kk) > x_swarmB(jj,kk+1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk+1);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==N_PAR)&&(kk~=1)
                                if x_swarmB(jj,kk) < x_swarmB(jj,kk-1)
                                    x_swarmB(jj,kk) = x_swarmB(jj,kk-1);
                                    %                         disp ('passou o min');
                                elseif x_swarmB(jj,kk) > X_MAXB(kk)
                                    x_swarmB(jj,kk) = X_MAXB(kk);
                                    %                         disp ('passou o max');
                                end
                            end
                            if (kk==1)&&(kk==N_PAR)
                                if x_swarmB(jj,kk) < X_MINB(kk)
                                    x_swarmB(jj,kk) = X_MINB(kk);
                                elseif x_swarmB(jj,kk) > X_MAXB(kk)
                                    x_swarmB(jj,kk) = X_MAXB(kk);
                                end
                            end
                        end
                    end
                end
            end

            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    for jj=1:NR(i)
                        fit_swarmR(jj)=sum(probR(1:x_swarmR(jj,1)))*(sum((1:x_swarmR(jj,1)).*probR(1:x_swarmR(jj,1))/sum(probR(1:x_swarmR(jj,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)))*(sum((x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)).*probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))/sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,level-1)+1:Lmax))*(sum((x_swarmR(jj,level-1)+1:Lmax).*probR(x_swarmR(jj,level-1)+1:Lmax)/sum(probR(x_swarmR(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        if fit_swarmR(jj) > fitBest_swarmR(jj)
                            fitBest_swarmR(jj) = fit_swarmR(jj);
                            xBest_swarmR(jj,:) = x_swarmR(jj,:);
                        end
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    for jj=1:NR(i)
                        fit_swarmR(jj)=sum(probR(1:x_swarmR(jj,1)))*(sum((1:x_swarmR(jj,1)).*probR(1:x_swarmR(jj,1))/sum(probR(1:x_swarmR(jj,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)))*(sum((x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel)).*probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))/sum(probR(x_swarmR(jj,jlevel-1)+1:x_swarmR(jj,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(jj)=fit_swarmR(jj)+sum(probR(x_swarmR(jj,level-1)+1:Lmax))*(sum((x_swarmR(jj,level-1)+1:Lmax).*probR(x_swarmR(jj,level-1)+1:Lmax)/sum(probR(x_swarmR(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        if fit_swarmR(jj) > fitBest_swarmR(jj)
                            fitBest_swarmR(jj) = fit_swarmR(jj);
                            xBest_swarmR(jj,:) = x_swarmR(jj,:);
                        end
                    end
                end
                
                if (i<=N_SWARMSG)
                    for jj=1:NG(i)
                        fit_swarmG(jj)=sum(probG(1:x_swarmG(jj,1)))*(sum((1:x_swarmG(jj,1)).*probG(1:x_swarmG(jj,1))/sum(probG(1:x_swarmG(jj,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmG(jj)=fit_swarmG(jj)+sum(probG(x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel)))*(sum((x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel)).*probG(x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel))/sum(probG(x_swarmG(jj,jlevel-1)+1:x_swarmG(jj,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        end
                        fit_swarmG(jj)=fit_swarmG(jj)+sum(probG(x_swarmG(jj,level-1)+1:Lmax))*(sum((x_swarmG(jj,level-1)+1:Lmax).*probG(x_swarmG(jj,level-1)+1:Lmax)/sum(probG(x_swarmG(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        if fit_swarmG(jj) > fitBest_swarmG(jj)
                            fitBest_swarmG(jj) = fit_swarmG(jj);
                            xBest_swarmG(jj,:) = x_swarmG(jj,:);
                        end
                    end
                end
                
                if (i<=N_SWARMSB)
                    for jj=1:NB(i)
                        fit_swarmB(jj)=sum(probB(1:x_swarmB(jj,1)))*(sum((1:x_swarmB(jj,1)).*probB(1:x_swarmB(jj,1))/sum(probB(1:x_swarmB(jj,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmB(jj)=fit_swarmB(jj)+sum(probB(x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel)))*(sum((x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel)).*probB(x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel))/sum(probB(x_swarmB(jj,jlevel-1)+1:x_swarmB(jj,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        end
                        fit_swarmB(jj)=fit_swarmB(jj)+sum(probB(x_swarmB(jj,level-1)+1:Lmax))*(sum((x_swarmB(jj,level-1)+1:Lmax).*probB(x_swarmB(jj,level-1)+1:Lmax)/sum(probB(x_swarmB(jj,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        if fit_swarmB(jj) > fitBest_swarmB(jj)
                            fitBest_swarmB(jj) = fit_swarmB(jj);
                            xBest_swarmB(jj,:) = x_swarmB(jj,:);
                        end
                    end
                end
                    
            end
            
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    [aR,bR] = max (fit_swarmR);
                    if (fit_swarmR(bR) > gbestvalue_swarmR)
                        gBest_swarmR=x_swarmR(bR,:)-1;
                        gbestvalue_swarmR = fit_swarmR(bR);
                        stagnancy_counterR(i)=0;
                    else
                        stagnancy_counterR(i)=stagnancy_counterR(i)+1;      % didn't improve
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    [aR,bR] = max (fit_swarmR);
                    if (fit_swarmR(bR) > gbestvalue_swarmR)
                        gBest_swarmR=x_swarmR(bR,:)-1;
                        gbestvalue_swarmR = fit_swarmR(bR);
                        stagnancy_counterR(i)=0;
                    else
                        stagnancy_counterR(i)=stagnancy_counterR(i)+1;      % didn't improve
                    end
                end
                
                if (i<=N_SWARMSG)
                    [aG,bG] = max (fit_swarmG);
                    if (fit_swarmG(bG) > gbestvalue_swarmG)
                        gBest_swarmG=x_swarmG(bG,:)-1;
                        gbestvalue_swarmG = fit_swarmG(bG);
                        stagnancy_counterG(i)=0;
                    else
                        stagnancy_counterG(i)=stagnancy_counterG(i)+1;      % didn't improve
                    end
                end
                
                if (i<=N_SWARMSB)
                    [aB,bB] = max (fit_swarmB);
                    if (fit_swarmB(bB) > gbestvalue_swarmB)
                        gBest_swarmB=x_swarmB(bB,:)-1;
                        gbestvalue_swarmB = fit_swarmB(bB);
                        stagnancy_counterB(i)=0;
                    else
                        stagnancy_counterB(i)=stagnancy_counterB(i)+1;      % didn't improve
                    end
                end
            end
            
            % evaluate swarm i:
            manteveR = 1;
            manteveG = 1;
            manteveB = 1;
            
            
            % create a new particle if possible
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && NR(i)<MAX_POP )
                        % create particle
                        NR(i)=NR(i)+1; %new swarm size
                        x_swarmR(NR(i),:) = fix(rand(1,1) * ( X_MAXR(:)-X_MINR(:) ) + X_MINR(:));  %new particle
                        v_swarmR(NR(i),:) = zeros (1,N_PAR);
                        v_swarmR_1(NR(i),:) = zeros (1,N_PAR);
                        v_swarmR_2(NR(i),:) = zeros (1,N_PAR);
                        v_swarmR_3(NR(i),:) = zeros (1,N_PAR);
                        xBest_swarmR(NR(i),:) = x_swarmR(NR(i),:);     %local best
                        fit_swarmR(NR(i))=sum(probR(1:x_swarmR(NR(i),1)))*(sum((1:x_swarmR(NR(i),1)).*probR(1:x_swarmR(NR(i),1))/sum(probR(1:x_swarmR(NR(i),1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)))*(sum((x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)).*probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))/sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),level-1)+1:Lmax))*(sum((x_swarmR(NR(i),level-1)+1:Lmax).*probR(x_swarmR(NR(i),level-1)+1:Lmax)/sum(probR(x_swarmR(NR(i),level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        [aR,bR]=max(fit_swarmR);
                        gBest_swarmR=x_swarmR(bR,:);
                        gbestvalue_swarmR = fit_swarmR(bR);
                        xBest_swarmR = x_swarmR;
                        fitBest_swarmR(NR(i),:)=fit_swarmR(NR(i),:);
                        % re-create tables
                        vR=insertrows(vR,v_swarmR(NR(i),:),k);
                        vR(jR:kR+1,:) = v_swarmR;
                        vR_1=insertrows(vR_1,v_swarmR_1(NR(i),:),kR);
                        vR_1(jR:kR+1,:) = v_swarmR_1;
                        vR_2=insertrows(vR_2,v_swarmR_2(NR(i),:),kR);
                        vR_2(jR:kR+1,:) = v_swarmR_2;
                        vR_3=insertrows(vR_3,v_swarmR_3(NR(i),:),kR);
                        vR_3(jR:kR+1,:) = v_swarmR_3;
                        xR=insertrows(xR,x_swarmR(NR(i),:),k);
                        xR(jR:kR+1,:) = x_swarmR;
                        xBestR=insertrows(xBestR,xBest_swarmR(NR(i),:),k);
                        xBestR(jR:kR+1,:) = xBest_swarmR;
                        fitR=insertrows(fitR,fit_swarmR(NR(i),:),k);
                        fitR(jR:kR+1,:) = fit_swarmR;
                        fitBestR=insertrows(fitBestR,fitBest_swarmR(NR(i),:),k);
                        fitBestR(jR:kR+1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR+1;
                        manteveR = 0;
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && NR(i)<MAX_POP )
                        % create particle
                        NR(i)=NR(i)+1; %new swarm size
                        x_swarmR(NR(i),:) = fix(rand(1,1) * ( X_MAXR(:)-X_MINR(:) ) + X_MINR(:));  %new particle
                        v_swarmR(NR(i),:) = zeros (1,N_PAR);
                        v_swarmR_1(NR(i),:) = zeros (1,N_PAR);
                        v_swarmR_2(NR(i),:) = zeros (1,N_PAR);
                        v_swarmR_3(NR(i),:) = zeros (1,N_PAR);
                        xBest_swarmR(NR(i),:) = x_swarmR(NR(i),:);     %local best
                        fit_swarmR(NR(i))=sum(probR(1:x_swarmR(NR(i),1)))*(sum((1:x_swarmR(NR(i),1)).*probR(1:x_swarmR(NR(i),1))/sum(probR(1:x_swarmR(NR(i),1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)))*(sum((x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel)).*probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))/sum(probR(x_swarmR(NR(i),jlevel-1)+1:x_swarmR(NR(i),jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        end
                        fit_swarmR(NR(i))=fit_swarmR(NR(i))+sum(probR(x_swarmR(NR(i),level-1)+1:Lmax))*(sum((x_swarmR(NR(i),level-1)+1:Lmax).*probR(x_swarmR(NR(i),level-1)+1:Lmax)/sum(probR(x_swarmR(NR(i),level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                        [aR,bR]=max(fit_swarmR);
                        gBest_swarmR=x_swarmR(bR,:);
                        gbestvalue_swarmR = fit_swarmR(bR);
                        xBest_swarmR = x_swarmR;
                        fitBest_swarmR(NR(i),:)=fit_swarmR(NR(i),:);
                        % re-create tables
                        vR=insertrows(vR,v_swarmR(NR(i),:),kR);
                        vR(jR:kR+1,:) = v_swarmR;
                        vR_1=insertrows(vR_1,v_swarmR_1(NR(i),:),kR);
                        vR_1(jR:kR+1,:) = v_swarmR_1;
                        vR_2=insertrows(vR_2,v_swarmR_2(NR(i),:),kR);
                        vR_2(jR:kR+1,:) = v_swarmR_2;
                        vR_3=insertrows(vR_3,v_swarmR_3(NR(i),:),kR);
                        vR_3(jR:kR+1,:) = v_swarmR_3;
                        xR=insertrows(xR,x_swarmR(NR(i),:),kR);
                        xR(jR:kR+1,:) = x_swarmR;
                        xBestR=insertrows(xBestR,xBest_swarmR(NR(i),:),kR);
                        xBestR(jR:kR+1,:) = xBest_swarmR;
                        fitR=insertrows(fitR,fit_swarmR(NR(i),:),kR);
                        fitR(jR:kR+1,:) = fit_swarmR;
                        fitBestR=insertrows(fitBestR,fitBest_swarmR(NR(i),:),kR);
                        fitBestR(jR:kR+1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR+1;
                        manteveR = 0;
                    end
                end
                
                if (i<=N_SWARMSG)
                    if( stagnancy_counterG(i)==0 && NG(i)<MAX_POP )
                        % create particle
                        NG(i)=NG(i)+1; %new swarm size
                        x_swarmG(NG(i),:) = fix(rand(1,1) * ( X_MAXG(:)-X_MING(:) ) + X_MING(:));  %new particle
                        v_swarmG(NG(i),:) = zeros (1,N_PAR);
                        v_swarmG_1(NG(i),:) = zeros (1,N_PAR);
                        v_swarmG_2(NG(i),:) = zeros (1,N_PAR);
                        v_swarmG_3(NG(i),:) = zeros (1,N_PAR);
                        xBest_swarmG(NG(i),:) = x_swarmG(NG(i),:);     %local best
                        fit_swarmG(NG(i))=sum(probG(1:x_swarmG(NG(i),1)))*(sum((1:x_swarmG(NG(i),1)).*probG(1:x_swarmG(NG(i),1))/sum(probG(1:x_swarmG(NG(i),1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmG(NG(i))=fit_swarmG(NG(i))+sum(probG(x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel)))*(sum((x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel)).*probG(x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel))/sum(probG(x_swarmG(NG(i),jlevel-1)+1:x_swarmG(NG(i),jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        end
                        fit_swarmG(NG(i))=fit_swarmG(NG(i))+sum(probG(x_swarmG(NG(i),level-1)+1:Lmax))*(sum((x_swarmG(NG(i),level-1)+1:Lmax).*probG(x_swarmG(NG(i),level-1)+1:Lmax)/sum(probG(x_swarmG(NG(i),level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
                        [aG,bG]=max(fit_swarmG);
                        gBest_swarmG=x_swarmG(bG,:);
                        gbestvalue_swarmG = fit_swarmG(bG);
                        xBest_swarmG = x_swarmG;
                        fitBest_swarmG(NG(i),:)=fit_swarmG(NG(i),:);
                        % re-create tables
                        vG=insertrows(vG,v_swarmG(NG(i),:),kG);
                        vG(jG:kG+1,:) = v_swarmG;
                        vG_1=insertrows(vG_1,v_swarmG_1(NG(i),:),kG);
                        vG_1(jG:kG+1,:) = v_swarmG_1;
                        vG_2=insertrows(vG_2,v_swarmG_2(NG(i),:),kG);
                        vG_2(jG:kG+1,:) = v_swarmG_2;
                        vG_3=insertrows(vG_3,v_swarmG_3(NG(i),:),kG);
                        vG_3(jG:kG+1,:) = v_swarmG_3;
                        xG=insertrows(xG,x_swarmG(NG(i),:),kG);
                        xG(jG:kG+1,:) = x_swarmG;
                        xBestG=insertrows(xBestG,xBest_swarmG(NG(i),:),kG);
                        xBestG(jG:kG+1,:) = xBest_swarmG;
                        fitG=insertrows(fitG,fit_swarmG(NG(i),:),kG);
                        fitG(jG:kG+1,:) = fit_swarmG;
                        fitBestG=insertrows(fitBestG,fitBest_swarmG(NG(i),:),kG);
                        fitBestG(jG:kG+1,:) = fitBest_swarmG;
                        gBestG(i,:)=gBest_swarmG;
                        gbestvalueG(i,:)=gbestvalue_swarmG;
                        kG=kG+1;
                        manteveG = 0;
                    end
                end
                
                if (i<=N_SWARMSB)
                    if( stagnancy_counterB(i)==0 && NB(i)<MAX_POP )
                        % create particle
                        NB(i)=NB(i)+1; %new swarm size
                        x_swarmB(NB(i),:) = fix(rand(1,1) * ( X_MAXB(:)-X_MINB(:) ) + X_MINB(:));  %new particle
                        v_swarmB(NB(i),:) = zeros (1,N_PAR);
                        v_swarmB_1(NB(i),:) = zeros (1,N_PAR);
                        v_swarmB_2(NB(i),:) = zeros (1,N_PAR);
                        v_swarmB_3(NB(i),:) = zeros (1,N_PAR);
                        xBest_swarmB(NB(i),:) = x_swarmB(NB(i),:);     %local best
                        fit_swarmB(NB(i))=sum(probB(1:x_swarmB(NB(i),1)))*(sum((1:x_swarmB(NB(i),1)).*probB(1:x_swarmB(NB(i),1))/sum(probB(1:x_swarmB(NB(i),1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
                        for jlevel=2:level-1
                            fit_swarmB(NB(i))=fit_swarmB(NB(i))+sum(probB(x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel)))*(sum((x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel)).*probB(x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel))/sum(probB(x_swarmB(NB(i),jlevel-1)+1:x_swarmB(NB(i),jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        end
                        fit_swarmB(NB(i))=fit_swarmB(NB(i))+sum(probB(x_swarmB(NB(i),level-1)+1:Lmax))*(sum((x_swarmB(NB(i),level-1)+1:Lmax).*probB(x_swarmB(NB(i),level-1)+1:Lmax)/sum(probB(x_swarmB(NB(i),level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
                        [aB,bB]=max(fit_swarmB);
                        gBest_swarmB=x_swarmB(bB,:);
                        gbestvalue_swarmB = fit_swarmB(bB);
                        xBest_swarmB = x_swarmB;
                        fitBest_swarmB(NB(i),:)=fit_swarmB(NB(i),:);
                        % re-create tables
                        vB=insertrows(vB,v_swarmB(NB(i),:),kB);
                        vB(jB:kB+1,:) = v_swarmB;
                        vB_1=insertrows(vB_1,v_swarmB_1(NB(i),:),kB);
                        vB_1(jB:kB+1,:) = v_swarmB_1;
                        vB_2=insertrows(vB_2,v_swarmB_2(NB(i),:),kB);
                        vB_2(jB:kB+1,:) = v_swarmB_2;
                        vB_3=insertrows(vB_3,v_swarmB_3(NB(i),:),kB);
                        vB_3(jB:kB+1,:) = v_swarmB_3;
                        xB=insertrows(xB,x_swarmB(NB(i),:),kB);
                        xB(jB:kB+1,:) = x_swarmB;
                        xBestB=insertrows(xBestB,xBest_swarmB(NB(i),:),kB);
                        xBestB(jB:kB+1,:) = xBest_swarmB;
                        fitB=insertrows(fitB,fit_swarmB(NB(i),:),kB);
                        fitB(jB:kB+1,:) = fit_swarmB;
                        fitBestB=insertrows(fitBestB,fitBest_swarmB(NB(i),:),kB);
                        fitBestB(jB:kB+1,:) = fitBest_swarmB;
                        gBestB(i,:)=gBest_swarmB;
                        gbestvalueB(i,:)=gbestvalue_swarmB;
                        kB=kB+1;
                        manteveB = 0;
                    end
                end
            end
            
            
            % create a new swarm  
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && already_deletedR(i)==0 && N_SWARMSR < MAX_SWARMS )
                        p=rand/N_SWARMSR;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NR(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NR(i),1);
                                x_nova(n,:) = x_swarmR(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSR,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSR,1);
                            end
                            inicio=sum( NR(1:swarm_aleatoria-1) );
                            for m=1:ceil( NR(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi ( NR(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xR(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXR-X_MINR ) + X_MINR));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSR = N_SWARMSR+1;   % refresh number of swarms
                            NR(N_SWARMSR) = m;        % population of the new swarm
                            n=size(xR,1);
                            o=n;
                            xR=[xR;x_nova];            % positions of the new particles
                            xBestR=[xBestR;x_nova];    % best position of new particles
                            vR=[vR;zeros(m,N_PAR)];    % initial velocity of new particles
                            vR_1=[vR_1;zeros(m,N_PAR)];
                            vR_2=[vR_2;zeros(m,N_PAR)];
                            vR_3=[vR_3;zeros(m,N_PAR)];
                            for n=o+1:o+m
                                fitR(n)=sum(probR(1:xR(n,1)))*(sum((1:xR(n,1)).*probR(1:xR(n,1))/sum(probR(1:xR(n,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitR(n)=fitR(n)+sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel)))*(sum((xR(n,jlevel-1)+1:xR(n,jlevel)).*probR(xR(n,jlevel-1)+1:xR(n,jlevel))/sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                end
                                fitR(n)=fitR(n)+sum(probR(xR(n,level-1)+1:Lmax))*(sum((xR(n,level-1)+1:Lmax).*probR(xR(n,level-1)+1:Lmax)/sum(probR(xR(n,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                fitBestR(n)=fitR(n);
                            end
                            [aR,bR]=max(fitR(o+1:o+m,:));
                            gBestR(N_SWARMSR,:)=xR(o+bR,:);
                            gbestvalueR(N_SWARMSR,1) = fitR(o+bR);
                            already_deletedR(N_SWARMSR)=0;
                            stagnancy_counterR(N_SWARMSR)=0;
                            clear x_nova;
                        end
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if( stagnancy_counterR(i)==0 && already_deletedR(i)==0 && N_SWARMSR < MAX_SWARMS )
                        p=rand/N_SWARMSR;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NR(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NR(i),1);
                                x_nova(n,:) = x_swarmR(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSR,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSR,1);
                            end
                            inicio=sum( NR(1:swarm_aleatoria-1) );
                            for m=1:ceil( NR(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi ( NR(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xR(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXR-X_MINR ) + X_MINR));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSR = N_SWARMSR+1;   % refresh number of swarms
                            NR(N_SWARMSR) = m;        % population of the new swarm
                            n=size(xR,1);
                            o=n;
                            xR=[xR;x_nova];            % positions of the new particles
                            xBestR=[xBestR;x_nova];    % best position of new particles
                            vR=[vR;zeros(m,N_PAR)];    % initial velocity of new particles
                            vR_1=[vR_1;zeros(m,N_PAR)];
                            vR_2=[vR_2;zeros(m,N_PAR)];
                            vR_3=[vR_3;zeros(m,N_PAR)];
                            for n=o+1:o+m
                                fitR(n)=sum(probR(1:xR(n,1)))*(sum((1:xR(n,1)).*probR(1:xR(n,1))/sum(probR(1:xR(n,1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitR(n)=fitR(n)+sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel)))*(sum((xR(n,jlevel-1)+1:xR(n,jlevel)).*probR(xR(n,jlevel-1)+1:xR(n,jlevel))/sum(probR(xR(n,jlevel-1)+1:xR(n,jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                end
                                fitR(n)=fitR(n)+sum(probR(xR(n,level-1)+1:Lmax))*(sum((xR(n,level-1)+1:Lmax).*probR(xR(n,level-1)+1:Lmax)/sum(probR(xR(n,level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
                                fitBestR(n)=fitR(n);
                            end
                            [aR,bR]=max(fitR(o+1:o+m,:));
                            gBestR(N_SWARMSR,:)=xR(o+bR,:);
                            gbestvalueR(N_SWARMSR,1) = fitR(o+bR);
                            already_deletedR(N_SWARMSR)=0;
                            stagnancy_counterR(N_SWARMSR)=0;
                            clear x_nova;
                        end
                    end
                end
                   
                if (i<=N_SWARMSG)
                    if( stagnancy_counterG(i)==0 && already_deletedG(i)==0 && N_SWARMSG < MAX_SWARMS )
                        p=rand/N_SWARMSG;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NG(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NG(i),1);
                                x_nova(n,:) = x_swarmG(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSG,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSG,1);
                            end
                            inicio=sum( NG(1:swarm_aleatoria-1) );
                            for m=1:ceil( NG(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi( NG(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xG(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXG-X_MING ) + X_MING));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSG = N_SWARMSG+1;   % refresh number of swarms
                            NG(N_SWARMSG) = m;        % population of the new swarm
                            n=size(xG,1);
                            o=n;
                            xG=[xG;x_nova];            % positions of the new particles
                            xBestG=[xBestG;x_nova];    % best position of new particles
                            vG=[vG;zeros(m,N_PAR)];    % initial velocity of new particles
                            vG_1=[vG_1;zeros(m,N_PAR)];
                            vG_2=[vG_2;zeros(m,N_PAR)];
                            vG_3=[vG_3;zeros(m,N_PAR)];
                            for n=o+1:o+m
                                fitG(n)=sum(probG(1:xG(n,1)))*(sum((1:xG(n,1)).*probG(1:xG(n,1))/sum(probG(1:xG(n,1)))) - sum((1:Lmax).*probG(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitG(n)=fitG(n)+sum(probG(xG(n,jlevel-1)+1:xG(n,jlevel)))*(sum((xG(n,jlevel-1)+1:xG(n,jlevel)).*probG(xG(n,jlevel-1)+1:xG(n,jlevel))/sum(probG(xG(n,jlevel-1)+1:xG(n,jlevel))))- sum((1:Lmax).*probG(1:Lmax)))^2;
                                end
                                fitG(n)=fitG(n)+sum(probG(xG(n,level-1)+1:Lmax))*(sum((xG(n,level-1)+1:Lmax).*probG(xG(n,level-1)+1:Lmax)/sum(probG(xG(n,level-1)+1:Lmax)))- sum((1:Lmax).*probG(1:Lmax)))^2;
                                fitBestG(n)=fitG(n);
                            end
                            [aG,bG]=max(fitG(o+1:o+m,:));
                            gBestG(N_SWARMSG,:)=xG(o+bG,:);
                            gbestvalueG(N_SWARMSG,1) = fitG(o+bG);
                            already_deletedG(N_SWARMSG)=0;
                            stagnancy_counterG(N_SWARMSG)=0;
                            clear x_nova;
                        end
                    end
                end
                
                if (i<=N_SWARMSB)
                    if( stagnancy_counterB(i)==0 && already_deletedB(i)==0 && N_SWARMSB < MAX_SWARMS )
                        p=rand/N_SWARMSB;
                        cria_swarm=rand;
                        if (cria_swarm<=p)  %probability p of creating a new swarm
                            %half of the parent's particles are selected at random for the
                            %child swarm and half of the particles of a random member of the
                            %swarm collection are also selected. If the swarm initial population
                            %number is not obtained, the rest of the particles are randomly
                            %initialized and added to the new swarm:
                            for n=1:ceil( NB(i)/2 )   % randomly choose half of the particles from the parent swarm
                                idx_parent = randi (NB(i),1);
                                x_nova(n,:) = x_swarmB(idx_parent,:);
                            end
                            % choose random swarm and get half of its particles
                            swarm_aleatoria = randi(N_SWARMSB,1);
                            % n is the parent swarm
                            while (swarm_aleatoria == i)
                                swarm_aleatoria = randi(N_SWARMSB,1);
                            end
                            inicio=sum( NB(1:swarm_aleatoria-1) );
                            for m=1:ceil( NB(swarm_aleatoria)/2 )   % randomly choose half of the particles from the swarm
                                idx_parent = randi ( NB(swarm_aleatoria),1 );
                                x_nova(n+m,:) = xB(inicio+idx_parent,:);
                                if (n+m >= POP_INICIAL)
                                    break;
                                end
                            end
                            % if the initial population isn't reached
                            m = size(x_nova,1);
                            if (m<POP_INICIAL)
                                x_nova(m+1:POP_INICIAL,:) = fix(rand(POP_INICIAL-m,1) * (( X_MAXB-X_MINB ) + X_MINB));  %new particle
                                m=POP_INICIAL; %refresh the size of x_nova
                            end
                            % A new swarm (x_nova) is created
                            N_SWARMSB = N_SWARMSB+1;   % refresh number of swarms
                            NB(N_SWARMSB) = m;        % population of the new swarm
                            n=size(xB,1);
                            o=n;
                            xB=[xB;x_nova];            % positions of the new particles
                            xBestB=[xBestB;x_nova];    % best position of new particles
                            vB=[vB;zeros(m,N_PAR)];    % initial velocity of new particles
                            vB_1=[vB_1;zeros(m,N_PAR)];
                            vB_2=[vB_2;zeros(m,N_PAR)];
                            vB_3=[vB_3;zeros(m,N_PAR)];
                            for n=o+1:o+m
                                fitB(n)=sum(probB(1:xB(n,1)))*(sum((1:xB(n,1)).*probB(1:xB(n,1))/sum(probB(1:xB(n,1)))) - sum((1:Lmax).*probB(1:Lmax)) )^2;
                                for jlevel=2:level-1
                                    fitB(n)=fitB(n)+sum(probB(xB(n,jlevel-1)+1:xB(n,jlevel)))*(sum((xB(n,jlevel-1)+1:xB(n,jlevel)).*probB(xB(n,jlevel-1)+1:xB(n,jlevel))/sum(probB(xB(n,jlevel-1)+1:xB(n,jlevel))))- sum((1:Lmax).*probB(1:Lmax)))^2;
                                end
                                fitB(n)=fitB(n)+sum(probB(xB(n,level-1)+1:Lmax))*(sum((xB(n,level-1)+1:Lmax).*probB(xB(n,level-1)+1:Lmax)/sum(probB(xB(n,level-1)+1:Lmax)))- sum((1:Lmax).*probB(1:Lmax)))^2;
                                fitBestB(n)=fitB(n);
                            end
                            [aB,bB]=max(fitB(o+1:o+m,:));
                            gBestB(N_SWARMSB,:)=xB(o+bB,:);
                            gbestvalueB(N_SWARMSB,1) = fitB(o+bB);
                            already_deletedB(N_SWARMSB)=0;
                            stagnancy_counterB(N_SWARMSB)=0;
                            clear x_nova;
                        end
                    end
                end
            end
            
            
            % eliminate worst particle
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if (stagnancy_counterR(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmR);
                        % eliminate worst particle
                        NR(i)=NR(i)-1;
                        x_swarmR(idx_pior,:)=[];
                        xBest_swarmR(idx_pior,:)=[];
                        v_swarmR(idx_pior,:)=[];
                        v_swarmR_1(idx_pior,:)=[];
                        v_swarmR_2(idx_pior,:)=[];
                        v_swarmR_3(idx_pior,:)=[];
                        fit_swarmR(idx_pior,:)=[];
                        fitBest_swarmR(idx_pior,:)=[];
                        % re-create tables
                        vR(jR+idx_pior-1,:)=[];
                        vR(jR:kR-1,:) = v_swarmR;
                        vR_1(jR+idx_pior-1,:)=[];
                        vR_1(jR:kR-1,:) = v_swarmR_1;
                        vR_2(jR+idx_pior-1,:)=[];
                        vR_2(jR:kR-1,:) = v_swarmR_2;
                        vR_3(jR+idx_pior-1,:)=[];
                        vR_3(jR:kR-1,:) = v_swarmR_3;
                        xR(jR+idx_pior-1,:)=[];
                        xR(jR:kR-1,:) = x_swarmR;
                        xBestR(jR+idx_pior-1,:)=[];
                        xBestR(jR:kR-1,:) = xBest_swarmR;
                        fitR(jR+idx_pior-1,:)=[];
                        fitR(jR:kR-1,:) = fit_swarmR;
                        fitBestR(jR+idx_pior-1,:)=[];
                        fitBestR(jR:kR-1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR-1;
                        manteveR = 0;
                        already_deletedR(i)=already_deletedR(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterR(i) = round( STAGNANCY * (1- ( 1/(already_deletedR(i)+1) ) ) );
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if (stagnancy_counterR(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmR);
                        % eliminate worst particle
                        NR(i)=NR(i)-1;
                        x_swarmR(idx_pior,:)=[];
                        xBest_swarmR(idx_pior,:)=[];
                        v_swarmR(idx_pior,:)=[];
                        v_swarmR_1(idx_pior,:)=[];
                        v_swarmR_2(idx_pior,:)=[];
                        v_swarmR_3(idx_pior,:)=[];
                        fit_swarmR(idx_pior,:)=[];
                        fitBest_swarmR(idx_pior,:)=[];
                        % re-create tables
                        vR(jR+idx_pior-1,:)=[];
                        vR(jR:kR-1,:) = v_swarmR;
                        vR_1(jR+idx_pior-1,:)=[];
                        vR_1(jR:kR-1,:) = v_swarmR_1;
                        vR_2(jR+idx_pior-1,:)=[];
                        vR_2(jR:kR-1,:) = v_swarmR_2;
                        vR_3(jR+idx_pior-1,:)=[];
                        vR_3(jR:kR-1,:) = v_swarmR_3;
                        xR(jR+idx_pior-1,:)=[];
                        xR(jR:kR-1,:) = x_swarmR;
                        xBestR(jR+idx_pior-1,:)=[];
                        xBestR(jR:kR-1,:) = xBest_swarmR;
                        fitR(jR+idx_pior-1,:)=[];
                        fitR(jR:kR-1,:) = fit_swarmR;
                        fitBestR(jR+idx_pior-1,:)=[];
                        fitBestR(jR:kR-1,:) = fitBest_swarmR;
                        gBestR(i,:)=gBest_swarmR;
                        gbestvalueR(i,:)=gbestvalue_swarmR;
                        kR=kR-1;
                        manteveR = 0;
                        already_deletedR(i)=already_deletedR(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterR(i) = round( STAGNANCY * (1- ( 1/(already_deletedR(i)+1) ) ) );
                    end
                end
                
                if (i<=N_SWARMSG)
                    if (stagnancy_counterG(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmG);
                        % eliminate worst particle
                        NG(i)=NG(i)-1;
                        x_swarmG(idx_pior,:)=[];
                        xBest_swarmG(idx_pior,:)=[];
                        v_swarmG(idx_pior,:)=[];
                        v_swarmG_1(idx_pior,:)=[];
                        v_swarmG_2(idx_pior,:)=[];
                        v_swarmG_3(idx_pior,:)=[];
                        fit_swarmG(idx_pior,:)=[];
                        fitBest_swarmG(idx_pior,:)=[];
                        % re-create tables
                        vG(jG+idx_pior-1,:)=[];
                        vG(jG:kG-1,:) = v_swarmG;
                        vG_1(jG+idx_pior-1,:)=[];
                        vG_1(jG:kG-1,:) = v_swarmG_1;
                        vG_2(jG+idx_pior-1,:)=[];
                        vG_2(jG:kG-1,:) = v_swarmG_2;
                        vG_3(jG+idx_pior-1,:)=[];
                        vG_3(jG:kG-1,:) = v_swarmG_3;
                        xG(jG+idx_pior-1,:)=[];
                        xG(jG:kG-1,:) = x_swarmG;
                        xBestG(jG+idx_pior-1,:)=[];
                        xBestG(jG:kG-1,:) = xBest_swarmG;
                        fitG(jG+idx_pior-1,:)=[];
                        fitG(jG:kG-1,:) = fit_swarmG;
                        fitBestG(jG+idx_pior-1,:)=[];
                        fitBestG(jG:kG-1,:) = fitBest_swarmG;
                        gBestG(i,:)=gBest_swarmG;
                        gbestvalueG(i,:)=gbestvalue_swarmG;
                        kG=kG-1;
                        manteveG = 0;
                        already_deletedG(i)=already_deletedG(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterG(i) = round( STAGNANCY * (1- ( 1/(already_deletedG(i)+1) ) ) );
                    end
                end
                
                if (i<=N_SWARMSB)
                    if (stagnancy_counterB(i) == STAGNANCY)
                        % identift worst particle
                        [a,idx_pior]=min(fit_swarmB);
                        % eliminate worst particle
                        NB(i)=NB(i)-1;
                        x_swarmB(idx_pior,:)=[];
                        xBest_swarmB(idx_pior,:)=[];
                        v_swarmB(idx_pior,:)=[];
                        v_swarmB_1(idx_pior,:)=[];
                        v_swarmB_2(idx_pior,:)=[];
                        v_swarmB_3(idx_pior,:)=[];
                        fit_swarmB(idx_pior,:)=[];
                        fitBest_swarmB(idx_pior,:)=[];
                        % re-create tables
                        vB(jB+idx_pior-1,:)=[];
                        vB(jB:kB-1,:) = v_swarmB;
                        vB_1(jB+idx_pior-1,:)=[];
                        vB_1(jB:kB-1,:) = v_swarmB_1;
                        vB_2(jB+idx_pior-1,:)=[];
                        vB_2(jB:kB-1,:) = v_swarmB_2;
                        vB_3(jB+idx_pior-1,:)=[];
                        vB_3(jB:kB-1,:) = v_swarmB_3;
                        xB(jB+idx_pior-1,:)=[];
                        xB(jB:kB-1,:) = x_swarmB;
                        xBestB(jB+idx_pior-1,:)=[];
                        xBestB(jB:kB-1,:) = xBest_swarmB;
                        fitB(jB+idx_pior-1,:)=[];
                        fitB(jB:kB-1,:) = fit_swarmB;
                        fitBestB(jB+idx_pior-1,:)=[];
                        fitBestB(jB:kB-1,:) = fitBest_swarmB;
                        gBestB(i,:)=gBest_swarmB;
                        gbestvalueB(i,:)=gbestvalue_swarmB;
                        kB=kB-1;
                        manteveB = 0;
                        already_deletedB(i)=already_deletedB(i)+1;
                        % stagnancy_counter doesn't get to zero
                        stagnancy_counterB(i) = round( STAGNANCY * (1- ( 1/(already_deletedB(i)+1) ) ) );
                    end
                end
            end
            
            
            % eliminate swarm
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if (NR(i)==MIN_POP)&&(N_SWARMSR>MIN_SWARMS)
                        vR(jR:kR,:)=[];
                        vR_1(jR:kR,:)=[];
                        vR_2(jR:kR,:)=[];
                        vR_3(jR:kR,:)=[];
                        xR(jR:kR,:)=[];
                        xBestR(jR:kR,:)=[];
                        fitR(jR:kR,:)=[];
                        fitBestR(jR:kR)=[];
                        gBestR(i,:)=[];
                        gbestvalueR(i,:)=[];
                        NR(i)=[];
                        already_deletedR(i)=[];
                        stagnancy_counterR(i)=[];
                        N_SWARMSR = N_SWARMSR - 1;
%                         i = i-1;
                        manteveR=0;
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if (NR(i)==MIN_POP)&&(N_SWARMSR>MIN_SWARMS)
                        vR(jR:kR,:)=[];
                        vR_1(jR:kR,:)=[];
                        vR_2(jR:kR,:)=[];
                        vR_3(jR:kR,:)=[];
                        xR(jR:kR,:)=[];
                        xBestR(jR:kR,:)=[];
                        fitR(jR:kR,:)=[];
                        fitBestR(jR:kR)=[];
                        gBestR(i,:)=[];
                        gbestvalueR(i,:)=[];
                        NR(i)=[];
                        already_deletedR(i)=[];
                        stagnancy_counterR(i)=[];
                        N_SWARMSR = N_SWARMSR - 1;
%                         i = i-1;
                        manteveR=0;
                    end
                end
                
                if (i<=N_SWARMSG)
                    if (NG(i)==MIN_POP)&&(N_SWARMSG>MIN_SWARMS)
                        vG(jG:kG,:)=[];
                        vG_1(jG:kG,:)=[];
                        vG_2(jG:kG,:)=[];
                        vG_3(jG:kG,:)=[];
                        xG(jG:kG,:)=[];
                        xBestG(jG:kG,:)=[];
                        fitG(jG:kG,:)=[];
                        fitBestG(jG:kG)=[];
                        gBestG(i,:)=[];
                        gbestvalueG(i,:)=[];
                        NG(i)=[];
                        already_deletedG(i)=[];
                        stagnancy_counterG(i)=[];
                        N_SWARMSG = N_SWARMSG - 1;
%                         i = i-1;
                        manteveG=0;
                    end
                end
                
                if (i<=N_SWARMSB)&&(N_SWARMSB>MIN_SWARMS)
                    if (NB(i)==MIN_POP)
                        vB(jB:kB,:)=[];
                        vB_1(jB:kB,:)=[];
                        vB_2(jB:kB,:)=[];
                        vB_3(jB:kB,:)=[];
                        xB(jB:kB,:)=[];
                        xBestB(jB:kB,:)=[];
                        fitB(jB:kB,:)=[];
                        fitBestB(jB:kB)=[];
                        gBestB(i,:)=[];
                        gbestvalueB(i,:)=[];
                        NB(i)=[];
                        already_deletedB(i)=[];
                        stagnancy_counterB(i)=[];
                        N_SWARMSB = N_SWARMSB - 1;
%                         i = i-1;
                        manteveB=0;
                    end
                end
            end
            
            % refresh structures
            if size(I,3)==1 %grayscale image
                if (i<=N_SWARMSR)
                    if (manteveR==1)
                        vR(jR:kR,:) = v_swarmR;
                        vR_1(jR:kR,:) = v_swarmR_1;
                        vR_2(jR:kR,:) = v_swarmR_2;
                        vR_3(jR:kR,:) = v_swarmR_3;
                        gBestR(i,:) = gBest_swarmR;
                        gbestvalueR(i,1) = gbestvalue_swarmR;
                        xR(jR:kR,:) = x_swarmR;
                        xBestR(jR:kR,:) = xBest_swarmR;
                        fitR(jR:kR,:) = fit_swarmR;
                        fitBestR(jR:kR,:) = fitBest_swarmR;
                    end
                end
            elseif size(I,3)==3 %RGB image
                if (i<=N_SWARMSR)
                    if (manteveR==1)
                        vR(jR:kR,:) = v_swarmR;
                        vR_1(jR:kR,:) = v_swarmR_1;
                        vR_2(jR:kR,:) = v_swarmR_2;
                        vR_3(jR:kR,:) = v_swarmR_3;
                        gBestR(i,:) = gBest_swarmR;
                        gbestvalueR(i,1) = gbestvalue_swarmR;
                        xR(jR:kR,:) = x_swarmR;
                        xBestR(jR:kR,:) = xBest_swarmR;
                        fitR(jR:kR,:) = fit_swarmR;
                        fitBestR(jR:kR,:) = fitBest_swarmR;
                    end
                end
                
                if (i<=N_SWARMSG)
                    if (manteveG==1)
                        vG(jG:kG,:) = v_swarmG;
                        vG_1(jG:kG,:) = v_swarmG_1;
                        vG_2(jG:kG,:) = v_swarmG_2;
                        vG_3(jG:kG,:) = v_swarmG_3;
                        gBestG(i,:) = gBest_swarmG;
                        gbestvalueG(i,1) = gbestvalue_swarmG;
                        xG(jG:kG,:) = x_swarmG;
                        xBestG(jG:kG,:) = xBest_swarmG;
                        fitG(jG:kG,:) = fit_swarmG;
                        fitBestG(jG:kG,:) = fitBest_swarmG;
                    end
                end
                
                if (i<=N_SWARMSB)
                    if (manteveB==1)
                        vB(jB:kB,:) = v_swarmB;
                        vB_1(jB:kB,:) = v_swarmB_1;
                        vB_2(jB:kB,:) = v_swarmB_2;
                        vB_3(jB:kB,:) = v_swarmB_3;
                        gBestB(i,:) = gBest_swarmB;
                        gbestvalueB(i,1) = gbestvalue_swarmB;
                        xB(jB:kB,:) = x_swarmB;
                        xBestB(jB:kB,:) = xBest_swarmB;
                        fitB(jB:kB,:) = fit_swarmB;
                        fitBestB(jB:kB,:) = fitBest_swarmB;
                    end
                end
            end

            %clear variables
            clear v_swarmR v_swarmG v_swarmB;
            clear v_swarmR_1 v_swarmG_1 v_swarmB_1;
            clear v_swarmR_2 v_swarmG_2 v_swarmB_2;
            clear v_swarmR_3 v_swarmG_3 v_swarmB_3;
            clear gBest_swarmR gBest_swarmG gBest_swarmB;
            clear gbestvalue_swarmR gbestvalue_swarmG gbestvalue_swarmB;
            clear x_swarmR x_swarmG x_swarmB;
            clear xBest_swarmR xBest_swarmG xBest_swarmB;
            clear fit_swarmR fit_swarmG fit_swarmB;
            clear fitBest_swarmR fitBest_swarmG fitBest_swarmB;

            i=i+1; %avança para a próxima Swarm
        end
    
        
        % calculate gbestvalue_DPSO (global best from all swarms):
        
        if size(I,3)==1 %grayscale image
            antigoR = gbestvalue_DPSOR;
            [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(gbestvalueR);
        elseif size(I,3)==3 %RGB image
            antigoR = gbestvalue_DPSOR;
            [gbestvalue_DPSOR,i_gbestvalue_DPSOR]=max(gbestvalueR);

            antigoG = gbestvalue_DPSOG;
            [gbestvalue_DPSOG,i_gbestvalue_DPSOG]=max(gbestvalueG);

            antigoB = gbestvalue_DPSOB;
            [gbestvalue_DPSOB,i_gbestvalue_DPSOB]=max(gbestvalueB);

        end
        
        nger=nger+1;
    end

    if size(I,3)==1 %grayscale image
        gBestR = round(gBestR(i_gbestvalue_DPSOR,:));
        gbestvalueR=gbestvalue_DPSOR;
    elseif size(I,3)==3 %RGB image
        gBestR = round(gBestR(i_gbestvalue_DPSOR,:));
        gbestvalueR=gbestvalue_DPSOR;
        gBestG = round(gBestG(i_gbestvalue_DPSOG,:));
        gbestvalueG=gbestvalue_DPSOG;
        gBestB = round(gBestB(i_gbestvalue_DPSOB,:));
        gbestvalueB=gbestvalue_DPSOB;
    end
    
    
%     gbestvalue_DPSOR
end



if (strcmpi(method,'exhaustive'))
    disp 'still in develpment...'
    if size(I,3)==1 %grayscale image
        jxcount=Lmax-1;
        xR(1)=1;
        for jx=2:N_PAR
            jxcount=jxcount*(Lmax-jx);
            xR(jx)=xR(jx-1)+1;
        end
        for jxc=1:jxcount
            fitR=sum(probR(1:xR(1).x))*(sum((1:xR(1)).*probR(1:xR(1))/sum(probR(1:xR(1)))) - sum((1:Lmax).*probR(1:Lmax)) )^2;
            for jlevel=2:level-1
                fitR=fitR+sum(probR(xR(jlevel-1)+1:xR(jlevel)))*(sum((xR(jlevel-1)+1:xR(jlevel)).*probR(xR(jlevel-1)+1:xR(jlevel))/sum(probR(xR(jlevel-1)+1:xR(jlevel))))- sum((1:Lmax).*probR(1:Lmax)))^2;
            end
            fitR=fitR+sum(probR(xR(level-1)+1:Lmax))*(sum((xR(level-1)+1:Lmax).*probR(xR(level-1)+1:Lmax)/sum(probR(xR(level-1)+1:Lmax)))- sum((1:Lmax).*probR(1:Lmax)))^2;
            if fitR>gbestvalueR
                gbestvalueR=fitR;
                gBestR=xR(:)-1;
            end
            for jx=1:N_PAR
                xR(jx)=xR(jx)+10^(jx-N_PAR);    %%A ACABAR!!!!
            end
        end
    elseif size(I,3)==3 %RGB image
        
    end    
end

if size(I,3)==1 %grayscale image
    gBestR=sort(gBestR);
    Iout=imageGRAY(I,gBestR);
elseif size(I,3)==3 %RGB image
    gBestR=sort(gBestR);
    gBestG=sort(gBestG);
    gBestB=sort(gBestB);
    Iout=imageRGB(I,gBestR,gBestG,gBestB);
end

if nargout>1
    if size(I,3)==1 %grayscale image
        gBestR=sort(gBestR);
        intensity=gBestR;     %return optimal intensity
        if nargout>2
            fitness=gbestvalueR;    %return fitness value
            if nargout>3
                time=toc;   %return CPU time
            end
        end
    elseif size(I,3)==3 %RGB image
        gBestR=sort(gBestR);
        gBestG=sort(gBestG);
        gBestB=sort(gBestB);
        intensity=[gBestR; gBestG; gBestB];
        if nargout>2
            fitness=[gbestvalueR; gbestvalueG; gbestvalueB];    %return fitness value
            if nargout>3
                time=toc;   %return CPU time
            end
        end
    end
end


function imgOut=imageRGB(img,Rvec,Gvec,Bvec)
imgOutR=img(:,:,1);
imgOutG=img(:,:,2);
imgOutB=img(:,:,3);

Rvec=[0 Rvec 256];
for iii=1:size(Rvec,2)-1
    at=find(imgOutR(:,:)>=Rvec(iii) & imgOutR(:,:)<Rvec(iii+1));
    imgOutR(at)=Rvec(iii);
end

Gvec=[0 Gvec 256];
for iii=1:size(Gvec,2)-1
    at=find(imgOutG(:,:)>=Gvec(iii) & imgOutG(:,:)<Gvec(iii+1));
    imgOutG(at)=Gvec(iii);
end

Bvec=[0 Bvec 256];
for iii=1:size(Bvec,2)-1
    at=find(imgOutB(:,:)>=Bvec(iii) & imgOutB(:,:)<Bvec(iii+1));
    imgOutB(at)=Bvec(iii);
end

imgOut=img;

imgOut(:,:,1)=imgOutR;
imgOut(:,:,2)=imgOutG;
imgOut(:,:,3)=imgOutB;


function imgOut=imageGRAY(img,Rvec)
% imgOut=img;
limites=[0 Rvec 255];
tamanho=size(img);
imgOut(:,:)=img*0;
% cores=[ 0   0   0;
%         255 0   0;
%         0   255 0;
%         0   0   255;
%         255 255 0;
%         0   255 255;
%         255 0   255;
%         255 255 255];
        
cores=colormap(lines)*255;
close all;
%tic
k=1;
    for i= 1:tamanho(1,1)
        for j=1:tamanho(1,2)
            while(k<size(limites,2))
                if(img(i,j)>=limites(1,k) && img(i,j)<=limites(1,k+1))
                    imgOut(i,j,1)=limites(1,k);
%                     imgOut(i,j,2)=cores(k,2);
%                     imgOut(i,j,3)=cores(k,3);
                end
                k=k+1;
            end
            k=1;
        end
    end

    
function [C,RA,RB] = insertrows(A,B,ind)
% INSERTROWS - Insert rows into a matrix at specific locations
%   C = INSERTROWS(A,B,IND) inserts the rows of matrix B into the matrix A at
%   the positions IND. Row k of matrix B will be inserted after position IND(k)
%   in the matrix A. If A is a N-by-X matrix and B is a M-by-X matrix, C will
%   be a (N+M)-by-X matrix. IND can contain non-integers.
%
%   If B is a 1-by-N matrix, B will be inserted for each insertion position
%   specified by IND. If IND is a single value, the whole matrix B will be
%   inserted at that position. If B is a single value, B is expanded to a row
%   vector. In all other cases, the number of elements in IND should be equal to
%   the number of rows in B, and the number of columns, planes etc should be the
%   same for both matrices A and B. 
%
%   Values of IND smaller than one will cause the corresponding rows to be
%   inserted in front of A. C = INSERTROWS(A,B) will simply append B to A.
%
%   If any of the inputs are empty, C will return A. If A is sparse, C will
%   be sparse as well. 
%
%   [C, RA, RB] = INSERTROWS(...) will return the row indices RA and RB for
%   which C corresponds to the rows of either A and B.
%
%   Examples:
%     % the size of A,B, and IND all match
%        C = insertrows(rand(5,2),zeros(2,2),[1.5 3]) 
%     % the row vector B is inserted twice
%        C = insertrows(ones(4,3),1:3,[1 Inf]) 
%     % matrix B is expanded to a row vector and inserted twice (as in 2)
%        C = insertrows(ones(5,3),999,[2 4])
%     % the whole matrix B is inserted once
%        C = insertrows(ones(5,3),zeros(2,3),2)
%     % additional output arguments
%        [c,ra,rb] = insertrows([1:4].',99,[0 3]) 
%        c.'     % -> [99 1 2 3 99 4] 
%        c(ra).' % -> [1 2 3 4] 
%        c(rb).' % -> [99 99] 
%
%   Using permute (or transpose) INSERTROWS can easily function to insert
%   columns, planes, etc:
%
%     % inserting columns, by using the transpose operator:
%        A = zeros(2,3) ; B = ones(2,4) ;
%        c = insertrows(A.', B.',[0 2 3 3]).'  % insert columns
%     % inserting other dimensions, by using permute:
%        A = ones(4,3,3) ; B = zeros(4,3,1) ; 
%        % set the dimension on which to operate in front
%        C = insertrows(permute(A,[3 1 2]), permute(B,[3 1 2]),1) ;
%        C = ipermute(C,[3 1 2]) 
%
%  See also HORZCAT, RESHAPE, CAT

% for Matlab R13
% version 2.0 (may 2008)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History:
% 1.0, feb 2006 - created
% 2.0, may 2008 - incorporated some improvements after being selected as
% "Pick of the Week" by Jiro Doke, and reviews by Tim Davis & Brett:
%  - horizontal concatenation when two arguments are provided
%  - added example of how to insert columns
%  - mention behavior of sparse inputs
%  - changed "if nargout" to "if nargout>1" so that additional outputs are
%    only calculated when requested for

error(nargchk(2,3,nargin)) ;

if nargin==2,
    % just horizontal concatenation, suggested by Tim Davis
    ind = size(A,1) ;
end

% shortcut when any of the inputs are empty
if isempty(B) || isempty(ind),    
    C = A ;     
    if nargout > 1,
        RA = 1:size(A,1) ;
        RB = [] ;
    end
    return
end

sa = size(A) ;

% match the sizes of A, B
if numel(B)==1,
    % B has a single argument, expand to match A
    sb = [1 sa(2:end)] ;
    B = repmat(B,sb) ;
else
    % otherwise check for dimension errors
    if ndims(A) ~= ndims(B),
        error('insertrows:DimensionMismatch', ...
            'Both input matrices should have the same number of dimensions.') ;
    end
    sb = size(B) ;
    if ~all(sa(2:end) == sb(2:end)),
        error('insertrows:DimensionMismatch', ...
            'Both input matrices should have the same number of columns (and planes, etc).') ;
    end
end

ind = ind(:) ; % make as row vector
ni = length(ind) ;

% match the sizes of B and IND
if ni ~= sb(1),
    if ni==1 && sb(1) > 1,
        % expand IND
        ind = repmat(ind,sb(1),1) ;
    elseif (ni > 1) && (sb(1)==1),
        % expand B
        B = repmat(B,ni,1) ;
    else
        error('insertrows:InputMismatch',...
            'The number of rows to insert should equal the number of insertion positions.') ;
    end
end

sb = size(B) ;

% the actual work
% 1. concatenate matrices
C = [A ; B] ;
% 2. sort the respective indices, the first output of sort is ignored (by
% giving it the same name as the second output, one avoids an extra 
% large variable in memory)
[abi,abi] = sort([[1:sa(1)].' ; ind(:)]) ;
% 3. reshuffle the large matrix
C = C(abi,:) ;
% 4. reshape as A for nd matrices (nd>2)
if ndims(A) > 2,
    sc = sa ;
    sc(1) = sc(1)+sb(1) ;
    C = reshape(C,sc) ;
end

if nargout > 1,
    % additional outputs required
    R = [zeros(sa(1),1) ; ones(sb(1),1)] ;
    R = R(abi) ;
    RA = find(R==0) ;
    RB = find(R==1) ;
end


    
    
    