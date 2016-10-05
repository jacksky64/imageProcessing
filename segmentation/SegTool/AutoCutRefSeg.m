function AutoCutSeg
% AutoSeg  - This function opens a file dialog, loads a image file,
% displays the image in the figure and calls SegmentGC (Main GC Seg Fn)
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global Variables
% Req for marking and keeping track of seeds
global ih_img fgpixels bgpixels;

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
SegmentGC(longfilename, ih_img, 1);


% Refinement 
strg = 'Refine';
axis ij;

%%%%%%%%%%%%%%%%Seed Selection Buttons%%%%%%%%%%%%%%%%%%%
% Calls fginput - gets foreground pixels from the user
data.ui.push_fg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .6 .1 .05], ...
    'String','Foreground','Callback', ['fginput ',strg]);

% Calls bginput - gets background pixels from the user
data.ui.push_bg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .5 .1 .05], ...
    'String','Background','Callback', ['bginput ',strg]);

% Calls SegmentRefine - SmartSelect refinement after AutoCut on the image
data.ui.push_bg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .4 .1 .05], ...
    'String','AutoCutRefine','Callback', ['SegmentRefine ',longfilename]);



