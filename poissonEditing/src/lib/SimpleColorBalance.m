function Iout = SimpleColorBalance(Iin,s1,s2)
% Iout = SimpleColorBalance(Iin,s1,s2,[gmin gmax]); 
% Simple color balance, Matlab Implementation inspired in ref. [1]. 
% We are assuming the Input and output images are in the range [0 255]
% (uint8 images), the dynamic range of the images can be modified adjusting
% the gmin and gmax values in line 40-41. 
% 
% Inputs>
%   - Iin: HxWxC color of gray input image, 
%   - s1: Percentage of "dark" pixels that will be saturated (per channel). 
%   - s2: Percentage of "bright" pixels that will be saturated. 
%       note: typically s1 and s2 are values in the interval [1 5]. Of 
%       course s1+s2 must be lower than 100. If s1 and s2 are equal to zero
%       no pixels are saturated and hence the output image is exaclty the
%       input image. 
% Outputs>
%   - Iout: equalized output image. 
% ----------------------------------------------------------------------- %
% refs:
%   [1] Nicolas Limare, Jose-Luis Lisani, Jean-Michel Morel, Ana Belén 
%       Petro, and Catalina Sbert, Simplest Color Balance, Image Processing 
%       On Line, 1 (2011). http://dx.doi.org/10.5201/ipol.2011.llmps-scb
% ----------------------------------------------------------------------- %
% (c) matias di martino, matiasdm@fing.edu.uy                Paris, 9/2016
% ----------------------------------------------------------------------- %

Iin = double(Iin);
[H,W,C] = size(Iin); % get input image size,
Iout = zeros(H,W,C); % mem. prelocation. 
if C>1, % if the in. im. is a color im., apply the alg. for each channel
    for c = 1:C
     Iout(:,:,c) = SimpleColorBalance(Iin(:,:,c),s1,s2);
    end
    return
end
% else, continue processing a gray image,

% Set the range of the input and output images (by default with set the 
% interval as [0 255] as we are working with uint8 images)
gmin = 0;   % minimun gray level
gmax = 255; % maximum gray level

%% (1) Build cumulative histogram.
% we build a cumulative histogram with 256 cells, 
cumHist = zeros(256,1); % mem. preloc. for the cumulative hist
gvalues = linspace(gmin,gmax,256); % gray values of each histogram cell
for pos = 1:256;
    cumHist(pos) = sum( Iin(:) < gvalues(pos) ); % num. px. with val<gval
end

%% (2) Select Vmin and Vmax values.
idx = find(cumHist <= H*W*s1/100, 1, 'last'); % contain the highest idx of 
% the positions in which the comulative Histogram contains less than 
% s1% pxls.
vmin = gvalues(idx); % gray level that corresponds to this threshold.

idx = find(cumHist <= H*W*(1 - s2/100), 1, 'last'); % contain the highest 
% idx of the positions in which the comulative Histogram contains all the 
% pixels minus the s2% of the highest values.
vmax = gvalues(idx); % gray level that corresponds to this threshold.

%% (3) Rescale Image and saturate pixels above and under Im range.
Iout = (Iin-vmin) * (gmax-gmin)/(vmax-vmin) + gmin;
Iout(Iout>gmax) = gmax;
Iout(Iout<gmin) = gmin;

end
