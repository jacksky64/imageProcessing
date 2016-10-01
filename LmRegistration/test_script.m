% ptsMatching
clc
close all
clear all

addpath('testdata');
addpath('output');
addpath('common');

% initialize parameters
params.distthreshold = 7;
params.simithreshold = 0.02;
params.checkinliner  = 1;
params.leastsquares  = 1;
params.debug = 0;

%% load two images

isource1 = imread('testdata/confocal_10.png');

itarget1 = imread('testdata/macrophage_goldfiducial.png');

if params.debug == 1
figure, imshow(isource1);
figure, imshow(itarget1);
end

%% preprocessing
isource = isource1(:,:,1);
itarget = itarget1(:,:,1);

% crop the edge
%isource(end-70:end, :) = zeros(70+1, size(isource,2));
%itarget(924:1000, 926:1000) = zeros(1000-924+1,1000-926+1);

if params.debug == 1
figure, imshow(isource);
figure, imshow(itarget);
end

%% extract fiducials
%thresholding

% temp = itarget1;
% itarget1 = isource1;
% isource1 = temp;
% 
% temp = itarget;
% itarget = isource;
% isource = temp;
% itarget(end-70:end, :) = zeros(70+1, size(itarget,2));
% 
% sourcepts = extractLM(isource, graythresh(itarget));
% targetpts = extractLM(itarget, 225/256);

% extract landmarks/fiducials
sourcepts = extractLM(isource, 225/256);
targetpts = extractLM(itarget, graythresh(itarget));

% display markers
if params.debug == 1
    figure, imshow(isource1), hold on
    plot(sourcepts(:, 2), sourcepts(:, 1), 'bo', 'LineWidth', 2, 'MarkerSize', 15);
    hold off
    figure, imshow(itarget1), hold on
    plot(targetpts(:, 2), targetpts(:, 1), 'r+', 'LineWidth', 2, 'MarkerSize', 15);
    hold off
end


%% fiducial/landmark based registration

tic
[matchinfo, lsmatchinfo] = lmRegistration(sourcepts, targetpts, params);
toc

affinematrix = lsmatchinfo.affinematrix;
%% display results

% display matching landmarks/fiducials
figure
plot(targetpts(:, 2), targetpts(:, 1), 'r+', 'LineWidth', 2, 'MarkerSize', 10);
hold on
plot(lsmatchinfo.sourceptstrans(:,2), lsmatchinfo.sourceptstrans(:,1), 'bo', 'LineWidth', 2, 'MarkerSize', 10); 
hold off
                        
registered = imgTransform( isource1, size(itarget), affinematrix, 'affine');

% display registered images
figure
imshow(registered)
%imwrite(registered, 'registered.png');
hold on
h = imshow(itarget1);
set(h, 'AlphaData', 0.6)
hold off
