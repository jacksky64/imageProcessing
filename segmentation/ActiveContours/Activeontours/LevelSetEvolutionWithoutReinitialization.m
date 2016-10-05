function LevelSetEvolutionWithoutReinitialization(Img,sigma,epsilon,mu,lambda,alf,c0,N,PlotRate,mask)
% This Matlab file demomstrates the level set method in Li et al's paper
%    "Level Set Evolution Without Re-initialization: A New Variational Formulation"
%    in Proceedings of CVPR'05, vol. 1, pp. 430-436.
% Author: Chunming Li, all rights reserved.
% E-mail: li_chunming@hotmail.com
% URL:  http://www.engr.uconn.edu/~cmli/
 if(~exist('PlotRate','var')) 
    PlotRate = 20; 
  end
% Img = imread('twoObj.bmp');  % The same cell image in the paper is used here
Img=double(Img(:,:,1));
% sigma=1.5;    % scale parameter in Gaussian kernel for smoothing.
G=fspecial('gaussian',15,sigma);
Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
[Ix,Iy]=gradient(Img_smooth);
f=Ix.^2+Iy.^2;
g=1./(1+f);  % edge indicator function.

% epsilon=1.5; % the papramater in the definition of smoothed Dirac function

% mu=0.04;
timestep=0.2/mu;
% timestep=5;  % time step, try timestep=10, 20, ..., 50, ...
% mu=0.2/timestep;  % coefficient of the internal (penalizing) energy term P(\phi)
          % Note: the product timestep*mu must be less than 0.25 for stability!

% lambda=5; % coefficient of the weighted length term Lg(\phi)
% alf=1.5;   % coefficient of the weighted area term Ag(\phi);
           % Note: Choose a positive(negative) alf if the initial contour is outside(inside) the object.
           
[nrow, ncol]=size(Img);
% figure(1);
% imagesc(Img, [0, 255]);colormap(gray);hold on;
% text(10,10,{'1.Left click to get points, right click to get end point','2.Drag the shape to desired posiiton',...
%     '3.Double click to run the algorithm'},'FontSize',[12],'Color', 'r');
% 
% % Click mouse to specify initial contour/region
% BW = roipoly;  % get a region R inside a polygon, BW is a binary image with 1 and 0 inside or outside the polygon;
% % c0=4; % the constant value used to define binary level set function;
initialLSF= c0*2*(0.5-mask); % initial level set function: -c0 inside R, c0 outside R;
u=initialLSF;

% [nrow, ncol]=size(Img);  
% initialLSF=c0*ones(nrow,ncol);
% w=round((nrow+ncol)/20);
% initialLSF(w+1:end-w, w+1:end-w)=0;  % zero level set is on the boundary of R. 
%                                      % Note: this can be commented out. The intial LSF does NOT necessarily need a zero level set.
                                     
% initialLSF(w+2:end-w-1, w+2: end-w-1)=-c0; % negative constant -c0 inside of R, postive constant c0 outside of R.
% u=initialLSF;

imshow(Img, []); hold on; axis off;axis equal;
contour(u,[0 0],'r','LineWidth',2);

title('Initial contour');

% start level set evolution
for n=1:N
    u=EVOLUTION(u, g ,lambda, mu, alf, epsilon, timestep, 1);      
    if mod(n,PlotRate)==0
        pause(0.001);
        imshow(Img, []); hold on;axis off;axis equal;
        contour(u,[0 0],'r','LineWidth',2);
        iterNum=['Level Set Evolution Without Re-initialization: A New Variational Formulation ',num2str(n),' iterations'];        
        title(iterNum);
        hold off;
    end
end
imshow(Img, []);hold on;
contour(u,[0 0],'r','LineWidth',2);
axis off;axis equal;
iterNum=['Level Set Evolution Without Re-initialization: A New Variational Formulation ',num2str(n),' iterations'];        
title(iterNum);

function u = EVOLUTION(u0, g, lambda, mu, alf, epsilon, delt, numIter)
%  EVOLUTION(u0, g, lambda, mu, alf, epsilon, delt, numIter) updates the level set function 
%  according to the level set evolution equation in Chunming Li et al's paper: 
%      "Level Set Evolution Without Reinitialization: A New Variational Formulation"
%       in Proceedings CVPR'2005, 
%  Usage:
%   u0: level set function to be updated
%   g: edge indicator function
%   lambda: coefficient of the weighted length term L(\phi)
%   mu: coefficient of the internal (penalizing) energy term P(\phi)
%   alf: coefficient of the weighted area term A(\phi), choose smaller alf 
%   epsilon: the papramater in the definition of smooth Dirac function, default value 1.5
%   delt: time step of iteration, see the paper for the selection of time step and mu 
%   numIter: number of iterations. 
%
% Author: Chunming Li, all rights reserved.
% e-mail: li_chunming@hotmail.com
% http://vuiis.vanderbilt.edu/~licm/

u=u0;
[vx,vy]=gradient(g);
 
for k=1:numIter
    u=NeumannBoundCond(u);
    [ux,uy]=gradient(u); 
    normDu=sqrt(ux.^2 + uy.^2 + 1e-10);
    Nx=ux./normDu;
    Ny=uy./normDu;
    diracU=Dirac(u,epsilon);
    K=curvature_central(Nx,Ny);
    weightedLengthTerm=lambda*diracU.*(vx.*Nx + vy.*Ny + g.*K);
    penalizingTerm=mu*(4*del2(u)-K);
    weightedAreaTerm=alf.*diracU.*g;
    u=u+delt*(weightedLengthTerm + weightedAreaTerm + penalizingTerm);  % update the level set function
end

% the following functions are called by the main function EVOLUTION
function f = Dirac(x, sigma)
f=(1/2/sigma)*(1+cos(pi*x/sigma));
b = (x<=sigma) & (x>=-sigma);
f = f.*b;

function K = curvature_central(nx,ny)
[nxx,junk]=gradient(nx);  
[junk,nyy]=gradient(ny);
K=nxx+nyy;

function g = NeumannBoundCond(f)
% Make a function satisfy Neumann boundary condition
[nrow,ncol] = size(f);
g = f;
g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);          
