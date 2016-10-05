function AutoSeg
% AutoSeg  - This function opens a file dialog, loads a image file,
% displays the image in the figure and calls SegmentGC (Main GC Seg Fn)
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15


% Get handle to current figure;
hfig = gcf;

% Call built-in file dialog to select image file
[filename,pathname]=uigetfile('images/*.*','Select image file');
if ~ischar(filename); return; end

% Load  Image file
longfilename = strcat(pathname,filename);
Im = imread(longfilename);

% Get the position of the image
data.ui.ah_img = axes('Position',[0.01 0.2 .603 .604]);
ih_img = image;

% Main GrabCut Segmentation Function
SegmentGC(longfilename, ih_img, 0);