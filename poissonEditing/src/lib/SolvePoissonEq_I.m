% ======================================================= %
% I = SolvePoissonEq_I(Gx,Gy)                             %
% ======================================================= %
function I = SolvePoissonEq_I(gx,gy)
% ------------------------------------------------------------ %
% Problem: Find the function I that satisfies
%   I = argmin{ int_Omega |Grad(I) - G|^2 dOmega } (P1)
% this problem leads to the E-L equation:
%   I_xx + I_yy = Gx_x + Gy_y                      (1)
% with neaumann border cond. on I i.e.
%   I_n = 0 on dOmega (n is the direction perp. to dOmega)
% ------------------------------------------------------------ %
% Input,
%   - G: Input gradient map. G is a struct that contains
%        x/y-patial derivative in the field G.x/y
%        (G.x/y is a (HxWxC) image). G can be computed
%        e.g. using ComputeGradient()
%
% Output,
%   - I: (HxWxC) solution of poisson Eq. (1) in the Freq.
%                domain.
% ------------------------------------------------------------ %
% Reference:
% M. Di Martino, G. Facciolo and E. Meinhardt-Llopis.
% "Poisson Image Image Editing", Image Processing On Line IPOL,
% 2015.

% Other Refs:
% [Perez et al. 2003]
%   Pérez, P., Gangnet, M., & Blake, A. (2003).
%   Poisson image editing. ACM Transactions on Graphics, 22(3).
% [Morel et al. 2012]
%   Morel, J. M., Petro, a. B., & Sbert, C. (2012).
%   Fourier implementation of Poisson image editing.
%   Pattern Recognition Letters, 33(3), 342–348.
% ------------------------------------------------------------ %
% copyright (c) 2015,
% Matias Di Martino <matiasdm@fing.edu.uy>
% Gabriele Facciolo <facciolo@cmla.ens-cachan.fr>
% Enric Meinhardt   <enric.meinhardt@cmla.ens-cachan.fr>
%
% Licence: This code is released under the AGPL version 3.
% Please see file LICENSE.txt for details.
% ------------------------------------------------------------ %
% Comments and sugestions are welcome at: matiasdm@fing.edu.uy
% M. Di Martino, G. Facciolo and E. Meinhardt-Llopis
% Paris                                                 9/2015
% ============================================================ %

I   = zeros(size(gx)); % init.

% Quadruplicate by symmetry the discrete domain and the
% input gradient field G.

% Extend input gradient field (assuming that the original function
% g is even (g(-x) = g(x)) and hence it's derivative is an odd
% function (g'(-x) = -g'(x))
gx = [gx  -gx(:,end:-1:1,:)]; gx = [gx; gx(end:-1:1,:,:)];
gy = [gy; -gy(end:-1:1,:,:)]; gy = [gy gy(:,end:-1:1,:)];

[H,W,C] = size(gx);
% Define frequency domain,
[wx,wy] = meshgrid(1:W,1:H);
wx0     = floor(W/2)+1; wy0 = floor(H/2)+1; % zero frec
wx      = wx - wx0;
wy      = wy - wy0;

i   = sqrt(-1); % imaginary unit
ft  = @(U) fftshift(fft2(U)); % define a shortcut for the Fourier tran.
ift = @(U) real(ifft2(ifftshift(U))); % and it's inverse.

for c = 1:C,
    Gx   = gx(:,:,c); Gy = gy(:,:,c);

    FT_I = ( (i*2*pi*wx/W).*ft(Gx) + (i*2*pi*wy/H).*ft(Gy) ) ./ ...
           ( (i*2*pi*wx/W).^2      + (i*2*pi*wy/H).^2 );

    FT_I(wy0,wx0) = 0; % set DC value (undefined in the previous div.)

    Aux       = ift(FT_I);
    I(:,:,c)  = Aux(1:H/2,1:W/2); % keep the original portion of the space,
end


end % function

