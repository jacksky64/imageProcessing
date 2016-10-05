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
% Description: This code implements the paper: "Variational B-Spline 
% Level-Set: A Linear Filtering Approach for Fast Deformable Model 
% Evolution." By Olivier Bernard.
%
% Coded by: Olivier Bernard (www.creatis.insa-lyon.fr/~bernard)
%------------------------------------------------------------------------


function [seg,phi,its] = creaseg_bernard(img,init_mask,max_its,scale,thresh,color,display)
 

    %-- default value for parameter max_its is 1
    if(~exist('max_its','var')) 
        max_its = 100;
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
    
    %-- Ensures image is 2D double matrix
    img = im2graydouble(img);    
    
%     init_mask = init_mask<=0;
    
    %-- Take care that the scale is an integer value strictly lower that 5
    scale = round(scale);
    if ( scale > 4 )
        scale = 4;
    end

    %-- Make sure that image is in correct dimension (multiple of scale)
    [dimI,dimJ] = size(img);
    dimIN = dimI; dimJN = dimJ;
    val = power(2,scale);
    diff = dimIN / val - fix( dimIN / val );
    while ( diff ~= 0 )
        dimIN = dimIN + 1;
        diff = dimIN / val - fix( dimIN / val );
    end
    diff = dimJN / val - fix( dimJN / val );
    while ( diff ~= 0 )
        dimJN = dimJN + 1;
        diff = dimJN / val - fix( dimJN / val );
    end
    imgN = repmat(0,[dimIN dimJN]);
    imgN(1:size(img,1),1:size(img,2)) = img;
    for i=(dimI+1):1:dimIN
        imgN(i,1:dimJ) = img(end,:);
    end
    for j=(dimJ+1):1:dimJN
        imgN(1:dimI,j) = img(:,end);
    end
    img = imgN;
    clear imgN;
    
    %-- Same for mask
    init_maskN = repmat(0,[dimIN dimJN]);
    init_maskN(1:size(init_mask,1),1:size(init_mask,2)) = init_mask;
    init_mask = init_maskN;
    clear init_maskN;
    
    %-- Compute the corresponding bspline filter used for the comutation of
    %-- the energy gradient from the Bslpine coefficients
    if ( scale == 0 )
        filter = [ 0.1667 0.6667 0.1667 ];
    elseif ( scale == 1 )
        filter = [ 0.0208 0.1667 0.4792 0.6667 0.4792 0.1667 0.0208 ];
    elseif ( scale == 2 )
        filter = [ 0.0026 0.0208 0.0703 0.1667 0.3151 0.4792 0.6120 ...
            0.6667 0.6120 0.4792 0.3151 0.1667 0.0703 0.0208 0.0026 ];
    elseif ( scale == 3 )
        filter = [ 3.2552e-004 0.0026 0.0088 0.0208 0.0407 0.0703 0.1117 ...
            0.1667 0.2360 0.3151 0.3981 0.4792 0.5524 0.6120 0.6520 ...
            0.6667 0.6520 0.6120 0.5524 0.4792 0.3981 0.3151 0.2360 ...
            0.1667 0.1117 0.0703 0.0407 0.0208 0.0088 0.0026 3.2552e-004 ];
    elseif ( scale == 4 )
        filter = [ 4.0690e-005 3.2552e-004 0.0011 0.0026 0.0051 0.0088 ...
            0.0140 0.0208 0.0297 0.0407 0.0542 0.0703 0.0894 0.1117 ...
            0.1373 0.1667 0.1997 0.2360 0.2747 0.3151 0.3565 0.3981 ...
            0.4392 0.4792 0.5171 0.5524 0.5843 0.6120 0.6348 0.6520 ...
            0.6629 0.6667 0.6629 0.6520 0.6348 0.6120 0.5843 0.5524 ...
            0.5171 0.4792 0.4392 0.3981 0.3565 0.3151 0.2747 0.2360 ...
            0.1997 0.1667 0.1373 0.1117 0.0894 0.0703 0.0542 0.0407 ...
            0.0297 0.0208 0.0140 0.0088 0.0051 0.0026 0.0011 ...
            3.2552e-004 4.0690e-005 ];        
    else
        filter = 0;
    end
    
    
    %-- Create a signed distance map (SDF) from mask
    phi = mask2phi(init_mask);
    
    %-- Create BSpline coefficient image from phi
    [bspline,phi] = Initialization(phi,scale);

    %--
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');

    %--main loop
    its = 0;      stop = 0;
    prev_mask = init_mask;        c = 0;
    [u,v,NRJ] = MinimizedFromFeatureParameters(0,0,phi,img,bitmax); % Initializing u, v, NRJ
    
    while ((its < max_its) && ~stop)
                
        %-- Minimized energy from the BSpline coefficients
        [u,v,phi,bspline,img,NRJ] = ...
            MinimizedFromBSplineCoefficients(u,v,phi,bspline,img,NRJ,filter,scale);
 
        new_mask = phi<=0;
        c = convergence(prev_mask,new_mask,thresh,c);
        if c <= 5
            its = its + 1;
            prev_mask = new_mask;
        else stop = 1;
        end      
        
        %-- intermediate output
        if (display>0)
            if ( mod(its,1)==0 )            
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
    phi = phi(1:dimI,1:dimJ);
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


%-- converts a mask to a SDF
function phi = mask2phi(init_a)

    phi=bwdist(init_a)-bwdist(1-init_a)+im2double(init_a)-.5;
  
    
%-- Converts image to one channel (grayscale) double
function img = im2graydouble(img)    

    [dimy, dimx, c] = size(img);
    if(isfloat(img)) % image is a double
    if(c==3) 
        img = rgb2gray(uint8(img)); 
    end
    else           % image is a int
    if(c==3) 
        img = rgb2gray(img); 
    end
    img = double(img);
    end


%-- Converts image to BSpline coeffcients image (double)
function BSpline = ConvertImageToBSpline(BSpline)

    for i=1:1:size(BSpline,1)
        BSpline(i,:) = ConvertSignalToBSpline(BSpline(i,:));
    end    
    for j=1:1:size(BSpline,2)
        BSpline(:,j) = ConvertSignalToBSpline(BSpline(:,j));
    end


%-- Converts Signal to BSpline coefficients signal(double)
function BSpline = ConvertSignalToBSpline(BSpline)

    z = sqrt(3)-2;
    lambda = (1-z)*(1-1/z);

    BSpline = lambda*BSpline;
    BSpline(1) = GetInitialCausalCoefficient(BSpline,z);
    for n=2:1:length(BSpline)
        BSpline(n) = BSpline(n) + z * BSpline(n-1);
    end

    BSpline(end) = (z * BSpline(end-1) + BSpline(end)) * z / (z * z - 1);
    for n=(length(BSpline)-1):-1:1
        BSpline(n) = z * ( BSpline(n+1) - BSpline(n) );
    end


%-- Compute first BSpline coefficients signal (double)
function val = GetInitialCausalCoefficient(BSpline,z)

    len = length(BSpline);
    tolerance = 1e-6;
    z1 = z;
    zn = power(z,len-1);
    sum = BSpline(1) + zn * BSpline(end);
    horizon = 2 + round( log(tolerance) / log(abs(z)));
    if ( horizon > len )
        horizon = len;
    end
    zn = zn * zn;
    for n=2:1:horizon
        zn = zn / z;
        sum = sum + (z1 + zn) * BSpline(n);
        z1 = z1 * z;
    end
    val = sum / (1-power(z,2*len-2));
  

%-- Converts BSpline coeffcients image to image (double)    
function Image = ConvertBSplineToImage(Image)

    for i=1:1:size(Image,1)
        Image(i,:) = ConvertBSplineToSignal(Image(i,:));
    end
    for j=1:1:size(Image,2)
        Image(:,j) = ConvertBSplineToSignal(Image(:,j));
    end


%-- Converts BSpline coeffcients signal to signal (double)     
function Signal = ConvertBSplineToSignal(BSpline)

    len = length(BSpline);
    Signal = zeros(size(BSpline));
    
    kernelFilter = [4/6 1/6];
    Signal(1) = BSpline(1) * kernelFilter(1) + 2 * BSpline(2) * kernelFilter(2);
    for n=2:1:(len-1)
        Signal(n) = BSpline(n) * kernelFilter(1) + ...
            BSpline(n-1) * kernelFilter(2) + BSpline(n+1) * kernelFilter(2);
    end
    Signal(end) = BSpline(end) * kernelFilter(1) + 2 * BSpline(end-1) * kernelFilter(2);    
    

%-- Create initial BSpline coefficients from phi with normalization procedure
function [bspline,phi] = Initialization(phi,scale)

    phiDown = imresize(phi,1/power(2,scale));
    bspline = ConvertImageToBSpline(phiDown);
    Linf = max(abs(bspline(:)));
    bspline = 3 * bspline / Linf;
    phiDown = ConvertBSplineToImage(bspline);
    phi = imresize(phiDown,power(2,scale));


%-- Minimized energy from the feature parameters
function [u,v,NRJ] = MinimizedFromFeatureParameters(u,v,phi,img,NRJ)
    
    %-- Compute new feature parameters   
    un = sum( img(:) .* heavyside(phi(:)) ) / sum( heavyside(phi(:)) );
    vn = sum( img(:) .* ( 1 - heavyside(phi(:)) ) ) / sum( 1 - heavyside(phi(:)) );
    NewNRJ = sum( (img(:)-un).^2 .* heavyside(phi(:)) + (img(:)-vn).^2 .* (1-heavyside(phi(:))) );

    %-- Update feature parameters
    if ( NewNRJ < NRJ )
        u = un;
        v = vn;
        NRJ = NewNRJ;
    end

    
%-- Compute the regularized heaviside function
function y = heavyside(x)

    epsilon = 0.5;
    y = 0.5 * ( 1 + (2/pi) * atan(x/epsilon) );

    
%-- Compute the regularized dirac function
function y = dirac(x)

    epsilon = 0.5;
    y = (1/(pi*epsilon)) ./ ( 1 + (x/epsilon).^2 );
    
    
%-- Minimized energy from the BSpline coefficients
function [u,v,phi,bspline,img,NRJ] = ...
    MinimizedFromBSplineCoefficients(u,v,phi,bspline,img,NRJ,filter,scale)

    %-- Compute energy gradient image
    feature = ( (img-u).^2 - (img-v).^2 ) .* dirac(phi);
    valMax = max(abs(feature(:)));
    feature = feature / valMax;
    grad = ComputeGradientEnergyFromBSpline(feature,filter,scale);
    
    %-- Compute Gradient descent with feedback adjustement
    nbItMax = 5;
    diffNRJ = 1;
    it = 0;
    mu = 1.5;
    
    while ( ( diffNRJ > 0 ) && ( it < nbItMax ) )
        
        %-- Update mu and it
        it = it + 1;
        mu = mu / 1.5;
        
        %-- Compute new BSpline values
        bspline_new = bspline - mu*grad;
        Linf = max(abs(bspline_new(:)));
        bspline_new = 3 * bspline_new / Linf;
        
        %-- Compute the corresponding Levelset
        phi_new = MultiscaleUpSampling(bspline_new,scale);
        
        %-- Compute the corresponding energy value
        [u_new,v_new,NRJ_new] = MinimizedFromFeatureParameters(u,v,phi_new,img,NRJ);
        
        % Update diffNRJ value
        diffNRJ = NRJ_new - NRJ;
        
    end
        
    if ( diffNRJ < 0 )
        bspline = bspline_new;
        phi = phi_new;
        NRJ = NRJ_new;
        u = u_new;
        v = v_new;
    end
    
    
%-- Compute the energy gradient form the Bspline taking into account the 
%-- scaling factor    
function grad = ComputeGradientEnergyFromBSpline(feature,filter,scale)

    nI = size(feature,1);
    nJ = size(feature,2);
    nIScale = nI / power(2,scale);
    nJScale = nJ / power(2,scale);
    tmp = zeros(nIScale,nJ);
    grad = zeros(nIScale,nJScale);

    for j=1:1:nJ
        tmp(:,j) = GetMultiscaleConvolution(feature(:,j),filter,scale);
    end
    for i=1:1:nIScale
        vec = GetMultiscaleConvolution(tmp(i,:),filter,scale);
        grad(i,:) = vec;
    end    
    
   
   
%-- Compute the energy gradient form the Bspline taking into account the
%-- scaling factor for a signal
function out = GetMultiscaleConvolution(in,filter,scale)

    %-- parameters
    scaleN = power(2,scale);    
    width = length(in);	
    widthScale = width / scaleN;    
    nx2 = 2 * width - 2;	
    size = scaleN * 4 - 1;
    index = zeros(1,size); 
    out = zeros(1,widthScale);

    %-- main loop
    for n=0:1:(widthScale-1)
        %-- Compute indexes
        x = n * scaleN;
        i = round(floor(x)) - floor(size/2);
        for k=0:1:(size-1)
            index(k+1) = i;
            i = i + 1;
        end
        %-- Apply the anti-mirror boundary conditions
        subImage = zeros(1,size);
        for k=0:1:(size-1)
            m = index(k+1);
            if ( (m>=0) && (m<width) )
                subImage(k+1) = in(m+1);
            elseif (m>=width)
                subImage(k+1) = 2*in(width)-in(nx2-m+2);
            elseif (m<0) 
                subImage(k+1) = 2*in(1)-in(-m+1);
            end
        end
        %-- Compute value
        w = 0;
        for k=0:1:(size-1)
            w = w + filter(k+1) * subImage(k+1);
        end
        out(n+1) = w;
    end

%-- Upsample by a factor of power(2,h)
function output = MultiscaleUpSampling(input,h)

dimI = size(input,1);
dimJ = size(input,2);
scaleDimI = dimI * power(2,h);
scaleDimJ = dimJ * power(2,h);
output = zeros(scaleDimI,scaleDimJ);

%-- Initialization
nx2 = 2 * dimI - 2;
ny2 = 2 * dimJ - 2;
scale = power(2,h);
xIndex = zeros(1,4);
yIndex = zeros(1,4);
xWeight = zeros(1,4);
yWeight = zeros(1,4);

subImage = zeros(4,4);

%-- Compute the sampled image
for u=0:1:(scaleDimI-1)
    for v=0:1:(scaleDimJ-1)

        %-- Initialization
        x = u / scale;
        y = v / scale;
        %-- Compute the interpolation indexes
        i = floor(x) - 1;
        j = floor(y) - 1;
        for k=0:1:3
            xIndex(k+1) = i;
            yIndex(k+1) = j;
		    i = i + 1;
		    j = j + 1;
        end
		%-- Compute the interpolation weights
		%-- x --%
		w = x - xIndex(2);
		xWeight(4) = (1.0 / 6.0) * w * w * w;
		xWeight(1) = (1.0 / 6.0) + (1.0 / 2.0) * w * (w - 1.0) - xWeight(4);
		xWeight(3) = w + xWeight(1) - 2.0 * xWeight(4);
		xWeight(2) = 1.0 - xWeight(1) - xWeight(3) - xWeight(4);
		%-- y --%
		w = y - yIndex(2);
		yWeight(4) = (1.0 / 6.0) * w * w * w;
		yWeight(1) = (1.0 / 6.0) + (1.0 / 2.0) * w * (w - 1.0) - yWeight(4);
		yWeight(3) = w + yWeight(1) - 2.0 * yWeight(4);
		yWeight(2) = 1.0 - yWeight(1) - yWeight(3) - yWeight(4); 
        
        %-- Apply the anti-mirror boundary conditions         
        for k=0:1:3
            m = xIndex(k+1);
            for l=0:1:3
                n = yIndex(l+1);
                if ( (m>=0) && (m<dimI) )
                    if ( (n>=0) && (n<dimJ) )
                        subImage(k+1,l+1) = input(m+1,n+1);
                    elseif (n>=dimJ)
                        subImage(k+1,l+1) = 2*(input(m+1,dimJ))-input(m+1,ny2-n+2);
                    elseif (n<0)
                        subImage(k+1,l+1) = 2*(input(m+1,n+2))-input(m+1,n+3);
                    end
                elseif (m>=dimI)
                    if ( (n>=0) && (n<dimJ) )
                        subImage(k+1,l+1) = 2*(input(dimI,n+1))-input(nx2-m+2,n+1);
                    elseif (n>=dimJ)
                        subImage(k+1,l+1) = 2*(input(dimI,dimJ))-input(nx2-m+2,ny2-n+2);
                    elseif (n<0)
                        subImage(k+1,l+1) = 2*(input(dimI,n+2))-input(nx2-m+2,n+3);
                    end
                elseif (m<0) 
                    if ( (n>=0) && (n<dimJ) )
                        subImage(k+1,l+1) = 2*(input(m+2,n+1))-input(m+3,n+1);
                    elseif (n>=dimJ)
                        subImage(k+1,l+1) = 2*(input(m+2,dimJ))-input(m+3,ny2-n+2); 
                    elseif (n<0)
                        subImage(k+1,l+1) = 2*(input(m+2,n+2))-input(m+3,n+3);
                    end
                end
            end
        end

        %-- perform interpolation 
		val = 0;
        for k=0:1:3
            w = 0;
            for l=0:1:3
                w = w + xWeight(l+1) * subImage(l+1,k+1);
            end
            val = val + yWeight(k+1) * w;
        end
        output(u+1,v+1) = val;
    end
end
    
% Convergence Test
function c = convergence(p_mask,n_mask,thresh,c)
    diff = p_mask - n_mask;
    n_diff = sum(abs(diff(:)));
    if n_diff < thresh
        c = c + 1;
    else c = 0;
    end
    
