% Localized Region Based Active Contour Segmentation:
%
% seg = localized_seg(I,init_mask,max_its,rad,alpha,method)
%
% Inputs: I           2D image
%         init_mask   Initialization (1 = foreground, 0 = bg)
%         max_its     Number of iterations to run segmentation for
%         rad         (optional) Localization Radius (in pixels)
%                       smaller = more local, bigger = more global
%         alpha       (optional)  Weight of smoothing term
%                       higer = smoother
%         method      (optional) selects localized energy
%                       1 = Chan-Vese Energy
%                       2 = Yezzi Energy (usually works better)
%
% Outputs: seg        Final segmentation mask (1=fg, 0=bg)
%
% Example:
% img = imread('tire.tif');      %-- load the image
% m = false(size(img));          %-- create initial mask
% m(28:157,37:176) = true;
% seg = localized_seg(img,m,150);
%
% Description: This code implements the paper: "Localizing Region Based
% Active Contours" By Lankton and Tannenbaum.  In this work, typical
% region-based active contour energies are localized in order to handle
% images with non-homogeneous foregrounds and backgrounds.
%
% Coded by: Shawn Lankton (www.shawnlankton.com)
%------------------------------------------------------------------------

function seg = localized_seg(I,init_mask,max_its,rad,alpha,method,FigRefreshRate,display)
  
  %-- default value for parameter alpha is .1
  if(~exist('alpha','var')) 
    alpha = .2; 
  end
  %-- default value for parameter method is 2
  if(~exist('method','var')) 
    method = 2; 
  end
  %-- default behavior is to display intermediate outputs
  if(~exist('display','var'))
    display = true;
  end
   if(~exist('FigRefreshRate','var'))
    FigRefreshRate =20;
  end
  %-- Ensures image is 2D double matrix
  I = im2graydouble(I);    
  %-- Default localization radius is 1/10 of average length
  [dimy dimx] = size(I);
  if(~exist('rad','var')) 
    rad = round((dimy+dimx)/(2*8)); 
    if(display>0) 
      disp(['localiztion radius is: ' num2str(rad) ' pixels']); 
    end
  end
  
  %-- Create a signed distance map (SDF) from mask
  phi = mask2phi(init_mask);

  %--main loop
  for its = 1:max_its   % Note: no automatic convergence test

    %-- get the curve's narrow band
    idx = find(phi <= 1.2 & phi >= -1.2)';  
    [y x] = ind2sub(size(phi),idx);
    
    %-- get windows for localized statistics
    xneg = x-rad; xpos = x+rad;      %get subscripts for local regions
    yneg = y-rad; ypos = y+rad;
    xneg(xneg<1)=1; yneg(yneg<1)=1;  %check bounds
    xpos(xpos>dimx)=dimx; ypos(ypos>dimy)=dimy;

    %-- re-initialize u,v,Ain,Aout
    u=zeros(size(idx)); v=zeros(size(idx)); 
    Ain=zeros(size(idx)); Aout=zeros(size(idx)); 
    
    %-- compute local stats
    for i = 1:numel(idx)  % for every point in the narrow band
      img = I(yneg(i):ypos(i),xneg(i):xpos(i)); %sub image
      P = phi(yneg(i):ypos(i),xneg(i):xpos(i)); %sub phi

      upts = find(P<=0);            %local interior
      Ain(i) = length(upts)+eps;
      u(i) = sum(img(upts))/Ain(i);
      
      vpts = find(P>0);             %local exterior
      Aout(i) = length(vpts)+eps;
      v(i) = sum(img(vpts))/Aout(i);
    end   
 
    %-- get image-based forces
    switch method  %-choose which energy is localized
     case 1,                 %-- CHAN VESE
      F = -(u-v).*(2.*I(idx)-u-v);
     otherwise,              %-- YEZZI
      F = -((u-v).*((I(idx)-u)./Ain+(I(idx)-v)./Aout));
    end
    
    %-- get forces from curvature penalty
    curvature = get_curvature(phi,idx,x,y);  
    
    %-- gradient descent to minimize energy
    dphidt = F./max(abs(F)) + alpha*curvature;  
    
    %-- maintain the CFL condition
    dt = .45/(max(dphidt)+eps);
        
    %-- evolve the curve
    phi(idx) = phi(idx) + dt.*dphidt;

    %-- Keep SDF smooth
    phi = sussman(phi, .5);

    %-- intermediate output
    if((display>0)&&(mod(its,FigRefreshRate) == 0)) 
      showCurveAndPhi(I,phi,its);  
    end
  end
  
  %-- final output
  if(display)
    showCurveAndPhi(I,phi,its);
  end
  
  %-- make mask from SDF
  seg = phi<=0; %-- Get mask from levelset

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%-- AUXILIARY FUNCTIONS ----------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------
  
%-- Displays the image with curve superimposed
function showCurveAndPhi(I, phi, i)
  imshow(I,[]); hold on;
  contour(phi, [0 0], 'g','LineWidth',4);
  contour(phi, [0 0], 'k','LineWidth',2);
  title(['Localized Region Based Active Contour Segmentation ',num2str(i) ' Iterations']); hold off;drawnow;
  
%-- converts a mask to a SDF
function phi = mask2phi(init_a)
  phi=bwdist(init_a)-bwdist(1-init_a)+im2double(init_a)-.5;
  
%-- compute curvature along SDF
function curvature = get_curvature(phi,idx,x,y)
    [dimy, dimx] = size(phi);        

    %-- get subscripts of neighbors
    ym1 = y-1; xm1 = x-1; yp1 = y+1; xp1 = x+1;

    %-- bounds checking  
    ym1(ym1<1) = 1; xm1(xm1<1) = 1;              
    yp1(yp1>dimy)=dimy; xp1(xp1>dimx) = dimx;    

    %-- get indexes for 8 neighbors
    idup = sub2ind(size(phi),yp1,x);    
    iddn = sub2ind(size(phi),ym1,x);
    idlt = sub2ind(size(phi),y,xm1);
    idrt = sub2ind(size(phi),y,xp1);
    idul = sub2ind(size(phi),yp1,xm1);
    idur = sub2ind(size(phi),yp1,xp1);
    iddl = sub2ind(size(phi),ym1,xm1);
    iddr = sub2ind(size(phi),ym1,xp1);
    
    %-- get central derivatives of SDF at x,y
    phi_x  = -phi(idlt)+phi(idrt);
    phi_y  = -phi(iddn)+phi(idup);
    phi_xx = phi(idlt)-2*phi(idx)+phi(idrt);
    phi_yy = phi(iddn)-2*phi(idx)+phi(idup);
    phi_xy = -0.25*phi(iddl)-0.25*phi(idur)...
             +0.25*phi(iddr)+0.25*phi(idul);
    phi_x2 = phi_x.^2;
    phi_y2 = phi_y.^2;
    
    %-- compute curvature (Kappa)
    curvature = ((phi_x2.*phi_yy + phi_y2.*phi_xx - 2*phi_x.*phi_y.*phi_xy)./...
              (phi_x2 + phi_y2 +eps).^(3/2)).*(phi_x2 + phi_y2).^(1/2);        
  
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

%-- level set re-initialization by the sussman method
function D = sussman(D, dt)
  % forward/backward differences
  a = D - shiftR(D); % backward
  b = shiftL(D) - D; % forward
  c = D - shiftD(D); % backward
  d = shiftU(D) - D; % forward
  
  a_p = a;  a_n = a; % a+ and a-
  b_p = b;  b_n = b;
  c_p = c;  c_n = c;
  d_p = d;  d_n = d;
  
  a_p(a < 0) = 0;
  a_n(a > 0) = 0;
  b_p(b < 0) = 0;
  b_n(b > 0) = 0;
  c_p(c < 0) = 0;
  c_n(c > 0) = 0;
  d_p(d < 0) = 0;
  d_n(d > 0) = 0;
  
  dD = zeros(size(D));
  D_neg_ind = find(D < 0);
  D_pos_ind = find(D > 0);
  dD(D_pos_ind) = sqrt(max(a_p(D_pos_ind).^2, b_n(D_pos_ind).^2) ...
                       + max(c_p(D_pos_ind).^2, d_n(D_pos_ind).^2)) - 1;
  dD(D_neg_ind) = sqrt(max(a_n(D_neg_ind).^2, b_p(D_neg_ind).^2) ...
                       + max(c_n(D_neg_ind).^2, d_p(D_neg_ind).^2)) - 1;
  
  D = D - dt .* sussman_sign(D) .* dD;
  
%-- whole matrix derivatives
function shift = shiftD(M)
  shift = shiftR(M')';

function shift = shiftL(M)
  shift = [ M(:,2:size(M,2)) M(:,size(M,2)) ];

function shift = shiftR(M)
  shift = [ M(:,1) M(:,1:size(M,2)-1) ];

function shift = shiftU(M)
  shift = shiftL(M')';
  
function S = sussman_sign(D)
  S = D ./ sqrt(D.^2 + 1);    

  
