% Computes a hdr radiance map and two tonemapped images.
%
% Computes a hdr radiance map given a pre-determined camera response curve
% that is being loaded from a file.
% Finally the hdr radiance map gets tonemapped to be able to display it on
% a computer screen.


%dirName = ('../pics/window/small/');
%dirName = ('../pics/hackeschehoefe/small/');
dirName = ('../pics/sbahn/small/');
%dirName = ('../pics/street/small/');
[filenames, exposures, numExposures] = readDir(dirName);

% load a pre-computed camera response curve.
% Generally you only need to compute your camera response curve once
% and than can  apply it to all images taken with the same camera
g = load('responseCurve.mat');
gRed = g.gRed;
gGreen = g.gGreen;
gBlue = g.gBlue;


%compute hat weighting function
weights = [0:1:127, 127:-1:0];

B = log(exposures);

fprintf('Computing hdr image\n')
hdr = hdr(filenames, gRed, gGreen, gBlue, weights, B);


fprintf('Tonemapping - local operator\n');
saturation = 0.6;
eps = 0.1;
phi = 8;
[ldrLocal, luminanceLocal, v, v1Final, sm ]  = reinhardLocal(hdr, saturation, eps, phi);

fprintf('Tonemapping - global operator\n');
key = 0.18;
saturation = 0.6;
[ldrGlobal, luminanceGlobal ] = reinhardGlobal( hdr, key, saturation);


imwrite(ldrLocal, 'sbahnLocal.bmp', 'bmp');
imwrite(ldrGlobal, 'sbahnGlobal.bmp', 'bmp');
