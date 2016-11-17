% This demo script runs our calibration engine on Heikkilä's data (with 3D rig)
% available at: http://www.ee.oulu.fi/~jth/calibr/
% This code loads the data from the format available on his web site, converts
% in my data format, runs the main calibration engine, displays the results and saves
% the results into a file called Calib_Results.mat

% (c) Jean-Yves Bouguet - Dec 25th, 1999


% Preparing the data:

clear;

load cademo,

n_ima = 1;

x_1 = data3d(:,4:5)';
X_1 = data3d(:,1:3)';


% Image size: (may or may not be available)

nx = 768;
ny = 576;

% No calibration image is available (only the corner coordinates)

no_image = 1;

% Set the toolbox not to prompt the user (choose default values)

dont_ask = 1;

% Run the main calibration routine:

go_calib_optim;

% Shows the extrinsic parameters:

ext_calib;

% Reprojection on the original images:

reproject_calib;

% Set the toolbox to normal mode of operation again:

dont_ask =  0;
