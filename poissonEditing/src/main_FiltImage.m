% ============================================================ %
% Poisson image editing
% ------------------------------------------------------------ %
% FiltImage(Im, Solver, Mode, OutIm, AdditionalParameters)
% inputs:
%   - Im    > input image e.g 'dog.png'
%   - Solver> String containing 'I' or 'II',
%               I: solves the problem by mixing background and object
%               gradients and solving poisson equation over the entire
%               domain (using fourier properties) and imposing neumann
%               border conditions (see [Morel et al. 2012]).
%               II: solver the problem by inserting object gradients inside
%               omega and then integrating inside this region using
%               dirichlet border conditions, (see [Perez et al. 2003]).
%   - Mode  > This string indicates which kind of experiment we want to do:
%              <> 'Flattening'  Set small gradients to zero.
%              <> 'Enhancement' Increase the gradients of the regions of
%                               the dark regions of the image.
%   - OutIm > File name of the output image, e.g. 'out.png'.
%   - Param > Additional parameters (depending on the 'Mode').
%             <> Mode = 'Flattening'  => Param = 'th'. [def 10]
%                                        if |GradI|<th is set to 0.%
%             <> Mode = 'Enhancement' => Param = 'th' 'alpha'. [def 50 2.5]
%                                        if |I|<th, GradI = alpha*GradI.
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
% [Limare et al. 2011] 
%   Nicolas Limare, Jose-Luis Lisani, Jean-Michel Morel, Ana
%   Belén Petro, and Catalina Sbert, Simplest Color Balance, 
%   Image Processing On Line, 1 (2011). 
%   http://dx.doi.org/10.5201/ipol.2011.llmps-scb
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

function main_FiltImage( input_image_filename, ...
                         solver, ...
                         mode, ...
                         out_image_filename, ...
                         varargin)

% ============================================ %
% = Read inputs                              = %
% ============================================ %
addpath lib
global verbose,
verbose = 1; % for debugging

% Read input images,
Iin        = imread(input_image_filename); % read input image

% -------------------------------------------- %
% - Display Exp Parameters and inputs        - %
% -------------------------------------------- %
if verbose>0,
    c = clock;
    fprintf('====================================\n'             )
    fprintf('Experiment parameters: \n'                          )
    fprintf('date: %4.0f-%02.0f-%02.0f (%02.0f:%02.0f) \n', ...
             c(1),c(2),c(3),c(4),c(5)                            )
    fprintf('------------------------------------\n'             )
    fprintf(['background im > ' input_image_filename ' \n']      )
    fprintf( 'verbose       > %2.0d \n', verbose                 )
    fprintf(['Solver        > ' solver      ' \n']               )
    fprintf(['Mode          > ' mode        ' \n']               )
    if nargin>4,
    fprintf(['Addit. par. 1 > ' varargin{1} ' \n']               )
    if nargin>5,
    fprintf(['Addit. par. 2 > ' varargin{2} ' \n']               )
    end
    end
    fprintf('====================================\n'             )
    clear c;
end


% (0) Compute Image gradient map,
switch solver
    case 'I',
        Diff_Method = 'Fourier';
    case 'II',
        Diff_Method = 'Backward';
    otherwise
        error('Type unknown'),
end
G           = ComputeGradient(Iin,Diff_Method);

% ============================================ %
% = (I) Modify the gradient map according    = %
% =     to mode                              = %
% ============================================ %
switch lower(mode),
    % ---------------------------------------------------- %
    case 'flattening', %                                 - %
    % ---------------------------------------------------- %
        if nargin>4,
            th = str2double(varargin{1}); % read input par,
        else % set default value,
            th = 10;
        end
        % find the portion of the image with low gradients,
        Omega = sqrt( G.x .^ 2 + G.y .^ 2 ) < th;

        % Set as 0 the gradients inside Omega,
        G.x(Omega==1) = 0;
        G.y(Omega==1) = 0;

    % ---------------------------------------------------- %
    case 'enhancement', %                                 - %
    % ---------------------------------------------------- %
        if nargin>4,
            th = str2double(varargin{1}); % read input par,
        else % set default value,
            th = 50;
        end
        if nargin>5,
            alpha = str2double(varargin{2}); % read input par,
        else % set default value,
            alpha = 2.5;
        end
        
        % find the portion of the image with low intensity,
        Omega = Iin < th;
        % Amplification factor with smooth transition, 
        % (i) First define a sigmoid func 
        s = @(x) (alpha-1)*(1./(1+exp(-20*x+15)))+1;
        % [ s(0.5) ~ 1, s(1) ~ alpha with a smooth transition, ]
        % (ii) Now have smooth version of Omega to have a measure of the
        % distance of each point to the boundary,
        K = fspecial('Gaussian',[5 5],3); 
        SmOmega = zeros(size(Omega)); % mem preloc.
        for c = 1:size(Omega,3), 
            SmOmega(:,:,c) = conv2(double(Omega(:,:,c)),K,'same');
        end 
        % SmOmega is a image in the range [0,1] where pixels inside Omega
        % far from the boundary will have values arround 1, pixels outside
        % Omega far from the boundary will have values arround 0, and
        % finnaly pixels near the border will have a smooth transition
        % between 0 and 1. 
        
        alphaMap = s(SmOmega);
        % Then the sigmoid mappinf "s" is applied to SmOmega, so values
        % arround SmOmega~0.5 have an amplification factor of 1 (the
        % grandient is preserved near the boundary), and values in the
        % interior of Omega are smoothly amplified with amplification
        % factor alpha. 

        % Amplify the gradients in the dark areas
        G.x(Omega==1) = alphaMap(Omega==1).*G.x(Omega==1);
        G.y(Omega==1) = alphaMap(Omega==1).*G.y(Omega==1);
    otherwise,
        error('Unknown "mode" ')
end

% ============================================ %
% = (II) Solve Poisson Equation              = %
% ============================================ %
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
if verbose>0, mt_printtime(time); end

% ============================================ %
% = (III) Normalize and adjust output        = %
% = dynamic range                            = %
% ============================================ %
switch lower(mode),
    % ---------------------------------------------------- %
    case 'flattening', %                                 - %
    % ---------------------------------------------------- %
    % When we use Fourier solvers (e.i. SoilvePoissonEq_I) we need to
    % arbitrary set the DC component of the integrated gradient map (as no
    % dirichlet boundary conditions are imposed). In order to have and
    % output that can be easily compared with the input image, we set mean
    % and std of the output to match the input
    I = MatchMeanAndStd(I,Iin);
    
    % ---------------------------------------------------- %
    case 'enhancement', %                                - %
    % ---------------------------------------------------- %
    % When performing ehancement, we normalize Poisson result using 
    % simple color balance to use all the dynamic range (as the
    % modification of the gradient field modifies the dynamic range of the
    % image and may produce saturation).
    s_low = 1; s_high = 1; % set the percentage of pix. we may saturate 
    % see ref. [Limare et al. 2011] for a more complete descrition of this
    % normalization procedure. 
    I = normalize(I,[0 255]);
    I = SimpleColorBalance(I,s_low,s_high); % Hist. equalization,
    % --------------------------------------------- %
    % - Computation of additional outputs. (Just  - %
    % - for comparision with poisson results)     - %
    % --------------------------------------------- %
    % (1) Input image with the same Simplest Color Balance.
    Iin_norm = SimpleColorBalance(Iin,s_low,s_high); 
    imwrite(uint8(Iin_norm),'Iin_equalized.png');
    % (2) Input image with a direct mapping of the intensity values, 
    % Define an equivalent mapping, 
    h  = @(U,tau,alpha) ...
          (U<tau) .* ( 255 / ( 255+(alpha-1)*tau ) * alpha .* U ) ...
        + (U>=tau).* ( 255 / ( 255+(alpha-1)*tau ).* (U+(alpha-1)*tau) );
    I_map = h(double(Iin),th,alpha);    
    I_map = SimpleColorBalance(I_map,s_low,s_high); 
    imwrite(uint8(I_map),'Iin_withDirectMapping.png');
end

imwrite(uint8(I),out_image_filename);   % save the output image, 
imwrite(uint8(255*Omega),'trimap.png'); % save the selected domain omega,

end %function main


%
