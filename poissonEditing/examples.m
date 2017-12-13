% ============================================================ %
% Poisson image editing
% ------------------------------------------------------------ %
% This code illustrates who to use the codes
% and techiques described in the artilcle:
%
% [Di Martino et al. 2015]
% M. Di Martino, G. Facciolo and E. Meinhardt-Llopis.
% "Poisson Image Image Editing", Image Processing On Line IPOL,
% 2015.
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

close all
clear all
clc
home

% add the path where the important functions are and
% also the folder that contains some example images.
addpath src src/lib
%  ========================================================== %
%% (A) First example: Seamless cloning,                     = %
%  ========================================================== %
fprintf('====================================================== \n'    )
fprintf('= (A) First example: Seamless cloning,               = \n'    )
fprintf('====================================================== \n'    )
% -------------------------------------------------------
% - (0) Set experiment parameters                       -
% -------------------------------------------------------
% Input Images,
BackgroundImageFileName = 'images/boats.png';  % some example images are provided
ObjectImageFileName     = 'images/sunset.png'; % in the "./images" folder.
OmegaImageFileName      = 'images/boats_omega.png';

% Location of the centroid of Omega in the background image,
x0 = 460;
y0 = 450;

% Define how to compute the guide vector field
Diff_Method = 'Backward';% TRY: 'Forward','Backward,'Centered','Fourier'

% Define the way Background and Object gradients' are combined
% inside Omega,
mode = 'Max'; % TRY: 'Replace','Max','Average'.

% Select the numerical methods to be used to solve the Poisson Equation.
solver = 'II'; % TRY: 'I','II'.
% The solver 'I' corresponds to the "Fourier approach" and solver 'II'
% to "Finite differences aproach".
% (Both explained in ref. [Di Martino et al. 2015])

% -------------------------------------------------------
% - (1) Read some input images (I1 source,              -
% -     I2 destination and Omega)                       -
% -------------------------------------------------------
OIm    = imread(BackgroundImageFileName);
BIm    = imread(ObjectImageFileName);
Omega  = imread(OmegaImageFileName);

% Display inputs --------------
if size(Omega,3)==1&&size(OIm,3)==3, Omega=cat(3,Omega,Omega,Omega); end
s = get(0,'ScreenSize');
[H,W,c] = size(OIm); name = 'I1 (source image)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-W s(4)-H+40 W H],'Name',name, ...
       'NumberTitle','off'); imshow(OIm)
[H,W,c] = size(OIm); name = 'Selected Region (Omega)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-W s(4)-1.5*H W H],'Name',name, ...
       'NumberTitle','off'); imshow(OIm.*uint8((Omega==255)))
[H,W,c] = size(BIm); name = 'I2 (Destination Image)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-2*W s(4)-H W H],'Name',name, ...
       'NumberTitle','off'); imshow(BIm)
% -----------------------------

% **********************************************************
% * What follows are the main steps performed in           *
% * main_SeamlessCloing.m                                  *
% **********************************************************
BIm   = double(BIm); OIm = double(OIm);
Omega = double(Omega==255);

% Create new images Omega and OIm with the same size of BIm and with
% the centroid of Omega in the position defined by [x0,y0]
Omega0             = Omega;
OIm0               = OIm;
[Ho,Wo,Co]         = size(Omega0);
[H,W,C]            = size(BIm);
Omega              = zeros(H,W,C);
OIm                = zeros(H,W,C);

Omega(1:Ho,1:Wo,:) = Omega0;
Omega0             = mean(Omega0,3);
OIm(1:Ho,1:Wo,:)   = OIm0;

[X,Y]              = meshgrid(1:Wo,1:Ho);
xg                 = mean(X(Omega0(:)==1));
yg                 = mean(Y(Omega0(:)==1));
Omega              = circshift( Omega, round([y0-yg x0-xg]) );
OIm                = circshift( OIm  , round([y0-yg x0-xg]) );
clear xg yg X Y Omega0 OIm0

% -------------------------------------------------------
% - (2) Comput and combine gradients                    -
% -------------------------------------------------------
% 2.1 Comput gradients,
Grad_OIm  = ComputeGradient(OIm,Diff_Method); % grad. of the "Object"
Grad_BIm  = ComputeGradient(BIm,Diff_Method); % grad. of the "Background"

% 2.2 Combine gradients,
G    = CombineGradients(Grad_BIm, Grad_OIm, Omega, mode);
clear Grad_OIm Grad_BIm

% -------------------------------------------------------
% - (3) Solve poisson equation                          -
% -------------------------------------------------------
% The solver II solves the problem with an algebraic approach only in the
% specified domain and with dirichlet border conditions.
% The solver I uses Fourier properties to solve the problem in the entire
% domain using Neaumann border conditions.
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
mt_printtime(time); % display the time of solv. Poisson Eq.

% Display Results --------------
[H,W,c] = size(I); name = 'I (output image)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-W s(4)-H+40 W H],'Name',name, ...
       'NumberTitle','off'); imshow(uint8(I))
% ------------------------------
fprintf('End of the first example, press any key to continue.\n')
pause
close all
clear all

%  ========================================================== %
%% (B) Second example: Contrast enhancement,                = %
%  ========================================================== %
fprintf('====================================================== \n'    )
fprintf('= (B) Second example: Contrast enhancement,          = \n'    )
fprintf('====================================================== \n'    )
% -------------------------------------------------------
% - (0) Set experiment parameters                       -
% -------------------------------------------------------
% Input Images,
InputImageFileName = 'images/catedral.png';  % some example images are provided

% Define how to compute the guide vector field
Diff_Method = 'Fourier';% TRY: 'Forward','Backward,'Centered','Fourier'

% Set the threshold T (see [Di Martino et al. 2015])
th    = 20; % the gradients in the regions of the image with intensity
            % values below this threshold are amplified.
            % Test values in [0 255],

% Set amplification factor,
alpha = 2.5;

% Select the numerical methods to be used to solve the Poisson Equation.
solver = 'I'; % TRY: 'I','II'.
% The solver 'I' corresponds to the "Fourier approach" and solver 'II'
% to "Finite differences aproach".
% (Both explained in ref. [Di Martino et al. 2015])

% -------------------------------------------------------
% - (1) Read an input image I1                          -
% -------------------------------------------------------
Iin = imread(InputImageFileName);

% Display input --------------
s = get(0,'ScreenSize');
[H,W,C] = size(Iin); name = 'Iin (input image)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-W s(4)-H+40 W H],'Name',name, ...
       'NumberTitle','off'); imshow(Iin)
% -----------------------------

% **********************************************************
% * What follows are the main steps performed in           *
% * main_FiltImage.m and the compiled version of it.       *
% **********************************************************
% -------------------------------------------------------
% - (2) Comput and modify the gradient map              -
% -------------------------------------------------------
% 2.1 Comput gradients,
G           = ComputeGradient(Iin,Diff_Method);

% 2.2 Modify gradient map G,
% set the domain we must modify
Omega = Iin < th; % domain we will modify

% Amplify the gradients in the dark areas
G.x(Omega==1) = alpha*G.x(Omega==1);
G.y(Omega==1) = alpha*G.y(Omega==1);

% -------------------------------------------------------
% - (3) Solve poisson equation                          -
% -------------------------------------------------------
tic;
switch solver,
    case 'I',
        I = SolvePoissonEq_I (G.x,G.y);
    case 'II',
        I = SolvePoissonEq_II(G.x,G.y,Omega,Iin);
    otherwise
        error('Type unknown'),
end
time = toc;
mt_printtime(time);

% Keep the image in the range [0 255] (the modification of the gradient
% field may modify the dinamic range of the image).
I    = normalize(I,[0 255]);

% Display Results --------------
[H,W,c] = size(I); name = 'I (output image)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-W s(4)-H+40 W H],'Name',name, ...
       'NumberTitle','off'); imshow(uint8(I));
% ------------------------------

fprintf('End of the second example, press any key to continue.\n')
pause
close all
clear all

%  ========================================================== %
%% (C) Third example: Texture Flattening,                   = %
%  ========================================================== %
fprintf('====================================================== \n'    )
fprintf('= (C) Third example: Texture Flattening,             = \n'    )
fprintf('====================================================== \n'    )
% -------------------------------------------------------
% - (0) Set experiment parameters                       -
% -------------------------------------------------------
% Input Images,
InputImageFileName = 'images/writing.png';  % some example images are provided

% Define how to compute the guide vector field
Diff_Method = 'Fourier';% TRY: 'Forward','Backward,'Centered','Fourier'

% Set the threshold T (see [Di Martino et al. 2015])
th    = 5; % the gradients whose modulus is below this threshold are set
            % to zero.

% Select the numerical methods to be used to solve the Poisson Equation.
solver = 'I'; % TRY: 'I','II'.
% The solver 'I' corresponds to the "Fourier approach" and solver 'II'
% to "Finite differences aproach".
% (Both explained in ref. [Di Martino et al. 2015])

% -------------------------------------------------------
% - (1) Read an input image                           -
% -------------------------------------------------------
Iin      = imread(InputImageFileName);

% Display input --------------
s = get(0,'ScreenSize');
[H,W,C] = size(Iin); name = 'Iin (input image)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-W s(4)-H+40 W H],'Name',name, ...
       'NumberTitle','off'); imshow(Iin)
% -----------------------------

% **********************************************************
% * What follows are the main steps performed in           *
% * main_FiltImage.m and the compiled version of it.       *
% **********************************************************
% -------------------------------------------------------
% - (2) Comput and modify the gradient map              -
% -------------------------------------------------------
% 2.1 Comput gradients,
G           = ComputeGradient(Iin,Diff_Method);

% 2.2 Modify gradient map G,
Omega = sqrt( G.x.^2 + G.y.^2 ) < th; % domain we will modify

alpha = 0; % attenuation factor,

% Amplify the gradients in the dark areas
G.x(Omega==1) = alpha*G.x(Omega==1);
G.y(Omega==1) = alpha*G.y(Omega==1);

% -------------------------------------------------------
% - (3) Solve poisson equation                          -
% -------------------------------------------------------
tic;
switch solver,
    case 'I',
        I = SolvePoissonEq_I (G.x,G.y);
    case 'II',
        I = SolvePoissonEq_II(G.x,G.y,Omega,Iin);
    otherwise
        error('Type unknown'),
end
time = toc;
mt_printtime(time);

% Keep the image in the range [0 255] (the modification of the gradient
% field may modify the dinamic range of the image).
I = normalize(I,[0 255]);

% Display Results --------------
[H,W,c] = size(I); name = 'I (output image)';
figure('Color',[1 1 1],'MenuBar','none',...
       'Position',[s(3)-W s(4)-H+40 W H],'Name',name, ...
       'NumberTitle','off'); imshow(uint8(I));
% ------------------------------

fprintf('End of the third example, press any key to exit\n')
pause
