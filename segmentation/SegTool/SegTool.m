function SegTool
% SEGTOOL  - Main interface for Segmentation Tool
% Tools - SmartSelect, AutoCut, AutoRefine
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15


% Main Menu
hfig = figure('units','pixels','position',[100 200 300 400],...
   'tag','SegTool', 'name','Super Segmentation Tool',...
   'menubar','none','numbertitle','off');


% SmartSelect (Lazy Snapping) Tool Button
data.ui.smart = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.25 .8 .5 .1], ...
                    'String','SmartSelect','Callback', 'SmartSelect');

% AutoCut (Grab Cut) Tool Button                
data.ui.smart = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.25 .7 .5 .1], ...
                    'String','AutoCut','Callback', 'AutoCut');
                
                
% AutoCutRefine (GrabCut + Lazy Snapping) Tool Button                                
data.ui.smart = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.25 .6 .5 .1], ...
                    'String','AutoCutRefine','Callback', 'AutoCutRefine');