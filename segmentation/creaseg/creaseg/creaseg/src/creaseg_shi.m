% Copyright or © or Copr. CREATIS laboratory, Lyon, France.
% 
% Contributor: Olivier Bernard, Associate Professor at the french 
% engineering university INSA (Institut National des Sciences Appliquees) 
% and a member of the CREATIS-LRMN laboratory (CNRS 5220, INSERM U630, 
% INSA, Claude Bernard Lyon 1 University) in France (Lyon).
% 
% Date of creation: 8th of October 2009
% 
% E-mail of the author: olivier.bernard@creatis.insa-lyon.fr
% 
% This software is a computer program whose purpose is to evaluate the 
% performance of different level-set based segmentation algorithms in the 
% context of image processing (and more particularly on biomedical 
% images).
% 
% The software has been designed for two main purposes. 
% - firstly, CREASEG allows you to use six different level-set methods. 
% These methods have been chosen in order to work with a wide range of 
% level-sets. You can select for instance classical methods such as 
% Caselles or Chan & Vese level-set, or more recent approaches such as the 
% one developped by Lankton or Bernard.
% - finally, the software allows you to compare the performance of the six 
% level-set methods on different images. The performance can be evaluated 
% either visually, or from measurements (either using the Dice coefficient 
% or the PSNR value) between a reference and the results of the 
% segmentation.
%  
% The level-set segmentation platform is citationware. If you are 
% publishing any work, where this program has been used, or which used one 
% of the proposed level-set algorithms, please remember that it was 
% obtained free of charge. You must reference the papers shown below and 
% the name of the CREASEG software must be mentioned in the publication.
% 
% CREASEG software
% "T. Dietenbeck, M. Alessandrini, D. Friboulet, O. Bernard. CREASEG: a
% free software for the evaluation of image segmentation algorithms based 
% on level-set. In IEEE International Conference On Image Processing. 
% Hong Kong, China, 2010."
%
% Bernard method
% "O. Bernard, D. Friboulet, P. Thevenaz, M. Unser. Variational B-Spline 
% Level-Set: A Linear Filtering Approach for Fast Deformable Model 
% Evolution. In IEEE Transactions on Image Processing. volume 18, no. 06, 
% pp. 1179-1191, 2009."
% 
% Caselles method
% "V. Caselles, R. Kimmel, and G. Sapiro. Geodesic active contours. 
% International Journal of Computer Vision, volume 22, pp. 61-79, 1997."
% 
% Chan & Vese method
% "T. Chan and L. Vese. Active contours without edges. IEEE Transactions on
% Image Processing. volume10, pp. 266-277, February 2001."
% 
% Lankton method
% "S. Lankton, A. Tannenbaum. Localizing Region-Based Active Contours. In 
% IEEE Transactions on Image Processing. volume 17, no. 11, pp. 2029-2039, 
% 2008."
% 
% Li method
% "C. Li, C.Y. Kao, J.C. Gore, Z. Ding. Minimization of Region-Scalable 
% Fitting Energy for Image Segmentation. In IEEE Transactions on Image 
% Processing. volume 17, no. 10, pp. 1940-1949, 2008."
% 
% Shi method
% "Yonggang Shi, William Clem Karl. A Real-Time Algorithm for the 
% Approximation of Level-Set-Based Curve Evolution. In IEEE Transactions 
% on Image Processing. volume 17, no. 05, pp. 645-656, 2008."
% 
% This software is governed by the BSD license and
% abiding by the rules of distribution of free software.
% 
% As a counterpart to the access to the source code and rights to copy,
% modify and redistribute granted by the license, users are provided only
% with a limited warranty and the software's author, the holder of the
% economic rights, and the successive licensors have only limited
% liability. 
% 
% In this respect, the user's attention is drawn to the risks associated
% with loading, using, modifying and/or developing or reproducing the
% software by the user in light of its specific status of free software,
% that may mean that it is complicated to manipulate, and that also
% therefore means that it is reserved for developers and experienced
% professionals having in-depth computer knowledge. Users are therefore
% encouraged to load and test the software's suitability as regards their
% requirements in conditions enabling the security of their systems and/or 
% data to be ensured and, more generally, to use and operate it in the 
% same conditions as regards security.
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Description: This code implements the paper: "A Real-Time Algorithm for 
% the Approximation of Level-Set-Based Curve Evolution." By Yonggang Shi.
%
% Coded by: Olivier Bernard (www.creatis.insa-lyon.fr/~bernard)
%------------------------------------------------------------------------


function [seg,phi,n] = creaseg_shi(img,init_mask,max_its,Na,Ns,Sigma,Ng,color,display)

    %-- default value for parameter max_its is 100
    if(~exist('max_its','var')) 
        max_its = 100; 
    end
    %-- default value for parameter na is 30
    if(~exist('Na','var')) 
        Na = 30; 
    end    
    %-- default value for parameter ns is 3
    if(~exist('Ns','var')) 
        Ns = 3;
    end
    %-- default value for parameter sigma is 9
    if(~exist('Sigma','var')) 
        Sigma = 3;
    end
    %-- default value for parameter ng is 7
    if(~exist('Ng','var')) 
        Ng = 1;
    end   
    %-- default value for parameter color is 'r'
    if(~exist('color','var')) 
        color = 'r'; 
    end       
    %-- default behavior is to display intermediate outputs
    if(~exist('display','var'))
        display = true;
    end   
    
%     init_mask = init_mask<=0;

    %--
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    
    
    %-- Create the initial level-set
    [phi,Lin,Lout,size_in,size_out] = createInitialLevelSet(init_mask);

    %-- Create feature image
    [feature,u,v,Ain,Aout] = createFeatureImage(phi,img);

    %-- main looop
    stop_cond = 0;  % Stopping condition
    n = 1;

    while ( (n<=max_its) && (stop_cond==0) )

        % Data dependent evolution
        na = 0;
        while ( (na<Na) && (n<=max_its) && (stop_cond==0) )

            [Lin,Lout,phi,u,v,Ain,Aout,size_in,size_out] = ...
                shi_evolution_subCV(img,Lin,Lout,phi,feature,u,v,Ain,Aout,size_in,size_out);

            %-- intermediate output
            if (display>0)
                if ( mod(na,50)==0 )            
                    set(ud.txtInfo1,'string',sprintf('iteration: %d',n),'color',[1 1 0]);
                    showCurveAndPhi(phi,ud,color);
                    drawnow;
                end
            else
                if ( mod(na,10)==0 )            
                    set(ud.txtInfo1,'string',sprintf('iteration: %d',n),'color',[1 1 0]);
                    drawnow;
                end
            end        

            stop_cond = stopping_condition(feature,Lin,Lout,size_in,size_out);

            if ( stop_cond==0 )  % Mise à jour de la feature image
                feature = zeros(size(phi));
                [x,y] = find(abs(phi) < 2);
                feature(x,y) = -(img(x,y) - u).^2 + (img(x,y) - v).^2;
                feature = feature./max(abs(feature(:)));
            end

            na = na+1;
            n = n+1;

        end

        % smoothing evolution
        for ns=1:1:Ns
            Fint = smoothing(phi,Lin,Lout,size_in,size_out,Ng,Sigma);
            [Lin,Lout,phi,u,v,Ain,Aout,size_in,size_out] = ...
                shi_evolution_subCV(img,Lin,Lout,phi,Fint,u,v,Ain,Aout,size_in,size_out);
            n = n+1;
        end

        if (stop_cond==0)
            feature = zeros(size(phi));
            [x,y] = find(abs(phi) < 2);
            feature(x,y) = -(img(x,y) - u).^2 + (img(x,y) - v).^2; % Chan & Vese
            feature = feature./max(abs(feature(:)));
        end

    end

    %-- final output
    showCurveAndPhi(phi,ud,color);   

    %-- make mask from SDF
    seg = phi<=0; %-- Get mask from levelset


%---------------------------------------------------------------------
%---------------------------------------------------------------------
%-- AUXILIARY FUNCTIONS ----------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------
  
 
%-- Displays the image with curve superimposed
function showCurveAndPhi(phi,ud,cl)

	axes(get(ud.imageId,'parent'));
	delete(findobj(get(ud.imageId,'parent'),'type','line'));
	hold on; [c,h] = contour(phi,[0 0],cl{1},'Linewidth',3); hold off;
	delete(h);
    test = isequal(size(c,2),0);
	while (test==false)
        s = c(2,1);
        if ( s == (size(c,2)-1) )
            t = c;
            hold on; plot(t(1,2:end)',t(2,2:end)',cl{1},'Linewidth',3);
            test = true;
        else
            t = c(:,2:s+1);
            hold on; plot(t(1,1:end)',t(2,1:end)',cl{1},'Linewidth',3);
            c = c(:,s+2:end);
        end
	end    



%-- Create the initial discrete level-set from mask
function [u,Lin,Lout,size_in,size_out] = createInitialLevelSet(mask)

    tmp = ones(size(mask))*3;
    tmp(mask>0) = -3;

    u = tmp;
    [nrow,ncol] = size(u);
    [x,y] = find(tmp==-3);
    for j=1:size(x,1)
        neigh = voisinage([x(j);y(j)],nrow,ncol);
        k = 1;
        stop = 0;
        while ( ( k<5 ) && ( stop==0 ) )
            if ( tmp(neigh(1,k),neigh(2,k)) > -3 )
                u(x(j),y(j)) = 1;
                stop = 1;
            end                
            k = k + 1;
        end
    end
    tmp(u>-3) = 3;
    [x,y] = find(tmp==-3);
    for j=1:size(x,1)
        neigh = voisinage([x(j);y(j)],nrow,ncol);
        k = 1;
        stop = 0;
        while ( ( k<5 ) && ( stop==0 ) )
            if ( tmp(neigh(1,k),neigh(2,k)) > -3 )
                u(x(j),y(j)) = -1;
                stop = 1;
            end                
            k = k + 1;
        end
    end
    

    Lin = zeros(2,round(size(u,1)*size(u,2)/6));
    Lout = zeros(2,round(size(u,1)*size(u,2)/6));
    size_in = 0;
    size_out = 0;
    for i=1:1:size(u,1)
        for j=1:1:size(u,2)
            if ( u(i,j) == 1 )
                size_out = size_out + 1;
                Lout(:,size_out) = [i;j];
            end
            if ( u(i,j) == -1 )
                size_in = size_in + 1;
                Lin(:,size_in) = [i;j];
            end
        end
    end    


%-- Find the neighborhood of one pixel 
function N = voisinage(x,nrow,ncol)

    i = x(1);
    j = x(2);
    I1 = i+1;
    if (I1 > nrow)
        I1 = nrow;
    end
    I2 = i-1;
    if (I2 < 1)
        I2 = 1;
    end
    J1 = j+1;
    if (J1 > ncol)
        J1 = ncol;
    end
    J2 = j-1;
    if (J2 < 1)
        J2 = 1;
    end
    N = [I1, I2, i, i; j, j, J1, J2];


%-- Create feature image for data dependent cycle
function [feature, u, v, Ain, Aout] = createFeatureImage(phi, im)
   
    upts = find(phi<=0);            % interior points
    vpts = find(phi>0);             % exterior points
    Ain = length(upts);             % interior area
    Aout = length(vpts);            % exterior area
    u = sum(im(upts))/(Ain+eps);    % interior mean
    v = sum(im(vpts))/(Aout+eps);   % exterior mean
    
    feature = zeros(size(phi));
    [x,y] = find(abs(phi) < 2);
    feature(x,y) = -(im(x,y) - u).^2 + (im(x,y) - v).^2;
    feature = feature./max(abs(feature(:)));
   
        
%-- Testing convergence
function sc = stopping_condition(F, Li, Lo,size_in,size_out)

    sc = 1; i = 1;
    while( i<size_out && sc )
        x = Lo(1,i);
        y = Lo(2,i);
        if F(x,y)>0
            sc = 0;
        end
        i = i+1;
    end
    
    i = 1;
    while( i<size_in && sc )
        x = Li(1,i);
        y = Li(2,i);
        if F(x,y)<0
            sc = 0;
        end   
        i = i + 1;
    end    
    

%-- Create feature image for smoothing cycle
function Fi = smoothing(phi, Li, Lo,size_in,size_out, sg, sigma)
   
    [nr, nc] = size(phi);
    Fi = zeros(nr, nc);

    Gaussian = fspecial('gaussian', [sg, sg], sigma);
    
    H = zeros(size(phi));
    H(phi<0) = 1;
    HG = imfilter(H, Gaussian);

    for i = 1:1:size_out
        x = Lo(1,i);    
        y = Lo(2,i);
        if ( HG(x,y)>1/2 )
            Fi(x,y) = 1;
        end   
    end

    for i = 1:1:size_in
        x = Li(1,i);
        y = Li(2,i);
        if ( HG(x,y)<1/2 )
            Fi(x,y) = -1;
        end   
    end
    
    
%-- shi_evolution_subCV
function [Linmod, Loutmod, Phimod, umod, vmod, Ai, Ao,s_i,s_o] = ...
                    shi_evolution_subCV(img, Lin, Lout, phi, feature, u, v, Ain, Aout,size_in,size_out)

    [nrow,ncol] = size(phi);

    Linmod = Lin;
    Loutmod = Lout;
    Phimod = phi;
    s_i = size_in;
    s_o = size_out;    

    umod = u;
	Ai = Ain;
    vmod = v;
	Ao = Aout;

    % Step 1: Outward evolution
    c = 1;
    N = s_o;
    while ( c <= N )
        i = Loutmod(1, c);      j = Loutmod(2, c);
        if ( feature(i, j) > 0 )
            [Linmod, Loutmod, Phimod,s_i,s_o] = ...
                switch_in(c, Linmod, Loutmod, Phimod, s_i, s_o, nrow, ncol);

            umod = (umod*Ai + img(i, j))/(Ai + 1);
            vmod = (vmod*Ao - img(i, j))/(Ao - 1);
            Ai = Ai + 1;   Ao = Ao - 1;

            c = c-1;
            N = N-1;
        end
        c = c+1;
    end

    % Step 2: Eliminate redundant point in Lin
    [Linmod, Phimod, s_i] = suppr_Lin(Linmod, Phimod, s_i, nrow, ncol);


    % Step 3: Inward evolution
    c = 1;
    N = s_i;
    while (c <= N)
        i = Linmod(1, c);       j = Linmod(2, c);
        if ( feature(i, j) < 0 )
            [Linmod, Loutmod, Phimod,s_i,s_o] = ...
                    switch_out(c, Linmod, Loutmod, Phimod,s_i,s_o, nrow, ncol);

            umod = (umod*Ai - img(i, j))/(Ai - 1);
            vmod = (vmod*Ao + img(i, j))/(Ao + 1);
            Ai = Ai - 1;   Ao = Ao + 1;

            c = c-1;
            N = N-1;
        end
        c = c+1;
    end


    % Step 4: Eliminate redundant point in Lout
    [Loutmod, Phimod,s_o] = suppr_Lout(Loutmod, Phimod,s_o,nrow, ncol);


function [Linmod, Loutmod, Phimod,s_i,s_o] = ...
            switch_in(c, Lin, Lout, phi,size_in,size_out, nrow, ncol)

    x = [Lout(1, c); Lout(2, c)];
    Phimod = phi;
    Linmod = Lin;
    Loutmod = Lout;
    
    % on ajoute x a Lin
    Linmod(:,size_in+1) = x;
    Phimod(x(1, 1), x(2, 1)) = -1;
    s_i = size_in + 1;

    % Suppression de x de Lout
    if (c == 1)
        Loutmod(:,1:size_out-1) = Lout(:, 2:size_out);
    elseif (c == size_out)
        Loutmod(:,1:size_out-1) = Lout(:, 1:size_out-1);
    else
        Loutmod(:,1:size_out-1) = [Lout(:, 1:c-1),Lout(:, c+1:size_out)];
    end
    s_o = size_out - 1;

    % Mise a jour du voisinage
    N = voisinage(x, nrow, ncol);
    for k=1:1:4
        y = [N(1, k); N(2, k)];
        i = N(1, k);
        j = N(2, k);
        if phi(i, j) == 3 % y est un point exterieur
            Phimod(i, j) = 1; % Mise a jour de phi(j)
            Loutmod(:,s_o+1) = y; % Mise a jour de Lout
            s_o = s_o + 1;
        end
    end


function [Linmod, Loutmod, Phimod,s_i,s_o] = ...
            switch_out(c, Lin, Lout, phi,size_in,size_out, nrow, ncol)
        
    x = [Lin(1, c); Lin(2, c)];
    Phimod = phi;
    Linmod = Lin;
    Loutmod = Lout;
    
    % on ajoute x a Lout
    Loutmod(:,size_out+1) = x;
    Phimod(x(1, 1), x(2, 1)) = 1;
    s_o = size_out + 1;

    % Suppression de x de Lin
    if (c == 1)
        Linmod(:,1:size_in-1) = Lin(:, 2:size_in);
    elseif (c == size_in)
        Linmod(:,1:size_in-1) = Lin(:, 1:size_in-1);
    else
        Linmod(:,1:size_in-1) = [Lin(:, 1:c-1), Lin(:, c+1:size_in)];
    end
    s_i = size_in-1;
    
    N = voisinage(x, nrow, ncol);
    for k=1:1:4
        y = [N(1, k); N(2, k)];
        i = N(1, k);
        j = N(2, k);
        if (phi(i, j) == -3) % y est un point interieur
            Phimod(i, j) = -1; % Mise a jour de phi(j)
            Linmod(:,s_i+1) = y; % Mise a jour de Lin
            s_i = s_i + 1;
        end
    end


function [Linmod, Phimod,s_i] = suppr_Lin(Lin, phi,size_in, nrow, ncol)

    Linmod = Lin;
    Phimod = phi;
    s_i = size_in;
    
    k=1;
    while (k <= s_i)
        x = [Lin(1, k); Lin(2, k)];
        N = voisinage(x, nrow, ncol);
        i = x(1, 1);
        j = x(2, 1);
        b = 0;
        for c=1:1:4
            if (phi(N(1, c), N(2, c)) < 0)
                b = b+1;
            end
        end
        if (b == 4)
            % Suppression de x de Lin
            if (k == 1)
                Linmod(:,1:s_i-1) = Lin(:,2:s_i);
            elseif (k == s_i)
                Linmod(:,1:s_i-1) = Lin(:,1:s_i-1);
            else
                Linmod(:,1:s_i-1) = [Lin(:,1:k-1),Lin(:,k+1:s_i)];
            end
            k = k-1;
            s_i = s_i-1;
            Phimod(i,j) = -3;
            Lin = Linmod;
        end

        k = k+1;
    end


function [Loutmod, Phimod,s_o] = suppr_Lout(Lout, phi,size_out, nrow, ncol)

    Loutmod = Lout;
    Phimod = phi;
    s_o = size_out;
    
    k = 1;
    while (k <= s_o)
        x = [Lout(1, k); Lout(2, k)];
        N = voisinage(x, nrow, ncol);
        i = x(1, 1);
        j = x(2, 1);
        b = 0;
        for c = 1:1:4
            if (phi(N(1, c), N(2, c)) > 0)
                b = b+1;
            end
        end
        if (b == 4)
            % Suppression de x de Lout
            if (k == 1)
                Loutmod(:,1:s_o-1) = Lout(:, 2:s_o);
            elseif (k == s_o)
                Loutmod(:,1:s_o-1) = Lout(:, 1:s_o-1);
            else
                Loutmod(:,1:s_o-1) = [Lout(:, 1:k-1),Lout(:, k+1:s_o)];
            end
            k = k-1;
            s_o = s_o-1;
            Phimod(i, j) = 3;
            Lout = Loutmod;
        end

        k = k+1;
    end


