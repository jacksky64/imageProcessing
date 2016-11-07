%% Demo 4: Simple Image reconstruction
%
%
% This demo will show how a simple image reconstruction can be performed,
% by using OS-SART and FDK
%
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% This file is part of the TIGRE Toolbox
% 
% Copyright (c) 2015, University of Bath and 
%                     CERN-European Organization for Nuclear Research
%                     All rights reserved.
%
% License:            Open Source under BSD. 
%                     See the full license at
%                     https://github.com/CERN/TIGRE/license.txt
%
% Contact:            tigre.toolbox@gmail.com
% Codes:              https://github.com/CERN/TIGRE/
% Coded by:           Ander Biguri 
%--------------------------------------------------------------------------
%% Initialize

clear;
close all;
%% Define Geometry
% 
% VARIABLE                                   DESCRIPTION                    UNITS
%-------------------------------------------------------------------------------------
geo.DSD = 633.202849;                       % Distance Source Detector      (mm)
geo.DSO = 380.775307;                       % Distance Source Origin        (mm)
% Detector parameters
geo.nDetector=[616; 608];					% number of pixels              (px)
geo.dDetector=[0.2; 0.2]; 					% size of each pixel            (mm)
geo.sDetector=geo.nDetector.*geo.dDetector; % total size of the detector    (mm)
% Image parameters
geo.nVoxel=[256;256;256];                   % number of voxels              (vx)
geo.sVoxel=[60;60;60];                      % total size of the image       (mm)
geo.dVoxel=geo.sVoxel./geo.nVoxel;          % size of each voxel            (mm)
% Offsets
geo.offOrigin =[0;0;0];                     % Offset of image from origin   (mm)              
%geo.offDetector=[-63.61;-121.6+83.84];                     % Offset of Detector            (mm)
geo.offDetector=[-63.61+61.6;-121.6+83.84+60.8];                     % Offset of Detector            (mm)


% Auxiliary 
geo.accuracy=0.5;                           % Accuracy of FWD proj          (vx/sample)

%% Load projections 
folder = 'E:\SolidDetectorImages\Dentale\2016-10-14 Immagini Dentali CBCT PAN CEPH\CBCT\SedentexCT_FULL_Low';
fileType = '*.tif';
projections=single(loadProjections(folder,fileType));
numProjections = size(projections,3);

% define angles
startAngle = 0*2*pi/360;
angularRange = (360-360/numProjections)*2*pi/360;

angles=linspace(startAngle,startAngle+angularRange,numProjections);

downsample = 1;
projections=projections(:,:,1:downsample:end);
angles=angles(1:downsample:end);

%% Reconstruct image using OS-SART and FDK

% FDK
imgFDK=FDK(projections,geo,angles);
plotImg([imgFDK],'Dim','Z');

outputFileName = 'd:\\temp\\out\\img_stack%03d.dcm';
for K=1:length(imgFDK(1, 1, :))
   dicomwrite(int16(imgFDK(:, :, K)), sprintf(outputFileName,K));
end

% OS-SART

niter=50;
%imgOSSART=OS_SART(projections,geo,angles,niter);

% Show the results
%plotImg([imgFDK,imgOSSART],'Dim','Z');
