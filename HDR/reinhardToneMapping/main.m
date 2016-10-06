% -------------------------------------------------------------------------
% Implements a complete hdr and tonemapping cycle
%
% Author:
% Mathias Eitz
% m.eitz@tu-berlin.de
%
% 1.: Computes the camera response curve according to "Recovering High
% Dynamic Range Radiance Maps from Photographs" by P. Debevec.
% You need a wide range of differently exposed pictures from the same scene
% to get good results.
%
% 2.: Recovers a hdr radiance map from the range of ldr pictures 
%
% 3.: Tonemaps the resulting hdr radiance map according to "Photographic
% Tone Reproduction for Digital Images" by Reinhard et al.
% Both the simple global and the more complex local tonemapping operator
% are applied to the hdr radiance map.
%
% Some code taken from Paul Debevec's implementation of his SIGGRAPH'97
% paper "Recovering High Dynamic Range Radiance Maps from Photographs"
%
% Original implementation: January 2007
% Compatibility updates for new Matlab versions (7.8.0): April 2010
% -------------------------------------------------------------------------


% Specify the directory that contains your range of differently exposed
% pictures. Needs to have a '/' at the end. 
% The images need to have exposure information encoded in the filename,
% i.e. the filename 'window_exp_1_60.jpg' would indicate that this image
% has been exposed for 1/60 second. See readDir.m for details.
dirName = ('../pics_window/');
[filenames, exposures, numExposures] = readDir(dirName);


fprintf('Opening test image\n');
tmp = imread(filenames{1});

numPixels = size(tmp,1) * size(tmp,2);
numExposures = size(filenames,2);


% define lamda smoothing factor
l = 50;


fprintf('Computing weighting function\n');
% precompute the weighting function value
% for each pixel
weights = [];
for i=1:256
    weights(i) = weight(i,1,256);
end

% load and sample the images
[zRed, zGreen, zBlue, sampleIndices] = makeImageMatrix(filenames, numPixels);


B = zeros(size(zRed,1)*size(zRed,2), numExposures);

fprintf('Creating exposures matrix B\n')
for i = 1:numExposures
    B(:,i) = log(exposures(i));
end

% solve the system for each color channel
fprintf('Solving for red channel\n')
[gRed,lERed]=gsolve(zRed, B, l, weights);
fprintf('Solving for green channel\n')
[gGreen,lEGreen]=gsolve(zGreen, B, l, weights);
fprintf('Solving for blue channel\n')
[gBlue,lEBlue]=gsolve(zBlue, B, l, weights);
save('gMatrix.mat','gRed', 'gGreen', 'gBlue');


% compute the hdr radiance map
fprintf('Computing hdr image\n')
hdrMap = hdr(filenames, gRed, gGreen, gBlue, weights, B);


% compute the hdr luminance map from the hdr radiance map. It is needed as
% an input for the Reinhard tonemapping operators.
fprintf('Computing luminance map\n');
luminance = 0.2125 * hdrMap(:,:,1) + 0.7154 * hdrMap(:,:,2) + 0.0721 * hdrMap(:,:,3);

% apply Reinhard local tonemapping operator to the hdr radiance map
fprintf('Tonemapping - Reinhard local operator\n');
saturation = 0.6;
eps = 0.05;
phi = 8;
[ldrLocal, luminanceLocal, v, v1Final, sm ]  = reinhardLocal(hdrMap, saturation, eps, phi);

% apply Reinhard global tonemapping oparator to the hdr radiance map
fprintf('Tonemapping - Reinhard global operator\n');
% specify resulting brightness of the tonampped image. See reinhardGlobal.m
% for details
a = 0.72;
% specify saturation of the resulting tonemapped image. See reinhardGlobal.m
% for details
saturation = 0.6;
[ldrGlobal, luminanceGlobal ] = reinhardGlobal( hdrMap, a, saturation );

figure
subplot(1,2,1);
imshow(ldrGlobal);
title('Reinhard global operator');
subplot(1,2,2);
imshow(ldrLocal);
title('Reinhard local operator');

fprintf('Finished!\n');