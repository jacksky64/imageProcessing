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
% Description: This code implements the paper: "Minimization of 
% Region-Scalable Fitting Energy for Image Segmentation." By Chunming Li.
%
% Coded by: Chunming Li
% E-mail: li_chunming@hotmail.com
% URL:  http://www.engr.uconn.edu/~cmli/
%------------------------------------------------------------------------


function [seg,phi,its] = creaseg_chunmingli(img,init_mask,max_its,length,regularization,scale,thresh,color,display)

    %-- default value for parameter max_its is 100
    if(~exist('max_its','var')) 
        max_its = 100; 
    end
    %-- default value for parameter length is 1
    if(~exist('length','var')) 
        length = 1; 
    end
    %-- default value for parameter penalizing is 1
    if(~exist('regularization','var')) 
        regularization = 1; 
    end    
    %-- default value for parameter scale is 1
    if(~exist('scale','var')) 
        scale = 1;
    end
    %-- default value for parameter thresh is 0
    if(~exist('thresh','var')) 
        thresh = 0;
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
    lambda1 = 1.0;
    lambda2 = 1.0;
    nu = length*255*255; % coefficient of the length term

    %--
    initialLSF = -init_mask.*4 + (1 - init_mask).*4;
    phi = initialLSF;

    %--
    timestep = .1; % time step
    mu = regularization; % coefficient of the level set (distance) regularization term P(\phi)
    epsilon = 1.0; % the paramater in the definition of smoothed Dirac function
    sigma = scale;   % scale parameter in Gaussian kernel
    % Note: A larger scale parameter sigma, such as sigma=10, would make the LBF algorithm more robust 
    %       to initialization, but the segmentation result may not be as accurate as using
    %       a small sigma when there is severe intensity inhomogeneity in the image. If the intensity
    %       inhomogeneity is not severe, a relatively larger sigma can be used to increase the robustness of the LBF
    %       algorithm.
    K = fspecial('gaussian',round(2*sigma)*2+1,sigma);     % the Gaussian kernel
    KI = conv2(img,K,'same');     % compute the convolution of the image with the Gaussian kernel outside the iteration
    % See Section IV-A in the above IEEE TIP paper for implementation.

    KONE = conv2(ones(size(img)),K,'same');  % compute the convolution of Gaussian kernel and constant 1 outside the iteration
	% See Section IV-A in the above IEEE TIP paper for implementation.

    
    %--
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    
    
    %--main loop
    its = 0;      stop = 0;
    prev_mask = init_mask;        c = 0;

    while ((its < max_its) && ~stop)
        
        %--
        phi = LSE_LBF(phi,img,K,KI,KONE,nu,timestep,mu,lambda1,lambda2,epsilon,1);

        new_mask = phi<=0;
        c = convergence(prev_mask,new_mask,thresh,c);
        if c <= 5
            its = its + 1;
            prev_mask = new_mask;
        else stop = 1;
        end      

        %-- intermediate output
        if (display>0)
            if ( mod(its,15)==0 )            
                set(ud.txtInfo1,'string',sprintf('iteration: %d',its),'color',[1 1 0]);
                showCurveAndPhi(phi,ud,color);
                drawnow;
            end
        else
            if ( mod(its,10)==0 )            
                set(ud.txtInfo1,'string',sprintf('iteration: %d',its),'color',[1 1 0]);
                drawnow;
            end
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

    
    
% LSE_LBF implements the level set evolution (LSE) for the method in Chunming Li et al's paper:
%       "Minimization of Region-Scalable Fitting Energy for Image Segmentation", 
%        IEEE Trans. Image Processing(TIP), vol. 17 (10), pp.1940-1949, 2008.
%
% Author: Chunming Li, all rights reserved
% E-mail: li_chunming@hotmail.com
% URL:  http://www.engr.uconn.edu/~cmli/

% For easy understanding of my code, please read the comments in the code that refer
% to the corresponding equations in the above IEEE TIP paper. 
% (Comments added by Ren Zhao at Univ. of Waterloo)
function phi = LSE_LBF(phi0,img,Ksigma,KI,KONE,nu,timestep,mu,lambda1,lambda2,epsilon,numIter)

    phi = phi0;
    for k1=1:numIter
        
        phi = NeumannBoundCond(phi);
        K = curvature_central(phi);
        DrcU = (epsilon/pi)./(epsilon^2.+phi.^2);	% eq.(9)
        [f1,f2] = localBinaryFit(img,phi,KI,KONE,Ksigma,epsilon);
        %-- compute lambda1*e1-lambda2*e2
        s1 = lambda1.*f1.^2-lambda2.*f2.^2;	% compute lambda1*e1-lambda2*e2 in the 1st term in eq. (15) in IEEE TIP 08
        s2 = lambda1.*f1-lambda2.*f2;
        dataForce = (lambda1-lambda2)*KONE.*img.*img+conv2(s1,Ksigma,'same')-2.*img.*conv2(s2,Ksigma,'same'); % eq.(15)
        A = -DrcU.*dataForce;	% 1st term in eq. (15)
        P = mu*(4*del2(phi)-K);	% 3rd term in eq. (15), where 4*del2(u) computes the laplacian (d^2u/dx^2 + d^2u/dy^2)
        L = nu.*DrcU.*K;	% 2nd term in eq. (15)
        phi = phi+timestep*(L+P+A);	% eq.(15)
        
    end

    
%-- compute f1 and f2
function [f1,f2] = localBinaryFit(img,u,KI,KONE,Ksigma,epsilon)

    Hu = 0.5*(1+(2/pi)*atan(u./epsilon));	% eq.(8)
    I = img.*Hu;
    c1 = conv2(Hu,Ksigma,'same');                             
    c2 = conv2(I,Ksigma,'same');	% the numerator of eq.(14) for i = 1
    f1 = c2./(c1);	% compute f1 according to eq.(14) for i = 1
    f2 = (KI-c2)./(KONE-c1);	% compute f2 according to the formula in Section IV-A, 
                                % which is an equivalent expression of eq.(14) for i = 2.
                            

%-- Neumann boundary condition
function g = NeumannBoundCond(f)
    
    [nrow,ncol] = size(f);
    g = f;
    g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
    g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
    g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);  

    
%-- compute curvature    
function k = curvature_central(u)                       

    [ux,uy] = gradient(u);                                  
    normDu = sqrt(ux.^2+uy.^2+1e-10);	% the norm of the gradient plus a small possitive number 
                                        % to avoid division by zero in the following computation.
    Nx = ux./normDu;                                       
    Ny = uy./normDu;
    nxx = gradient(Nx);                              
    [junk,nyy] = gradient(Ny);                              
    k = nxx+nyy;                        % compute divergence


% Convergence Test
function c = convergence(p_mask,n_mask,thresh,c)

    diff = p_mask - n_mask;
    n_diff = sum(abs(diff(:)));
    if n_diff < thresh
        c = c + 1;
    else c = 0;
    end
