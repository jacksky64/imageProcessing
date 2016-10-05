function SmartSelect
% SMARTSELECT  - Main interface for Smart Select Tool
% This function creates the user interface (figure window
% and custom menu)
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

clear all;

% Global Variables
global sopt;

% Initialize all required parameters
sopt = mksopt;

% Main Menu 
hfig = figure('units','pixels','position', [50 100 1100 600],...
   'tag','GUI', 'name','Graph-Cuts Segmentation',...
   'menubar','none','numbertitle','off');


% File menu for figure, with callbacks:
% Open...    (callback to displayImage)
% Exit       (closes figure window)

hmenu = uimenu('Label','File');

% DisplayImage function - loads the image file
uimenu(hmenu,'label','Open...','callback','SmartSelectSeg')

% Exit 
uimenu(hmenu,'label','Exit','callback','closereq','separator','on');




