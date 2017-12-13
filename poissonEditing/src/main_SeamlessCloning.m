% ============================================================ %
% Poisson image editing
% ------------------------------------------------------------ %
% main_SeamlessCloning(BackIm, ObjIm, Omega, x0, y0, Solv, Mode, OutIm)
% inputs:
%   - BackgroundIm > background image filename, e.g. 'Sunset.png'
%   - ObjIm  > Object image filena, e.g. 'Sailboat.png'
%   - Omega  > Binary image containing the mask over the object image
%              must be of the same size of ObjIm.
%   - x0, y0 > Location of the object in the reference system of the
%              background image. e.g. ['100' '230']
%   - Solver > String containing 'I' or 'II',
%               I: solves the problem by mixing background and object
%               gradients and solving poisson equation over the entire
%               domain (using fourier properties) and imposing neumann
%               border conditions (see [Morel et al. 2012]).
%               II: solver the problem by inserting object gradients inside
%               omega and then integrating inside this region using
%               dirichlet border conditions, (see [Perez et al. 2003]).
%   - Mode > This string indicates which kind of experiment we want to do:
%            'Replace'     Just insert the gradients of the "object" inside
%                          omega.
%            'Max'         Keep the higher gradinet between the object and
%                          the background.
%            'Average'     Average Obj. and Back. gradients.
%            'Sum'         Sum Obj. and Back. gradients.
%   - OutIm  > File name of the output image, e.g. 'out.png'
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

function main_SeamlessCloning( background_image_filename,   ...
                               object_image_filename,       ...
                               omega_image_filename,        ...
                               x0, y0,                      ...
                               solver,                      ...
                               mode,                        ...
                               out_image_filename)

% ============================================ %
% = Read inputs                              = %
% ============================================ %
addpath lib
global verbose,
verbose = 1; % for debugging

% Read input images,
BIm        = double(imread(background_image_filename)); % read Background image
[H ,W ,C]  = size(BIm);

% read ObjIm (to be inserted)
OIm0       = imread(object_image_filename);
[Ho,Wo,Co] = size(OIm0);

% read the mask image with the area of interest,
Omega0     = imread(omega_image_filename);
Omega0     = Omega0==max(Omega0(:));

% Replicate the inputs if some of them is a gray image
if Co==1, OIm0 = cat(3,OIm0,OIm0,OIm0); Co =3; end
if C==1 , BIm  = cat(3,BIm,BIm,BIm); C=3; end
if size(Omega0,3) == 1, Omega0 = cat(3,Omega0,Omega0,Omega0); end

% Sanity check: If the object we are inserting is larger than the
% background image, truncate the object image.
if Ho>H || Wo>W,
    % Bring the region of interest to the center of the image,
    [X,Y]    = meshgrid(1:Wo,1:Ho);
    g_Omega0 = mean(Omega0,3);
    x_min    = max(1, min(X(g_Omega0(:)==1))-3 );
    y_min    = max(1, min(Y(g_Omega0(:)==1))-3 );
    Omega0   = circshift( Omega0, round([1-y_min 1-x_min]) );
    OIm0     = circshift( OIm0,   round([1-y_min 1-x_min]) );
    
    % then, truncate the object image and the mask omega,
    Omega0 = Omega0(1:min(H,Ho),1:min(W,Wo),:);
    OIm0   = OIm0(1:min(H,Ho),1:min(W,Wo),:);
    
    % update the size, 
    [Ho,Wo,~]  = size(OIm0);

    clear g_Omega0 x_min y_min
end

% Create new images Omega and OIm with the same size of BIm --
Omega              = zeros(H,W,C);
OIm                = zeros(H,W,C);

Omega(1:Ho,1:Wo,:) = Omega0;
Omega0             = mean(Omega0,3);
OIm(1:Ho,1:Wo,:)   = OIm0;

[X,Y]              = meshgrid(1:Wo,1:Ho);
xg                 = mean(X(Omega0(:)==1));
yg                 = mean(Y(Omega0(:)==1));
x0                 = str2double(x0);
y0                 = str2double(y0);
Omega              = circshift( Omega, round([y0-yg x0-xg]) );
OIm                = circshift( OIm, round([y0-yg x0-xg]) );
clear xg yg X Y Omega0 OIm0
% ------------------------------------------------------------

if verbose>1, imwrite(uint8(normalize(Omega,[0 255])),'Omega.png'), end

% -------------------------------------------- %
% - Display Exp Parameters and inputs        - %
% -------------------------------------------- %
% print a aux file showing the result of just copy and paste,
aux = BIm; aux(Omega==1) = OIm(Omega==1);
imwrite(uint8(aux),'output_2.png'); clear aux;
if verbose>0,
    c = clock;
    fprintf('====================================\n'             )
    fprintf('Experiment parameters: \n'                          )
    fprintf('date: %4.0f-%02.0f-%02.0f (%02.0f:%02.0f) \n',   ...
             c(1),c(2),c(3),c(4),c(5)                            )
    fprintf('------------------------------------\n'             )
    fprintf(['background im > ' background_image_filename ' \n'] )
    fprintf(['object     im > ' object_image_filename ' \n']     )
    fprintf(['omega      im > ' omega_image_filename ' \n']      )
    fprintf( '[x0 y0]       > %3.0d,%3.0d \n', x0, y0            )
    fprintf( 'verbose       > %2.0d \n', verbose                 )
    fprintf(['Solver        > ' solver      ' \n']               )
    fprintf(['Mode          > ' mode        ' \n']               )
    fprintf('====================================\n'             )
    clear c
end

% ============================================ %
% = (I) First test, combine gradients and    = %
% = and solve poisson eq.                    = %
% ============================================ %
switch solver
    case 'I',
        Diff_Method = 'Fourier';
    case 'II',
        Diff_Method = 'Backward';
    otherwise
        error('Type unknown'),
end
Grad_BIm  = ComputeGradient(BIm,Diff_Method);
Grad_OIm  = ComputeGradient(OIm,Diff_Method);

% -------------------------------------------- %
% - Combine gradients                        - %
% -------------------------------------------- %
G    = CombineGradients(Grad_BIm, Grad_OIm, Omega, mode);
clear Grad_OIm Grad_BIm

% ============================================ %
% = (II) Solve Poisson Equation              = %
% ============================================ %
tic;
switch solver,
    case 'I',
        I = SolvePoissonEq_I(G.x,G.y);
        % recover the mean values to keep image appearence and colors,
        % recall that the mean value is lost when the DC components of
        % Fourier transform are set to zero.
        BIm_outside_Omega = BIm.*(1-Omega);
        I_outside_Omega   = I.*(1-Omega);
        for c = 1:C,
            % mean value of the input image, (outside Omega)
            input_mean_value = sum(sum(BIm_outside_Omega(:,:,c))) / ...
                               sum(sum(1-Omega(:,:,c)));
            % mean value of the output image, (outside Omega)
            out_mean_value   = sum(sum(I_outside_Omega(:,:,c))) /...
                               sum(sum(1-Omega(:,:,c)));
            % Set the mean value,
            I(:,:,c)   = I(:,:,c) - out_mean_value + input_mean_value;
        end
        clear c BIm_outsideOmega I_outsideOmega ...
              input_mean_value out_mean_value
    case 'II',
        I = SolvePoissonEq_II(G.x,G.y,Omega,BIm);
    otherwise
        error('Type unknown'),
end
time = toc;
if verbose>0, mt_printtime(time); end,

% Output
imwrite(uint8(I),out_image_filename);

end %function main

