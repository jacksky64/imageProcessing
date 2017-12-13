% ======================================================= %
% I = SolvePoissonEq_II(G)                                   %
% ======================================================= %
function I = SolvePoissonEq_II(gx,gy,Omega,F)
% ------------------------------------------------------- %
% Problem: Find the function I that satisfies
%   I_omega = argmin{ int_Omega |Grad(I) - G|^2 dOmega } (P1)
% this problem leads to the E-L equation:
%   I_xx + I_yy = Gx_x + Gy_y                      (1)
% with (dirichlet) border cond.
%   I(dOmega) = F(dOmega)
% ------------------------------------------------------- %
% Input,
%   - gx and gy: are (HxWxC) images containing x and y partial
%               derivatives
%   - Omega: (HxWxC) binary image containing 1/0 if x is/isn't in Omega.
%   - F: (HxWxC) "Background image". It is used to impose dirichlet
%        boundary conditions, i.e. I(dOmega) = F(dOmega);
%
% Output,
%   - I: (HxWxC) I = F outside Omega and the solution of poisson Eq. (1)
%        inside Omega.
%
% ------------------------------------------------------------ %
% Reference:
%   M. Di Martino, G. Facciolo and E. Meinhardt-Llopis.
%   "Poisson Image Image Editing", Image Processing On Line IPOL,
%   2015.
%
% ------------------------------------------------------------ %
% Other relevants refs:
% [Perez et al. 2003]
%   P??rez, P., Gangnet, M., & Blake, A. (2003).
%   Poisson image editing. ACM Transactions on Graphics, 22(3).
% [Morel et al. 2012]
%   Morel, J. M., Petro, a. B., & Sbert, C. (2012).
%   Fourier implementation of Poisson image editing.
%   Pattern Recognition Letters, 33(3), 342-348.
% ------------------------------------------------------------ %
% copyright (c) 2015,
% Matias Di Martino <matiasdm@fing.edu.uy>
% Gabriele Facciolo <facciolo@cmla.ens-cachan.fr>
% Enric Meinhardt   <enric.meinhardt@cmla.ens-cachan.fr>
%
% Licence: This code is released under the AGPL version 3.
% Please see file LICENSE.txt for details.
% Complete
% ------------------------------------------------------------ %
% Comments and sugestions are welcome at: matiasdm@fing.edu.uy
% M. Di Martino, G. Facciolo and E. Meinhardt-Llopis
% Paris                                                 9/2015
% ============================================================ %

if size(gx,3)>1,
    I = zeros(size(gx)); % init
    for c = 1:3, % solve for each channel indep.
        I(:,:,c) = SolvePoissonEq_II(...
                      gx(:,:,c),gy(:,:,c),Omega(:,:,c),F(:,:,c));
    end
else % solve the problem if the input is a single channel,
     % (from now on we can assume that images are HxWx1.)
F = double(F);

% ==================================================== %
% = (o) Expand inputs to have Neumann Bound. Cond.   = %
% ==================================================== %
% this is necessary just when Omega reaches the edge of
% the background image. In that case we don't have pixels
% to set dirichlet bord. cond., hence we impose neumann B.C.
n_pad = 1;
gx    = padarray(gx,n_pad*[1 1 0],0);
gy    = padarray(gy,n_pad*[1 1 0],0);
Omega = padarray(Omega,n_pad*[1 1 0],'symmetric');
F     = padarray(F,n_pad*[1 1 0],'symmetric');

% ==================================================== %
% = (i) Definitions                                  = %
% ==================================================== %
[H,W] = size(gx); HW = H*W;

% --------------------------------------------- %
% -(i).a Define Dx, Dy and L matrices         - %
% --------------------------------------------- %
% {d(U)/di}(:) = Di*U(:), i = x,y,
% pad the image domain (S) with zeros
N                     = (H+2)*(W+2);
mask                  = zeros(H+2,W+2);
mask(2:end-1,2:end-1) = 1; % pixels inside the domain S
idxS                  = find(mask==1); % keep the index of Pixels in S.
clear mask

% define the dilated domain in order to restrict the definition of the
% operators only to the concerned pixels.
% The mask dOmega is the same size as mask
dOmega = padarray(Omega,[1 1],0,'both');
dOmega = dOmega | circshift(dOmega,[1 0]) | circshift(dOmega,[-1 0]) ...
          | circshift(dOmega,[0 1]) | circshift(dOmega,[0 -1]);
dOmega([1 end],:,:) = 0; dOmega(:,[1 end],:) = 0;   
%Keep the index of Pixels in Omega \cup partial Omega.
idx    = find(dOmega==1);

% forward scheme,
Dx = (sparse(idx,idx+(H+2),1,N,N) - sparse(idx,idx,1,N,N));
Dy = (sparse(idx,idx+1    ,1,N,N) - sparse(idx,idx,1,N,N));

L  = sparse(idx,idx,-4,N,N)  ...
   + sparse(idx,idx+1,1,N,N) ...
   + sparse(idx,idx-1,1,N,N) ...
   + sparse(idx,idx+(H+2),1,N,N) ...
   + sparse(idx,idx-(H+2),1,N,N);

% Keep pixels inside S
Dx = Dx(idxS,idxS); Dy = Dy(idxS,idxS); L  = L(idxS,idxS);
clear idx idxS N

% Correct the weight for those pixels that lie in the borders of S,
Dx = Dx - sparse(1:HW,1:HW,sum(Dx,2),HW,HW);
Dy = Dy - sparse(1:HW,1:HW,sum(Dy,2),HW,HW);
L  = L  - sparse(1:HW,1:HW,sum(L ,2),HW,HW);

% --------------------------------------------- %
% -(i).b Define M_Omega, M_dOmega             - %
% --------------------------------------------- %
% M_Omega is a HWxHW matrix such that M_Omega*x has the value of x(:) if
% lies in Omega and 0 otherwise
M_Omega = sparse(1:HW,1:HW,Omega(:),HW,HW);

% M_dOmega is a HWxHW matrix such that M_dOmega*x has the value of x(:) if
% lies in dOmega and 0 otherwise
dOmega = padarray(Omega,[1 1],0,'both');
dOmega =    circshift(dOmega,[1 0]) | circshift(dOmega,[-1 0]) ...
          | circshift(dOmega,[0 1]) | circshift(dOmega,[0 -1]);

dOmega           = dOmega(2:end-1,2:end-1);
dOmega(Omega==1) = 0;

M_dOmega = sparse(1:HW,1:HW,dOmega(:),HW,HW);

% ==================================================== %
% = (ii) Build the system                            = %
% ==================================================== %
idx = find(Omega == 1);
S   = sparse(1:length(idx),idx,1,length(idx),HW);
A = L*M_Omega; % keep as unknowns just the pixels that lies inside Omega
A = S*A*S';% S*A corresponds to the rows of A that corresponds to px in Omega

b  = Dx*gx(:) + Dy*gy(:) - L*M_dOmega*F(:);
b  = S*b;

x = A\b;

I              = F;
I(Omega(:)==1) = x;

% Remove the pixels added
I = I(n_pad+1:end-n_pad,n_pad+1:end-n_pad);

end

end % function

