% ======================================================= %
% GradF = ComputeGradient(F,Method)                       %
% ======================================================= %
function GradF = ComputeGradient(F,Method)
% Input,
%   - F: (HxWxC) image (C=1 gray, C=3 color image)
%   - Method: [def = 'Fourier'] {'Forward','Backward,'Centered','Fourier'}
% Output,
%   - GradF: struct where GradF.x -> (HxWxC) x-partial derivative of F
%                     and GradF.y -> (HxWxC) y-partial derivative of F
%
% ------------------------------------------------------------ %
% Reference:
%   M. Di Martino, G. Facciolo and E. Meinhardt-Llopis.
%   "Poisson Image Image Editing", Image Processing On Line IPOL,
%   2015.
%
% ------------------------------------------------------------ %
% Other relevant refs:
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
% Comments and suggestions are welcome at: matiasdm@fing.edu.uy
% M. Di Martino, G. Facciolo and E. Meinhardt-Llopis
% Paris                                                 9/2015
% ============================================================ %

F       = double(F);

if isempty(Method), Method = 'Fourier'; end % def value,

switch Method,
    case 'Forward',  % -- x'(i) = x(i+1)-x(i) -- %
        GradF.x = [F(:,2:end,:)-F(:,1:end-1,:)  0*F(:,1,:)];
        GradF.y = [F(2:end,:,:)-F(1:end-1,:,:); 0*F(1,:,:)];
    case 'Backward', % -- x'(i) = x(i)-x(i-1) -- %
        GradF.x = [0*F(:,1,:)  F(:,2:end,:)-F(:,1:end-1,:)];
        GradF.y = [0*F(1,:,:); F(2:end,:,:)-F(1:end-1,:,:)];
    case 'Centered', % -- x'(i) = (x(i+1)-x(i-1))/2 -- %
        GradF.x = 1/2 * [0*F(:,1,:)  F(:,3:end,:)-F(:,1:end-2,:)  0*F(:,1,:)];
        GradF.y = 1/2 * [0*F(1,:,:); F(3:end,:,:)-F(1:end-2,:,:); 0*F(1,:,:)];
    case 'Fourier', % -- see e.g. [Morel et al. 2012] -- %
        % First Expand the domain and the image,
        F = [F F(:,end:-1:1,:)]; F = [F; F(end:-1:1,:,:)];
        [H,W,C] = size(F);
        GradF.x = zeros(H,W,C); GradF.y = zeros(H,W,C);
        % initialization
        i       = sqrt(-1); % imaginary unit,
        ft      = @(U) fftshift(fft2(U)); % 2D-Fourier transform,
        ift     = @(U) real(ifft2(ifftshift(U))); % inv. Fourier trans.,
        [Jc,Ic] = meshgrid( 1:W , 1:H );      % define the spatial
        j0 = floor(W/2)+1; i0 = floor(H/2)+1; % frequencies domain
        Jc = Jc - j0; Ic = Ic - i0;           % (center)

        for c = 1:C,
            GradF.x(:,:,c) = ift( (i*2*pi/W*Jc).*ft(F(:,:,c)) );
            GradF.y(:,:,c) = ift( (i*2*pi/H*Ic).*ft(F(:,:,c)) );
        end
        GradF.x = GradF.x(1:H/2,1:W/2,:);
        GradF.y = GradF.y(1:H/2,1:W/2,:);

    otherwise, % -- Display an error -- %
        error('[ComputeGradient] Method unknown')
end

end %function
