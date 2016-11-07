function argout = imagine2(varargin)
% IMAGINE IMAGe visualization, analysis and evaluation engINE
%
%   IMAGINE starts the IMAGINE user interface without initial data
%
%   IMAGINE(DATA) Starts the IMAGINE user interface with one (DATA is 3D)
%   or multiple panels (DATA is 4D).
%
%   IMAGINE(DATA, PROPERTY1, VALUE1, ...)) Starts the IMAGINE user
%   interface with data DATA plus supplying some additional information
%   about the dataset in the usual property/value pair format. Possible
%   combinations are:
%       PROPERTY        VALUE
%       'Name'          String: A name for the dataset
%       'Voxelsize'     [3x1] or [1x3] double: The voxel size of the first
%                       three dimensions of DATA.
%       'Units'         String: The physical unit of the pixels (e.g. 'mm')
%
%   IMAGINE(DATA1, DATA2, ...) Starts the IMAGINE user interface with
%   multiple panels, where each input can be either a 3D- or 4D-array. Each
%   dataset can be defined more detailedly with the properties above. 
%
%
% Examples:
%
% 1. >> load mri % Gives variable D
%    >> imagine(squeeze(D)); % squeeze because D is in rgb format
%
% 2. >> load mri % Gives variable D
%    >> imagine(squeeze(D), 'Name', 'Head T1', 'Voxelsize', [1 1 2.7]);
% This syntax gives a more realistic aspect ration if you rotate the data.
%
% For more information about the IMAGINE functions refer to the user's
% guide file in the documentation folder supplied with the code.
%
% Copyright 2012-2015 Christian Wuerslin, Stanford University
% Contact: wuerslin@stanford.edu

% =========================================================================
% Warp Zone! (using Cntl + D)
% -------------------------------------------------------------------------
% *** The callbacks ***
% fCloseGUI                 % On figure close
% fResizeFigure             % On figure resize
% fIconClick                % On clicking menubar or tool icons
% fWindowMouseHoverFcn      % Standard figure mouse move callback
% fWindowButtonDownFcn      % Figure mouse button down function
% fWindowMouseMoveFcn       % Figure mouse move function when button is pressed or ROI drawing active
% fWindowButtonUpFcn        % Figure mouse button up function: Starts most actions
% fKeyPressFcn              % Keyboard callback
% fContextFcn               % Context menu callback
% fSetWindow                % Callback of the colorbars
% 
% -------------------------------------------------------------------------
% *** IMAGINE Core ***
% fFillPanels
% fUpdateActivation
% fZoom
% fWindow
% fChangeImage
% fEval
%
% -------------------------------------------------------------------------
% *** Lengthy subfunction ***
% fLoadFiles
% fParseInputs
% fAddImageToData
% fSaveToFiles
%
% -------------------------------------------------------------------------
% *** Helpers ***
% fCreatePanels
% fGetPanel
% fServesSizeCriterion
% fIsOn
% fGetNActiveVisibleSeries
% fGetNVisibleSeries
% fGetImg
% fGetData
% fPrintNumber
% fBackgroundImg
% fReplicate
%
% -------------------------------------------------------------------------
% *** GUIS ***
% fGridSelect
% fColormapSelect
% fSelectEvalFcns
% =========================================================================

% =========================================================================
% *** FUNCTION imagine
% ***
% *** Main GUI function. Creates the figure and all its contents and
% *** registers the callbacks.
% ***
% =========================================================================

% -------------------------------------------------------------------------
% Control the figure's appearance
SAp.sVERSION          = '2.2 - Belly Jeans';
SAp.sTITLE            = ['IMAGINE ',SAp.sVERSION];% Title of the figure
SAp.iICONSIZE         = 24;                     % Size if the icons
SAp.iICONPADDING      = SAp.iICONSIZE/2;        % Padding between icons
SAp.iMENUBARHEIGHT    = SAp.iICONSIZE*2;        % Height of the menubar (top)
SAp.iTOOLBARWIDTH     = SAp.iICONSIZE*2;        % Width of the toolbar (left)
SAp.iTITLEBARHEIGHT   = 24;                     % Height of the titles (above each image)
SAp.iCOLORBARHEIGHT   = 12;                     % Height of the colorbar
SAp.iCOLORBARPADDING  = 60;                     % The space on the left and right of the colorbar for the min/max values
SAp.iEVALBARHEIGHT    = 16;                     % Height of the evaluation bar
SAp.iDISABLED_SCALE   = 0.3;                    % Brightness of disabled buttons (decrease to make darker)
SAp.iINACTIVE_SCALE   = 0.6;                    % Brightness of inactive buttons (toggle buttons and radio groups)
SAp.dBGCOLOR          = [0.2 0.3 0.4];          % Color scheme
SAp.dEmptyImg         = 0;                      % The background image (is calculated in fResizeFigure);
SAp.iCOLORMAPLENGTH   = 2.^12;
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Set some paths.
SPref.sMFILEPATH    = fileparts(mfilename('fullpath'));                 % This is the path of this m-file
SPref.sICONPATH     = [SPref.sMFILEPATH, filesep, 'icons', filesep];    % That's where the icons are
SPref.sSaveFilename = [SPref.sMFILEPATH, filesep, 'imagineSave.mat'];   % A .mat-file to save the GUI settings
addpath([SPref.sMFILEPATH, filesep, 'EvalFunctions'], ...
        [SPref.sMFILEPATH, filesep, 'colormaps'], ...
        [SPref.sMFILEPATH, filesep, 'import'], ...
        [SPref.sMFILEPATH, filesep, 'tools']);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Define some preferences
S = load('mylines.mat');
SPref.dCOLORMAP             = S.mylines;% The color scheme of the overlays and lines
SPref.dWINDOWSENSITIVITY    = 0.02;     % Defines mouse sensitivity for windowing operation
SPref.dZOOMSENSITIVITY      = 0.02;     % Defines mouse sensitivity for zooming operation
SPref.dROTATION_THRESHOLD   = 50;       % Defines the number of pixels the cursor has to move to rotate an image
SPref.dLWRADIUS             = 200;      % The radius in which the path maps are calculated in the livewire algorithm
SPref.lGERMANEXPORT         = false;    % Not a beer! Determines whether the data is exported with a period or a comma as decimal point
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% This is the definition of the menubar. If a radiobutton-like
% functionality is to implemented, the GroupIndex parameter of all
% icons within the group has to be set to the same positive integer
% value. Normal Buttons have group index -1, toggel switches have group
% index 0. The toolbar has the GroupIndex 255.
SIcons = struct( ...
    'Name',        {'folder_open',                 'doc_import',          'save', 'doc_delete', 'exchange',          'grid', 'colormap',         'link',          'link1',     'reset',       'phase',                          'max',                          'min',         'record',                    'stop',               'rewind',           'clock',           'line1',     'cursor_arrow', 'rotate',               'line',            'roi',                      'lw',                               'rg',                    'ic',        'tag'}, ...
    'Spacer',      {            0,                            0,               0,            0,          1,               0,          0,              0,                0,           1,             0,                              0,                              1,                0,                         0,                      0,                 0,                 0,                  0,        0,                    0,                0,                         0,                                  0,                       0,            0}, ...
    'GroupIndex',  {           -1,                           -1,              -1,           -1,         -1,              -1,         -1,              0,                0,          -1,             1,                              1,                              1,               -1,                        -1,                     -1,                 0,                 0,                255,      255,                  255,              255,                       255,                                255,                     255,          255}, ...
    'Enabled',     {            1,                            1,               0,            0,          0,               1,          1,              1,                1,           1,             1,                              1,                              1,                1,                         0,                      1,                 1,                 1,                  1,        1,                    1,                1,                         1,                                  1,                       1,            1}, ...
    'Active',      {            1,                            1,               1,            1,          1,               1,          1,              1,                0,           1,             0,                              0,                              0,                1,                         1,                      1,                 0,                 1,                  1,        0,                    0,                0,                         0,                                  0,                       0,            0}, ...
    'Accelerator', {          'o',                          'i',             's',     'delete',        'x',              '',         '',            'l',               '',         '0',            '',                             '',                             '',              'r',                       'r',                    'z',               't',               'w',                'm',      'r',                  'l',              'o',                       'w',                                'g',                     'i',          'p'}, ...
    'Modifier',    {       'Cntl',                       'Cntl',          'Cntl',           '',     'Cntl',              '',         '',         'Cntl',               '',      'Cntl',            '',                             '',                             '',           'Cntl',                     'Alt',                 'Cntl',            'Cntl',            'Cntl',                 '',       '',                   '',               '',                        '',                                 '',                      '',           ''}, ...
    'Tooltip',     {'Open Files' , 'Import Workspace Variables', 'Save To Files',     'Delete', 'Exchange', 'Change Layout', 'Colormap', 'Link Actions', 'Link Windowing','Reset View', 'Phase Image', 'Maximum Intensity Projection', 'Minimum Intensity Projection', 'Log Evaluation', 'Stop Logging Evaluation', 'Undo Last Evaluation', 'Eval Timeseries', 'Show Line Plots', 'Move/Zoom/Window', 'Rotate', 'Profile Evaluation', 'ROI Evaluation', 'Livewire ROI Evaluation', 'Region Growing Volume Evaluation', 'Isocontour Evaluation', 'Properties'});
% -------------------------------------------------------------------------

% ------------------------------------------------------------------------
% Reset the GUI's state variable
SState.iLastSeries     = 0;
SState.iStartSeries    = 1;
SState.sTool           = 'cursor_arrow';
SState.sPath           = [SPref.sMFILEPATH, filesep];
SState.csEvalLineFcns  = {};
SState.csEvalROIFcns   = {};
SState.csEvalVolFcns   = {};
SState.sEvalFilename   = [];
SState.iROIState       = 0;     % The ROI state machine
SState.dROILineX       = [];
SState.dROILineY       = [];
SState.iPanels         = [0, 0];
SState.lShowColorbar   = true;
SState.lShowEvalbar    = true;
SState.dColormapBack   = gray(SAp.iCOLORMAPLENGTH);
SState.dColormapMask   = S.mylines;
SState.dMaskOpacity    = 0.3;
SState.sDrawMode       = 'mag';
SState.dTolerance      = 1.0;
SState.hEvalFigure     = 0.1;
% ------------------------------------------------------------------------

% ------------------------------------------------------------------------
% Create some globals
SData                  = [];    % A struct for hoding the data (image data + visualization parameters)
SImg                   = [];    % A struct for the image component handles
SLines                 = [];    % A struct for the line component handles
SMouse                 = [];    % A Struct to hold parameters of the mouse operations
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Read the preferences from the save file
iPosition = [100 100 1000 600];
if exist(SPref.sSaveFilename, 'file')
    load(SPref.sSaveFilename);
    SState.sPath            = SSaveVar.sPath;
    SState.csEvalLineFcns   = SSaveVar.csEvalLineFcns;
    SState.csEvalROIFcns    = SSaveVar.csEvalROIFcns;
    SState.csEvalVolFcns    = SSaveVar.csEvalVolFcns;
    iPosition               = SSaveVar.iPosition;
    SPref.lGERMANEXPORT     = SSaveVar.lGermanExport;
    clear SSaveVar; % <- no one needs you anymore! :((
else
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % First-time call: Do some setup
    sAns = questdlg('Do you want to use periods (anglo-american) or commas (german) as decimal separator in the exported .csv spreadsheet files? This is important for a smooth Excel import.', 'IMAGINE First-Time Setup', 'Stick to the point', 'Use se commas', 'Stick to the point');
    SPref.lGERMANEXPORT = strcmp(sAns, 'Use se commas');
    fCompileMex;
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Make sure the figure fits on the screen
iScreenSize = get(0, 'ScreenSize');
if (iPosition(1) + iPosition(3) > iScreenSize(3)) || ...
   (iPosition(2) + iPosition(4) > iScreenSize(4))
    iPosition(1:2) = 50;
    iPosition(3:4) = iScreenSize(3:4) - 100;
end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create the figure. Mouse scroll wheel is supported since Version 7.4 (I think).
hF = figure(...
    'BusyAction'            , 'cancel', ...
    'Interruptible'         , 'off', ...
    'Position'              , iPosition, ...
    'Units'                 , 'pixels', ...
    'Color'                 , SAp.dBGCOLOR/2, ...
    'ResizeFcn'             , @fResizeFigure, ...
    'DockControls'          , 'on', ...
    'MenuBar'               , 'none', ...
    'Name'                  , SAp.sTITLE, ...
    'NumberTitle'           , 'off', ...
    'KeyPressFcn'           , @fKeyPressFcn, ...
    'CloseRequestFcn'       , @fCloseGUI, ...
    'WindowButtonDownFcn'   , @fWindowButtonDownFcn, ...
    'WindowButtonMotionFcn' , @fWindowMouseHoverFcn, ...
	'Visible'               , 'off');
try
    set(hF, 'WindowScrollWheelFcn' , @fChangeImage);
catch
    warning('IMAGINE: No scroll wheel functionality!');
end
colormap(gray(256));
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Crate context menu for the region growing
hContextMenu = uicontextmenu;
uimenu(hContextMenu, 'Label', 'Tolerance +50%', 'Callback', @fContextFcn);
uimenu(hContextMenu, 'Label', 'Tolerance +10%', 'Callback', @fContextFcn);
uimenu(hContextMenu, 'Label', 'Tolerance -10%', 'Callback', @fContextFcn);
uimenu(hContextMenu, 'Label', 'Tolerance -50%', 'Callback', @fContextFcn);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create the menubar and the toolbar including their components
SAxes.hMenu  = axes('Parent', hF, 'Color', 'k', 'Units', 'pixels', 'YDir', 'reverse', 'XTick', [], 'YTick', []);
SAxes.hTools = axes('Parent', hF, 'Color', 'k', 'Units', 'pixels', 'YDir', 'reverse', 'XTick', [], 'YTick', []);
SImg .hIcons = zeros(length(SIcons), 1);

iXStart = SAp.iTOOLBARWIDTH - SAp.iICONSIZE;
iYStart = SAp.iICONPADDING;
for iI = 1:length(SIcons)
    if SIcons(iI).GroupIndex ~= 255, iXStart = iXStart + SAp.iICONPADDING + SAp.iICONSIZE; end
    
    dImage = double(imread([SPref.sICONPATH, SIcons(iI).Name, '.png'])); % icon file name (.png) has to be equal to icon name
    if size(dImage, 3) == 1, dImage = repmat(dImage, [1 1 3]); end
    dImage = imresize(dImage, [SAp.iICONSIZE SAp.iICONSIZE]);
    dImage(dImage < 0) = 0;
    dImage(dImage > 255) = 255;
    SIcons(iI).dImg = dImage./255;
    
    if SIcons(iI).GroupIndex == 255
        hParent = SAxes.hTools;
        iX = SAp.iICONPADDING;
        iY = iYStart;
    else
        hParent = SAxes.hMenu;
        iX = iXStart;
        iY = SAp.iICONPADDING;
    end
    
    SImg.hIcons(iI) = image(...
        'CData'         , SIcons(iI).dImg, ...
        'XData'         , iX, ...
        'YData'         , iY, ...
        'Parent'        , hParent, ...
        'ButtonDownFcn' , @fIconClick);
    
    if SIcons(iI).Spacer && SIcons(iI).GroupIndex ~= 255, iXStart = iXStart + SAp.iICONSIZE; end
    if SIcons(iI).GroupIndex == 255, iYStart = iYStart + SAp.iICONSIZE + SAp.iICONPADDING; end
end
SState.dIconEnd = iXStart + SAp.iICONPADDING + SAp.iICONSIZE;

STexts.hStatus = uicontrol(... % Create the text element
    'Style'                 ,'Text', ...
    'FontName'              , 'Helvetica Neue', ...
    'FontWeight'            , 'light', ...
    'Parent'                , hF, ...
    'FontUnits'             , 'normalized', ...
    'FontSize'              , 0.7, ...
    'BackgroundColor'       , 'k', ...
    'ForegroundColor'       , 'w', ...
    'HorizontalAlignment'   , 'right', ...
    'Units'                 , 'pixels');

clear iStartPos hParent iI dImage
% -------------------------------------------------------------------------

dLogo = [0 0 0 1 1 0 0 0; ...
         0 0 0 1 1 0 0 0; ...
         0 0 0 0 0 0 0 0; ...
         0 0 1 1 1 0 0 0; ...
         0 0 0 1 1 0 0 0; ...
         0 0 0 1 1 0 0 0; ...
         0 0 1 1 1 1 0 0; ...
         0 0 0 0 0 0 0 0;];
% dPattern = max(cat(3, rand(12), padarray(dLogo, [2 2], 0, 'both')), [], 3);
dPattern = 0.2*rand(16) + 0.3*padarray(dLogo, [4 4], 0, 'both');
dPattern = dPattern.*repmat(linspace(1, 0, 16)', [1, 16]);
SAp.dBGImg = fBlend(SAp.dBGCOLOR, dPattern, 'multiply', 0.5);

% -------------------------------------------------------------------------
% Parse Inputs and determine and create the initial amount of panels
if ~isempty(varargin), fParseInputs(varargin); end
if ~prod(SState.iPanels), SState.iPanels = [1 1]; end
fCreatePanels;
clear varargin; % <- no one needs you anymore! :((
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Update the figure components
fUpdateActivation(); % Acitvate/deactivate some buttons according to the gui state
set(hF, 'Visible', 'on', 'UserData', @fGetData);
fDraw; % Resize only calls fPosition
argout = hF;
% -------------------------------------------------------------------------
% The 'end' of the IMAGINE main function. The real end is, of course, after
% all the nested functions. Using the nested functions, shared varaiables
% (the variables of the IMAGINE function) can be used which makes the usage
% of the 'guidata' commands obsolete.
% =========================================================================



    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fCloseGUI (nested in imagine)
    % * * 
    % * * Figure callback
    % * *
    % * * Closes the figure and saves the settings
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fCloseGUI(hObject, eventdata) %#ok<*INUSD> eventdata is repeatedly unused
        % -----------------------------------------------------------------
        % Save the settings
        SSaveVar.sPath          = SState.sPath;
        SSaveVar.csEvalLineFcns = SState.csEvalLineFcns;
        SSaveVar.csEvalROIFcns  = SState.csEvalROIFcns;
        SSaveVar.csEvalVolFcns  = SState.csEvalVolFcns;
        SSaveVar.iPosition      = get(hObject, 'Position');
        SSaveVar.lGermanExport  = SPref.lGERMANEXPORT;
        try
            save(SPref.sSaveFilename, 'SSaveVar');
        catch
            warning('Could not save the settings! Is the IMAGINE folder protected?');
        end
        % -----------------------------------------------------------------
        
        delete(hObject); % Bye-bye figure
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fCloseGUI
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fCreatePanels (nested in imagine)
    % * *
    % * * Create the panels and its child object.
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fCreatePanels
        % -----------------------------------------------------------------
        % Delete panels and their handles if necessary
        if isfield(SAxes, 'hImg')
            delete(SAxes.hImg); % Deletes hImgFrame and its children
            delete(SAxes.hColorbar);
            STexts  = rmfield(STexts,  {'hImg1', 'hImg2', 'hColorbarMin', 'hColorbarMax','hEval', 'hVal'});
            SAxes   = rmfield(SAxes,   {'hImg', 'hColorbar'});
            SImg    = rmfield(SImg,    {'hImg', 'hColorbar'});
        end
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % For each panel create panels, axis, image and text objects
        for i = 1:prod(SState.iPanels)
            SAxes.hImg(i) = axes(...
                'Parent'                , hF, ...
                'Units'                 , 'pixels', ...
                'Color'                 , 'k', ...
                'XTick'                 , [], ...
                'YTick'                 , [], ...
                'YDir'                  , 'reverse', ...
                'XColor'                , SAp.dBGCOLOR, ...
                'YColor'                , SAp.dBGCOLOR, ...
                'Box'                   , 'on');
            SImg.hImg(i) = image(...
                'CData'                 , 0, ...
                'Parent'                , SAxes.hImg(i), ...
                'HitTest'               , 'off');
            STexts.hImg1(i)         = text('Units', 'pixels', 'FontSize', 14, 'Color', 'w', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'Interpreter', 'none');
            STexts.hImg2(i)         = text('Units', 'pixels', 'FontSize', 14, 'Color', 'w', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
            STexts.hColorbarMin(i)  = text('Units', 'pixels', 'FontSize', 12, 'Color', 'w', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');
            STexts.hColorbarMax(i)  = text('Units', 'pixels', 'FontSize', 12, 'Color', 'w', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
            STexts.hEval(i)         = text('Units', 'pixels', 'FontSize', 12, 'Color', 'w', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
            STexts.hVal(i)          = text('Units', 'pixels', 'FontSize', 12, 'Color', 'w', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
            
            SAxes.hColorbar(i) = axes(...
                'Parent'                , hF, ...
                'XTick'                 , [], ...
                'YTick'                 , [], ...
                'Units'                 , 'pixels', ...
                'XLim'                  , [0 256] + 0.5, ...
                'YLim'                  , [0.5 1.5], ...
                'Visible'               , 'off');
            SImg.hColorbar(i) = image(...
                'CData'                 , uint8(0:255), ...
                'Parent'                , SAxes.hColorbar(i), ...
                'ButtonDownFcn'         , @fSetWindow);
            
            
            iDataInd = i + SState.iStartSeries - 1;
            if (iDataInd > 0) && (iDataInd <= length(SData))
                set(STexts.hColorbarMin(i), 'String', sprintf('%s', fPrintNumber(SData(iDataInd).dWindowCenter - SData(iDataInd).dWindowWidth./2)));
                set(STexts.hColorbarMax(i), 'String', sprintf('%s', fPrintNumber(SData(iDataInd).dWindowCenter + SData(iDataInd).dWindowWidth./2)));
            end
            
        end % of loop over pannels
        % -----------------------------------------------------------------

        if strcmp(SState.sTool, 'rg'), set(SAxes.hImg, 'uicontextmenu', hContextMenu); end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fCreatePanels
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fResizeFigure (nested in imagine)
    % * * 
    % * * Figure callback
    % * *
    % * * Re-arranges all the GUI elements after a figure resize
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fResizeFigure(hObject, eventdata)
        
        % -----------------------------------------------------------------
        % Get figure dimensions
        iFigureSize   = get(hF, 'Position');
        
        iViewWidth  = round((iFigureSize(3)  - SAp.iTOOLBARWIDTH ) / SState.iPanels(2));
        iViewHeight = round((iFigureSize(4) - SAp.iMENUBARHEIGHT) / SState.iPanels(1));
                
        % -----------------------------------------------------------------
        % Arrange the panels and all their contents
        iYStart = 2;
        for iY = SState.iPanels(1):-1:1 % Start from the bottom
            
            if iY > 1
                iHeight = iViewHeight;
            else
                iHeight = iFigureSize(4) - iYStart - SAp.iMENUBARHEIGHT;
            end
            
            iXStart = SAp.iTOOLBARWIDTH + 2;
            
            for iX = 1:SState.iPanels(2)
                
                iLinInd = (iY - 1).*SState.iPanels(2) + iX;                
                
                if iX == SState.iPanels(2)
                    iWidth = iFigureSize(3) - iXStart;
                else
                    iWidth = iViewWidth;
                end
                
                set(STexts.hEval(iLinInd), 'Position', [5,          5]);
                set(STexts.hVal(iLinInd),  'Position', [iWidth - 5, 5]);
                
                set(SAxes.hImg(iLinInd), 'Position',   [iXStart, iYStart, iWidth, iHeight]);

                set(STexts.hImg1(iLinInd), 'Position', [5,              iHeight - 5]);
                set(STexts.hImg2(iLinInd), 'Position', [iWidth - 5, iHeight - 5]);
                
                set(SAxes.hColorbar(iLinInd), 'Position',     [iXStart + SAp.iCOLORBARPADDING,    iYStart + iHeight - SAp.iCOLORBARHEIGHT - SAp.iTITLEBARHEIGHT + 4, max([iWidth - 2*SAp.iCOLORBARPADDING, 1]), SAp.iCOLORBARHEIGHT - 3]);
                set(STexts.hColorbarMin(iLinInd), 'Position', [SAp.iCOLORBARPADDING - 5,          iHeight - SAp.iTITLEBARHEIGHT - SAp.iCOLORBARHEIGHT + 6]);
                set(STexts.hColorbarMax(iLinInd), 'Position', [iWidth - SAp.iCOLORBARPADDING + 5, iHeight - SAp.iTITLEBARHEIGHT - SAp.iCOLORBARHEIGHT + 6]);
                
                iXStart = iXStart + iWidth;
            end
            iYStart = iYStart + iHeight;
        end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Arrange the menubar
        dTextWidth = max([iFigureSize(3) - SState.dIconEnd - 48, 1]);
        set(SAxes.hMenu, 'Position', [1, iFigureSize(4) - SAp.iMENUBARHEIGHT + 1, iFigureSize(3), SAp.iMENUBARHEIGHT], ...
            'XLim', [0 iFigureSize(3)] + 0.5, 'YLim', [0 SAp.iMENUBARHEIGHT] + 0.5);
        set(STexts.hStatus, 'Position', [SState.dIconEnd + 5, iFigureSize(4) - SAp.iMENUBARHEIGHT + 1 + 10, dTextWidth, 28]);
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Arrange the toolbar
        set(SAxes.hTools, 'Position', [1, 1, SAp.iTOOLBARWIDTH, iFigureSize(4) - SAp.iMENUBARHEIGHT], ...
            'XLim', [0 SAp.iTOOLBARWIDTH] + 0.5, 'YLim', [0 iFigureSize(4) - SAp.iMENUBARHEIGHT] + 0.5);
        % -----------------------------------------------------------------

        fPosition;
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fResizeFigure
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fFillPanels (nested in imagine)
    % * *
    % * * Display the current data in all panels.
    % * * The holy grail of Imagine!
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fFillPanels
        fDraw;
        fPosition;
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fFillPanels
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    function fDraw
        for i = 1:length(SAxes.hImg)
            iSeriesInd = SState.iStartSeries + i - 1;
            if iSeriesInd <= length(SData) % Panel not empty
                
                if strcmp(SState.sDrawMode, 'phase')
                    dMin = -pi; dMax = pi;
                else
                    dMin = SData(SState.iStartSeries).dWindowCenter - 0.5.*SData(SState.iStartSeries).dWindowWidth;
                    dMax = SData(SState.iStartSeries).dWindowCenter + 0.5.*SData(SState.iStartSeries).dWindowWidth;
                end
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Get the image data, do windowing and apply colormap
                if ~fIsOn('link1') && ~strcmp(SState.sDrawMode, 'phase')
                    dMin = SData(iSeriesInd).dWindowCenter - 0.5.*SData(iSeriesInd).dWindowWidth;
                    dMax = SData(iSeriesInd).dWindowCenter + 0.5.*SData(iSeriesInd).dWindowWidth;
                end
                dImg = fGetImg(iSeriesInd);
                dImg = dImg - dMin;
                iImg = round(dImg./(dMax - dMin).*(SAp.iCOLORMAPLENGTH - 1)) + 1;
                iImg(iImg < 1) = 1;
                iImg(iImg > SAp.iCOLORMAPLENGTH) = SAp.iCOLORMAPLENGTH;
                dImg = reshape(SState.dColormapBack(iImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Apply mask if any
                if ~isempty(SData(iSeriesInd).lMask)
%                     dColormap = [0 0 0; SPref.dCOLORMAP(i, :)]
                    dColormap = [0 0 0; lines(max(SData(iSeriesInd).lMask(:)))];
                    switch SState.sDrawMode
                        case {'mag', 'phase'}, iMask = uint8(SData(iSeriesInd).lMask(:,:,SData(iSeriesInd).iActiveImage)) + 1;
                        case {'max', 'min'}  , iMask = uint8(max(SData(iSeriesInd).lMask, [], 3)) + 1;
                    end
                    dMask = reshape(dColormap(iMask, :), [size(iMask, 1) ,size(iMask, 2), 3]);
                    dImg = 1 - (1 - dImg).*(1 - SState.dMaskOpacity.*dMask); % The 'screen' overlay mode
                end
                set(SImg.hImg(i), 'CData', dImg, 'Visible', 'on');
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Update the text elements
                set(STexts.hColorbarMin(i), 'String', sprintf('%s', fPrintNumber(dMin)));
                set(STexts.hColorbarMax(i), 'String', sprintf('%s', fPrintNumber(dMax)));
                set(STexts.hImg1(i), 'String', ['[', int2str(iSeriesInd), ']: ', SData(iSeriesInd).sName]);
                if strcmp(SState.sDrawMode, 'max') || strcmp(SState.sDrawMode, 'min')
                    iMin = max(1, SData(iSeriesInd).iActiveImage - 3);
                    iMax = min(size(SData(iSeriesInd).dImg, 3), SData(iSeriesInd).iActiveImage + 3);
                    set(STexts.hImg2(i), 'String', sprintf('[%u - %u]/%u', iMin, iMax, size(SData(iSeriesInd).dImg, 3)));
                else
                    set(STexts.hImg2(i), 'String', sprintf('%u/%u', SData(iSeriesInd).iActiveImage, size(SData(iSeriesInd).dImg, 3)));
                end
                set(STexts.hEval(i), 'String', SData(iSeriesInd).sEvalText);
                set(SImg.hColorbar(i), 'Visible', 'on');
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
            else % Panel is empty
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Set image to the background image (RGB)
                
                set(SImg.hImg(i), 'CData', SAp.dBGImg, 'Visible', 'on');
                
                set([STexts.hImg1(i), STexts.hEval(i), STexts.hVal(i), STexts.hImg2(i), STexts.hColorbarMin(i), STexts.hColorbarMax(i)], 'String', '');
                set(SImg.hColorbar(i), 'Visible', 'off');
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            end
        end
    end


    function fPosition
        for i = 1:length(SAxes.hImg)
            iSeriesInd = SState.iStartSeries + i - 1;
            
            dAxesPos = get(SAxes.hImg(i), 'Position');
            if iSeriesInd <= length(SData) % Panel not empty
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Handle zoom and shift
                dScale = SData(iSeriesInd).dPixelSpacing;
                dScale = dScale(1, 1:2)./min(dScale); % Smallest Entry scaled to 1
                dDelta_mm = dAxesPos([4, 3])./SData(iSeriesInd).dZoomFactor./dScale;
                set(SAxes.hImg(i), ...
                    'XLim', SData(iSeriesInd).dDrawCenter(2) + 0.5 * [-dDelta_mm(2) dDelta_mm(2)], ...
                    'YLim', SData(iSeriesInd).dDrawCenter(1) + 0.5 * [-dDelta_mm(1) dDelta_mm(1)]);
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            else
                dSize = dAxesPos(4:-1:3);
                dLim = size(SAp.dBGImg(:,:,1))./max(dSize).*dSize;
                set(SAxes.hImg(i), 'XLim', size(SAp.dBGImg, 2)/2 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
                                   'YLim', size(SAp.dBGImg, 1)/2 + 0.5*[-dLim(1) dLim(1)] + 0.5);
            end
        end
    end
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fIconClick (nested in imagine)
    % * * 
    % * * Common callback for all buttons in the menubar
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fIconClick(hObject, eventdata)
        % -----------------------------------------------------------------
        % Get the source's (pressed buttton) data and exit if disabled
        iInd = find(SImg.hIcons == hObject);
        if ~SIcons(iInd).Enabled, return, end;
        % -----------------------------------------------------------------
        
        sActivate = [];
        % -----------------------------------------------------------------
        % Distinguish the idfferent button types (normal, toggle, radio)
        switch SIcons(iInd).GroupIndex
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % NORMAL pushbuttons
            case -1

                switch(SIcons(iInd).Name)
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % LOAD new FILES using file dialog
                    case 'folder_open'
                        if strcmp(get(hF, 'SelectionType'), 'normal')
                            % Load Files
                            [csFilenames, sPath] = uigetfile( ...
                                {'*.*', 'All Files'; ...
                                '*.dcm; *.DCM; *.mat; *.MAT; *.jpg; *.jpeg; *.JPG; *.JPEG; *.tif; *.tiff; *.TIF; *.TIFF; *.gif; *.GIF; *.bmp; *.BMP; *.png; *.PNG; *.nii; *.NII; *.gipl; *.GIPL', 'All images'; ...
                                '*.mat; *.MAT', 'Matlab File (*.mat)'; ...
                                '*.jpg; *.jpeg; *.JPG; *.JPEG', 'JPEG-Image (*.jpg)'; ...
                                '*.tif; *.tiff; *.TIF; *.TIFF;', 'TIFF-Image (*.tif)'; ...
                                '*.gif; *.GIF', 'Gif-Image (*.gif)'; ...
                                '*.bmp; *.BMP', 'Bitmaps (*.bmp)'; ...
                                '*.png; *.PNG', 'Portable Network Graphics (*.png)'; ...
                                '*.dcm; *.DCM', 'DICOM Files (*.dcm)'; ...
                                '*.nii; *.NII', 'NifTy Files (*.nii)'; ...
                                '*.gipl; *.GIPL', 'Guys Image Processing Lab Files (*.gipl)'}, ...
                                'OpenLocation'  , SState.sPath, ...
                                'Multiselect'   , 'on');
                            if isnumeric(sPath), return, end;   % Dialog aborted
                        else
                            % Load a folder
                            sPath = uigetdir(SState.sPath);
                            if isnumeric(sPath), return, end;
                            
                            sPath = [sPath, filesep];
                            SFiles = dir(sPath);
                            SFiles = SFiles(~[SFiles.isdir]);
                            csFilenames = cell(length(SFiles), 1);
                            for i = 1:length(SFiles), csFilenames{i} = SFiles(i).name; end
                        end
                        
                        SState.sPath = sPath;
                        fLoadFiles(csFilenames);
                        fFillPanels();
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -

                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % IMPORT workspace (base) VARIABLE(S)
                    case 'doc_import'
                        csVars = fWSImport();
                        if isempty(csVars), return, end   % Dialog aborted
                        
                        for i = 1:length(csVars)
                            dVar = evalin('base', csVars{i});
                            fAddImageToData(dVar, csVars{i}, 'workspace');
                        end
                        fFillPanels();
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                        
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % SAVE panel data to file(s)
                    case 'save'
                        if strcmp(get(hF, 'SelectionType'), 'normal')
                            [sFilename, sPath] = uiputfile( ...
                                {'*.jpg', 'JPEG-Image (*.jpg)'; ...
                                '*.tif', 'TIFF-Image (*.tif)'; ...
                                '*.gif', 'Gif-Image (*.gif)'; ...
                                '*.bmp', 'Bitmaps (*.bmp)'; ...
                                '*.png', 'Portable Network Graphics (*.png)'}, ...
                                'Save selected series to files', ...
                                [SState.sPath, filesep, '%SeriesName%_%ImageNumber%']);
                            if isnumeric(sPath), return, end;   % Dialog aborted
                            
                            SState.sPath = sPath;
                            fSaveToFiles(sFilename, sPath);
                        else
                            [sFilename, sPath] = uiputfile( ...
                                {'*.jpg', 'JPEG-Image (*.jpg)'; ...
                                '*.tif', 'TIFF-Image (*.tif)'; ...
                                '*.gif', 'Gif-Image (*.gif)'; ...
                                '*.bmp', 'Bitmaps (*.bmp)'; ...
                                '*.png', 'Portable Network Graphics (*.png)'}, ...
                                'Save MASK of selected series to files', ...
                                [SState.sPath, filesep, '%SeriesName%_%ImageNumber%_Mask']);
                            if isnumeric(sPath), return, end;   % Dialog aborted
                            
                            SState.sPath = sPath;
                            fSaveMaskToFiles(sFilename, sPath);
                        end
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -        
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % DELETE DATA from structure
                    case 'doc_delete'
                        iSeriesInd = find([SData.lActive]); % Get indices of selected axes
                        iSeriesInd = iSeriesInd(iSeriesInd >= SState.iStartSeries);
                        SData(iSeriesInd) = []; % Delete the visible active data
                        fFillPanels();
                        fUpdateActivation(); % To make sure panels without data are not selected
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % EXCHANGE SERIES
                    case 'exchange'
                        iSeriesInd = find([SData.lActive]); % Get indices of selected axes
                        SData1 = SData(iSeriesInd(1));
                        SData(iSeriesInd(1)) = SData(iSeriesInd(2)); % Exchange the data
                        SData(iSeriesInd(2)) = SData1;
                        fFillPanels();
                        fUpdateActivation(); % To make sure panels without data are not selected
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % Determine the NUMBER OF PANELS and their LAYOUT
                    case 'grid'
                        iPanels = fGridSelect(4, 4);
                        if ~sum(iPanels), return, end   % Dialog aborted
                        
                        SState.iPanels = iPanels;
                        fCreatePanels; % also updates the SState.iPanels
                        fFillPanels;
                        fUpdateActivation;
                        fResizeFigure(hF, []);
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % Select the COLORMAP
                    case 'colormap'
                        sColormap = fColormapSelect(STexts.hStatus);
                        if ~isempty(sColormap)
                            eval(sprintf('dColormap = %s(SAp.iCOLORMAPLENGTH);', sColormap));
                            SState.dColormapBack = dColormap;
                            fFillPanels;
                            eval(sprintf('colormap(%s(256));', sColormap));
                            set(SAxes.hImg, 'Color', dColormap(1,:));
                        end
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % RESET the view (zoom/window/center)
                    case 'reset' % Reset the view properties of all data
                        for i = 1:length(SData)
                            SData(i).dZoomFactor = 1;
                            SData(i).dWindowCenter = mean(SData(i).dDynamicRange);
                            SData(i).dWindowWidth = SData(i).dDynamicRange(2) - SData(i).dDynamicRange(1);
                            SData(i).dDrawCenter = [0.5 0.5];
                        end
                        fFillPanels();
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % RECORD Start recording data
                    case 'record'
                        [sName, sPath] = uiputfile( ...
                            {'*.csv', 'Comma-separated File (*.csv)'}, ...
                            'Chose Logfile', SState.sPath);
                        if isnumeric(sPath)
                            SState.sEvalFilename = '';
                        else
                            SState.sEvalFilename = [sPath, sName];
                        end
                        SState.sPath = sPath;
                        fUpdateActivation;
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -

                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % STOP logging data
                    case 'stop'
                        SState.sEvalFilename = '';
                        fUpdateActivation;

                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % REWIND last measurement
                    case 'rewind'
                        iPosDel = fGetEvalFilePos;
                        if iPosDel < 0
                            fprintf('File ''%s''does not exist yet or is write-protexted!\n', SState.sEvalFilename);
                            return
                        end
                        
                        if iPosDel == 0
                            fprintf('Log file ''%s'' is empty!\n', SState.sEvalFilename);
                            return
                        end
                        
                        fid = fopen(SState.sEvalFilename, 'r');
                        sLine = fgets(fid);
                        i = 1;
                        lLast = false;
                        while ischar(sLine)
                            csText{i} = sLine;
                            i = i + 1;
                            sLine = fgets(fid);
                            csPos = textscan(sLine, '"%d"');
                            if isempty(csPos{1})
                                iPos = 0;
                            else
                                iPos = csPos{1};
                            end
                            if iPos == iPosDel - 1, lLast = true; end
                            if iPos ~= iPosDel - 1 && lLast, break, end
                        end
                        fclose(fid);
                        iEnd = length(csText);
                        if iPosDel == 1, iEnd = 3; end
                        fid = fopen(SState.sEvalFilename, 'w');
                        for i = 1:iEnd
                            fprintf(fid, '%s', csText{i});
                        end
                        fprintf('Removed entry %d from ''%s''!\n', iPosDel, SState.sEvalFilename);
                        fclose(fid);
   
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -

                    otherwise
                end
            % End of NORMAL buttons
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % TOGGLE buttons: Invert the state
            case 0
                SIcons(iInd).Active = ~SIcons(iInd).Active;
                fUpdateActivation();
                fFillPanels; % Because of link button
            % End of TOGGLE buttons
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The render-mode group
            case 1 % The render-mode group
                if ~strcmp(SState.sDrawMode, SIcons(iInd).Name)
                    SState.sDrawMode = SIcons(iInd).Name;
                    sActivate        = SIcons(iInd).Name;
                else
                    SState.sDrawMode = 'mag';
                end
                fFillPanels;

            case 255 % The toolbar
                % -   -   -   -   -   -   -   -   -   -   -   -   -
                % Right-click setup menus
                if strcmp(get(hF, 'SelectionType'), 'alt') && ~isfield(eventdata, 'Character')% Right click, open tool settings in neccessary
                    switch SIcons(iInd).Name
                        case 'line',
                            csFcns = fSelectEvalFcns(SState.csEvalLineFcns, [SPref.sMFILEPATH, filesep, 'EvalFunctions']);
                            if iscell(csFcns), SState.csEvalLineFcns = csFcns; end
                        case {'roi', 'lw'},
                            csFcns = fSelectEvalFcns(SState.csEvalROIFcns, [SPref.sMFILEPATH, filesep, 'EvalFunctions']);
                            if iscell(csFcns), SState.csEvalROIFcns = csFcns; end
                        case 'rg'
                            csFcns = fSelectEvalFcns(SState.csEvalVolFcns, [SPref.sMFILEPATH, filesep, 'EvalFunctions']);
                            if iscell(csFcns), SState.csEvalVolFcns = csFcns; end
                    end
                end
                % -   -   -   -   -   -   -   -   -   -   -   -   -

                % -   -   -   -   -   -   -   -   -   -   -   -   -
                if ~strcmp(SState.sTool, SIcons(iInd).Name) % Tool change
                    % Try to delete the lines of the ROI and line eval tools
                    if isfield(SLines, 'hEval')
                        try delete(SLines.hEval); end %#ok<TRYNC>
                        SLines = rmfield(SLines, 'hEval');
                    end
                    
                    % Set tool-specific context menus
                    switch SIcons(iInd).Name
                        case 'rg', set(SAxes.hImg, 'uicontextmenu', hContextMenu);
                        otherwise, set(SAxes.hImg, 'uicontextmenu', []);
                    end
                    
                    % Remove the masks, if a new eval tool is selected
                    switch SIcons(iInd).Name
                        case {'line', 'roi', 'lw', 'rg', 'ic'}
                            for i = 1:length(SData), SData(i).lMask = []; end
                            fFillPanels;
                    end

                    % -----------------------------------------------------------------
                    % Reset the ROI painting state machine and Mouse callbacks
                    SState.iROIState = 0;
                    set(gcf, 'WindowButtonDownFcn'  , @fWindowButtonDownFcn);
                    set(gcf, 'WindowButtonMotionFcn', @fWindowMouseHoverFcn);
                    set(gcf, 'WindowButtonUpFcn'    , '');
                    % -----------------------------------------------------------------
                end
                SState.sTool = SIcons(iInd).Name;
                sActivate    = SIcons(iInd).Name;
                % -   -   -   -   -   -   -   -   -   -   -   -   -

        end
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Common code for all radio groups
        if SIcons(iInd).GroupIndex > 0
            for i = 1:length(SIcons)
                if SIcons(i).GroupIndex == SIcons(iInd).GroupIndex
                    SIcons(i).Active = strcmp(SIcons(i).Name, sActivate);
                end
            end
        end
        fUpdateActivation();
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fIconClick
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

      

    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fWindowMouseHoverFcn (nested in imagine)
    % * * 
    % * * Figure callback
    % * *
    % * * The standard mouse move callback. Displays cursor coordinates and
    % * * intensity value of corresponding pixel.
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fWindowMouseHoverFcn(hObject, eventdata)
        
        iAxisInd = fGetPanel();
        if iAxisInd
            % -------------------------------------------------------------
            % Cursor is over a panel -> show coordinates and intensity
            iPos = uint16(get(SAxes.hImg(iAxisInd), 'CurrentPoint')); % Get cursor poition in axis coordinate system
            
            for i = 1:length(SAxes.hImg)
                iSeriesInd = SState.iStartSeries + i - 1;
                if iSeriesInd > length(SData), continue, end
                
                if iPos(1, 1) > 0 && iPos(1, 2) > 0 && iPos(1, 1) <= size(SData(iSeriesInd).dImg, 2) && iPos(1, 2) <= size(SData(iSeriesInd).dImg, 1)
                    switch SState.sDrawMode
                        case {'mag', 'phase'}
                            dImg = fGetImg(iSeriesInd);
                            dVal = dImg(iPos(1, 2), iPos(1, 1));
                        case 'max'
                            if isreal(SData(iSeriesInd).dImg)
                                dVal = max(SData(iSeriesInd).dImg(iPos(1, 2), iPos(1, 1), :), [], 3);
                            else
                                dVal = max(abs(SData(iSeriesInd).dImg(iPos(1, 2), iPos(1, 1), :)), [], 3);
                            end
                        case 'min'
                            if isreal(SData(iSeriesInd).dImg)
                                dVal = min(SData(iSeriesInd).dImg(iPos(1, 2), iPos(1, 1), :), [], 3);
                            else
                                dVal = min(abs(SData(iSeriesInd).dImg(iPos(1, 2), iPos(1, 1), :)), [], 3);
                            end
                    end
                    if i == iAxisInd, set(STexts.hStatus, 'String', sprintf('I(%u,%u) = %s', iPos(1, 1), iPos(1, 2), fPrintNumber(dVal))); end
                    set(STexts.hVal(i), 'String', sprintf('%s', fPrintNumber(dVal)));
                else
                    if i == iAxisInd, set(STexts.hStatus, 'String', ''); end
                    set(STexts.hVal(i), 'String', '');
                end
            end
            % -------------------------------------------------------------
        else
            % -------------------------------------------------------------
            % Cursor is not over a panel -> Check if tooltip has to be shown
            hOver = hittest;
            iInd = find([SImg.hIcons] == hOver);
            if iInd
                sText = SIcons(iInd).Tooltip;
                sAccelerator = SIcons(iInd).Accelerator;
                if ~isempty(SIcons(iInd).Modifier), sAccelerator = sprintf('%s+%s', SIcons(iInd).Modifier, SIcons(iInd).Accelerator); end
                if ~isempty(SIcons(iInd).Accelerator), sText = sprintf('%s [%s]', sText, sAccelerator); end
                set(STexts.hStatus, 'String', sText);
            else
                set(STexts.hStatus, 'String', '');
            end
            % -------------------------------------------------------------
        end

        drawnow update
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fWindowMouseHoverFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fWindowButtonDownFcn (nested in imagine)
    % * * 
    % * * Figure callback
    % * *
    % * * Starting callback for mouse button actions.
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fWindowButtonDownFcn(hObject, eventdata)
        iAxisInd = fGetPanel();
        if ~iAxisInd, return, end % Exit if event didn't occurr in a panel

        % -----------------------------------------------------------------
        % Save starting parameters
        dPos = get(SAxes.hImg(iAxisInd), 'CurrentPoint');
        SMouse.iStartAxis       = iAxisInd;
        SMouse.iStartPos        = get(hObject, 'CurrentPoint');
        SMouse.dAxesStartPos    = [dPos(1, 1), dPos(1, 2)];
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % Backup the display settings of all data
        SMouse.dDrawCenter   = reshape([SData.dDrawCenter], [2, length(SData)]);
        SMouse.dZoomFactor   = [SData.dZoomFactor];
        SMouse.dWindowCenter = [SData.dWindowCenter];
        SMouse.dWindowWidth  = [SData.dWindowWidth];
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % Delete existing line objects, clear masks
        if isfield(SLines, 'hEval')
            try delete(SLines.hEval); end %#ok<TRYNC>
            SLines = rmfield(SLines, 'hEval');
        end
        switch SState.sTool
            case {'line', 'roi', 'lw', 'rg', 'ic'}
                for i = 1:length(SData), SData(i).lMask = []; end
                fFillPanels;
        end
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % Activate the callbacks for drag operations
            set(hObject, 'WindowButtonUpFcn',     @fWindowButtonUpFcn);
        set(hObject, 'WindowButtonMotionFcn', @fWindowMouseMoveFcn);
        % -----------------------------------------------------------------

        drawnow update
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fWindowButtonDownFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fWindowMouseMoveFcn (nested in imagine)
    % * * 
    % * * Figure callback
    % * *
    % * * Callback for mouse movement while button is pressed.
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =    
    function fWindowMouseMoveFcn(hObject, eventdata)
        iAxesInd = fGetPanel();
                
        % -----------------------------------------------------------------
        % Get some frequently used values
        lLinked   = fIsOn('link'); % Determines whether axes are linked
        iD        = get(hF, 'CurrentPoint') - SMouse.iStartPos; % Mouse distance travelled since button down
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % Tool-specific code
        switch SState.sTool

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The NORMAL CURSOR: select, move, zoom, window
            case 'cursor_arrow'
                switch get(hF, 'SelectionType')

                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % Normal, left mouse button -> MOVE operation
                    case 'normal' 
                        dD = double(iD); % Scale mouse movement to panel size (since DrawCenter is a relative value)
                        dD(2) = -dD(2);
                        for i = 1:length(SData)
                            iAxisInd = i - SState.iStartSeries + 1;
                            if ~((lLinked) || (iAxisInd == SMouse.iStartAxis)), continue, end % Skip if axes not linked and current figure not active
                            
                            dScale = SData(i).dPixelSpacing(1:2)./min(SData(i).dPixelSpacing);
                            
                            dNewPos = SMouse.dDrawCenter(:, i)' - flip(dD)./dScale./SData(i).dZoomFactor; % Calculate new draw center relative to saved one
                            SData(i).dDrawCenter = dNewPos; % Save DrawCenter data
                        end
                        fPosition;
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % Shift key or right mouse button -> ZOOM operation
                    case 'alt'
                        for i = 1:length(SData)
                            if (~fIsOn('link')) && i ~= (SMouse.iStartAxis + SState.iStartSeries - 1), continue, end % Skip if axes not linked and current figure not active
                            
                            dZoom = min(100, max(0.25, SMouse.dZoomFactor(i).*exp(SPref.dZOOMSENSITIVITY.*iD(2))));
                            
                            dOldDrawCenter = SMouse.dDrawCenter(:, i)';
                            dMouseStart = flip(SMouse.dAxesStartPos, 2);
                            dD = dOldDrawCenter - dMouseStart;
                            SData(i).dDrawCenter = dMouseStart + SMouse.dZoomFactor(i)./dZoom.*dD;
                            SData(i).dZoomFactor = dZoom; % Save ZoomFactor data
                            
                        end
                        fPosition;

                    case 'extend' % Control key or middle mouse button -> WINDOW operation
                        for i = 1:length(SData)
                            if (~fIsOn('link')) && (i ~= SMouse.iStartAxis + SState.iStartSeries - 1), continue, end % Skip if axes not linked and current figure not active
                            
                            SData(i).dWindowWidth  = SMouse.dWindowWidth(i) .*exp(SPref.dWINDOWSENSITIVITY*(-iD(2)));
                            SData(i).dWindowCenter = SMouse.dWindowCenter(i).*exp(SPref.dWINDOWSENSITIVITY*  iD(1));
                            iAxisInd = i - SState.iStartSeries + 1;
                            if iAxisInd < 1 || iAxisInd > length(SAxes.hImg), continue, end % Do not update images outside the figure's scope (will be done with next call of fFillPanels)
                            if iAxisInd == SMouse.iStartAxis % Show windowing information for the starting axes
                                set(STexts.hStatus, 'String', sprintf('C: %s, W: %s', fPrintNumber(SData(i).dWindowCenter), fPrintNumber(SData(i).dWindowWidth)));
                            end
                        end
                        fFillPanels;
                end
            % end of the NORMAL CURSOR
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The ROTATION tool
            case 'rotate'
                if ~any(abs(iD) > SPref.dROTATION_THRESHOLD), return, end   % Only proceed if action required

                iStartSeries = SMouse.iStartAxis + SState.iStartSeries - 1;
                for i = 1:length(SData)
                    if ~(lLinked || i == iStartSeries || SData(i).iGroupIndex == SData(iStartSeries).iGroupIndex), continue, end % Skip if axes not linked and current figure not active
                    
                    switch get(hObject, 'SelectionType')
                        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                        % Normal, left mouse button -> volume rotation operation
                        case 'normal'
                            if iD(1) > SPref.dROTATION_THRESHOLD % Moved mouse to left
                                SData(i).iActiveImage = uint16(SMouse.dAxesStartPos(1, 1));
                                iPermutation = [1 3 2]; iFlipdim = 2;
                            end
                            if iD(1) < -SPref.dROTATION_THRESHOLD % Moved mouse to right
                                SData(i).iActiveImage = uint16(size(SData(i).dImg, 2) - SMouse.dAxesStartPos(1, 1) + 1);
                                iPermutation = [1 3 2]; iFlipdim = 3;
                            end
                            if iD(2) > SPref.dROTATION_THRESHOLD
                                SData(i).iActiveImage = uint16(size(SData(i).dImg, 1) - SMouse.dAxesStartPos(1, 2) + 1);
                                iPermutation = [3 2 1]; iFlipdim = 3;
                            end
                            if iD(2) < -SPref.dROTATION_THRESHOLD
                                SData(i).iActiveImage = uint16(SMouse.dAxesStartPos(1, 2));
                                iPermutation = [3 2 1]; iFlipdim = 1;
                            end
                            
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        % Shift key or right mouse button -> rotate in-plane
                        case 'alt'
                            if any(iD > SPref.dROTATION_THRESHOLD)
                                iPermutation = [2 1 3]; iFlipdim = 2;
                            end
                            if any(iD < -SPref.dROTATION_THRESHOLD)
                                iPermutation = [2 1 3]; iFlipdim = 1;
                            end
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        
                        case 'extend'
                            return
                    end
                    % Switch statement
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % Apply the transformation
                    SData(i).dImg =  flipdim(permute(SData(i).dImg,  iPermutation), iFlipdim);
                    SData(i).lMask = flipdim(permute(SData(i).lMask, iPermutation), iFlipdim);
                    SData(i).dPixelSpacing = SData(i).dPixelSpacing(iPermutation);
                    set(hObject, 'WindowButtonMotionFcn', @fWindowMouseHoverFcn);
                    
                    % - - - - - - - - - - - - - - - - - - - - - - -
                    % Limit active image range to image dimensions
                    if SData(i).iActiveImage < 1, SData(i).iActiveImage = 1; end
                    if SData(i).iActiveImage > size(SData(i).dImg, 3), SData(i).iActiveImage = size(SData(i).dImg, 3); end
                end
                % Loop over the data
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
                fFillPanels();
            % END of the rotate tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The LINE EVALUATION tool
            case 'line'
                if ~iAxesInd, return, end % Exit if event didn't occurr in a panel
                dPos = get(SAxes.hImg(iAxesInd), 'CurrentPoint');
                if ~isfield(SLines, 'hEval') % Make sure line object exists
                    for i = 1:length(SAxes.hImg)
                        if i + SState.iStartSeries - 1 > length(SData), continue, end
                        SLines.hEval(i) = line([SMouse.dAxesStartPos(1, 1), dPos(1, 1)], [SMouse.dAxesStartPos(1, 2), dPos(1, 2)], ...
                            'Parent'        , SAxes.hImg(i), ...
                            'Color'         , SPref.dCOLORMAP(i,:), ...
                            'LineStyle'     , '-');
                    end
                else
                    set(SLines.hEval, 'XData', [SMouse.dAxesStartPos(1, 1), dPos(1, 1)], 'YData', [SMouse.dAxesStartPos(1, 2), dPos(1, 2)]);
                end
                fWindowMouseHoverFcn(hF, []); % Update the position display by triggering the mouse hover callback
            % end of the LINE EVALUATION tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Handle special case of ROI drawing (update the lines), ellipse
            case 'roi'
                if ~iAxesInd || iAxesInd + SState.iStartSeries - 1 > length(SData), return, end
                
                switch SState.iROIState
                    
                    case 0 % No drawing -> Check if one should start an elliplse or rectangle
                        dPos = get(SAxes.hImg(SMouse.iStartAxis), 'CurrentPoint');
                        if sum((dPos(1, 1:2) - SMouse.dAxesStartPos).^2) > 4
                            for i = 1:length(SAxes.hImg)
                                if i + SState.iStartSeries - 1 > length(SData), continue, end
                                SLines.hEval(i) = line(dPos(1, 1), dPos(1, 2), ...
                                    'Parent'    , SAxes.hImg(i), ...
                                    'Color'     , SPref.dCOLORMAP(i,:),...
                                    'LineStyle' , '-');
                            end
                            switch(get(hF, 'SelectionType'))
                                case 'normal', SState.iROIState = 2; % -> Rectangle
                                case {'alt', 'extend'}, SState.iROIState = 3; % -> Ellipse
                            end
                        end
                        
                    case 1 % Polygon mode
                        dPos = get(SAxes.hImg(iAxesInd), 'CurrentPoint');
                        dROILineX = [SState.dROILineX; dPos(1, 1)]; % Draw a line to the cursor position
                        dROILineY = [SState.dROILineY; dPos(1, 2)];
                        set(SLines.hEval, 'XData', dROILineX, 'YData', dROILineY);

                    case 2 % Rectangle mode
                        dPos = get(SAxes.hImg(iAxesInd), 'CurrentPoint');
                        SState.dROILineX = [SMouse.dAxesStartPos(1); SMouse.dAxesStartPos(1); dPos(1, 1); dPos(1, 1); SMouse.dAxesStartPos(1)];
                        SState.dROILineY = [SMouse.dAxesStartPos(2); dPos(1, 2); dPos(1, 2); SMouse.dAxesStartPos(2); SMouse.dAxesStartPos(2)];
                        set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
                        
                    case 3 % Ellipse mode
                        dPos = get(SAxes.hImg(iAxesInd), 'CurrentPoint');
                        dDX = dPos(1, 1) - SMouse.dAxesStartPos(1);
                        dDY = dPos(1, 2) - SMouse.dAxesStartPos(2);
                        if strcmp(get(hF, 'SelectionType'), 'extend')
                            dD = max(abs([dDX, dDY]));
                            dDX = sign(dDX).*dD;
                            dDY = sign(dDY).*dD;
                        end
                        dT = linspace(-pi, pi, 100)';
                        SState.dROILineX = SMouse.dAxesStartPos(1) + dDX./2.*(1 + cos(dT));
                        SState.dROILineY = SMouse.dAxesStartPos(2) + dDY./2.*(1 + sin(dT));
                        set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
                end
                fWindowMouseHoverFcn(hF, []); % Update the position display by triggering the mouse hover callback
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Handle special case of LW drawing (update the lines)
            case 'lw'
                if iAxesInd == SMouse.iStartAxis 
                    if SState.iROIState == 1 && sum(abs(SState.iPX(:))) > 0 % ROI drawing in progress
                        dPos = get(SAxes.hImg(SMouse.iStartAxis), 'CurrentPoint');
                        [iXPath, iYPath] = fLiveWireGetPath(SState.iPX, SState.iPY, dPos(1, 1), dPos(1, 2));
                        if isempty(iXPath)
                            iXPath = dPos(1, 1);
                            iYPath = dPos(1, 2);
                        end
                        set(SLines.hEval, 'XData', [SState.dROILineX; double(iXPath(:))], ...
                                          'YData', [SState.dROILineY; double(iYPath(:))]);
                        drawnow update
                    end
                end
                fWindowMouseHoverFcn(hF, []); % Update the position display by triggering the mouse hover callback
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            otherwise

        end
        % end of the TOOL switch statement
        % -----------------------------------------------------------------

        drawnow update
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fWindowMouseMoveFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    

    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fWindowButtonUpFcn (nested in imagine)
    % * * 
    % * * Figure callback
    % * *
    % * * End of mouse operations.
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fWindowButtonUpFcn(hObject, eventdata)
        iAxisInd = fGetPanel();
        
        iCursorPos = get(hF, 'CurrentPoint');
        % -----------------------------------------------------------------
        % Stop the operation by disabling the corresponding callbacks
        set(hF, 'WindowButtonMotionFcn'    ,@fWindowMouseHoverFcn);
        set(hF, 'WindowButtonUpFcn'        ,'');
        set(STexts.hStatus, 'String', '');
        % -----------------------------------------------------------------
            
        % -----------------------------------------------------------------
        % Tool-specific code
        switch SState.sTool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The NORMAL CURSOR: select, move, zoom, window
            % In this function, only the select case has to be handled
            case 'cursor_arrow'
                if ~sum(abs(iCursorPos - SMouse.iStartPos)) % Proceed only if mouse was moved
                    
                    switch get(hF, 'SelectionType')
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        % NORMAL selection: Select only current series
                        case 'normal'
                            iN = fGetNActiveVisibleSeries();
                            for iSeries = 1:length(SData)
                                if SMouse.iStartAxis + SState.iStartSeries - 1 == iSeries
                                    SData(iSeries).lActive = ~SData(iSeries).lActive || iN > 1;
                                else
                                    SData(iSeries).lActive = false;
                                end
                            end
                            SState.iLastSeries = SMouse.iStartAxis + SState.iStartSeries - 1; % The lastAxis is needed for the shift-click operation
                        % end of normal selection
                        % - - - - - - - - - - - - - - - - - - - - - - - - -

                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        %  Shift key or right mouse button: Select ALL axes
                        %  between last selected axis and current axis
                        case 'extend'
                            iSeriesInd = SMouse.iStartAxis + SState.iStartSeries - 1;
                            if sum([SData.lActive] == true) == 0
                                % If no panel active, only select the current axis
                                SData(iSeriesInd).lActive = true;
                                SState.iLastSeries = iSeriesInd;
                            else
                                if SState.iLastSeries ~= iSeriesInd
                                    iSortedInd = sort([SState.iLastSeries, iSeriesInd], 'ascend');
                                    for i = 1:length(SData)
                                        SData(i).lActive = (i >= iSortedInd(1)) && (i <= iSortedInd(2));
                                    end
                                end
                            end
                        % end of shift key/right mouse button
                        % - - - - - - - - - - - - - - - - - - - - - - - - -

                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        % Cntl key or middle mouse button: ADD/REMOVE axis
                        % from selection
                        case 'alt'
                            iSeriesInd = SMouse.iStartAxis + SState.iStartSeries - 1;
                            SData(iSeriesInd).lActive = ~SData(iSeriesInd).lActive;
                            SState.iLastSeries = iSeriesInd;
                        % end of alt/middle mouse buttton
                        % - - - - - - - - - - - - - - - - - - - - - - - - -
                        
                    end
                end
            % end of the NORMAL CURSOR
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The LINE EVALUATION tool
            case 'line'
                fEval(SState.csEvalLineFcns);
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % End of the LINE EVALUATION tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The ROI EVALUATION tool
            case 'roi'
                set(hF, 'WindowButtonMotionFcn', @fWindowMouseMoveFcn);
                set(hF, 'WindowButtonDownFcn', '');
                set(hF, 'WindowButtonUpFcn', @fWindowButtonUpFcn); % But keep the button up function
                                
                if iAxisInd && iAxisInd + SState.iStartSeries - 1 <= length(SData) % ROI drawing in progress
                    dPos = get(SAxes.hImg(iAxisInd), 'CurrentPoint');
                    
                    if SState.iROIState > 1 || any(strcmp({'extend', 'open'}, get(hF, 'SelectionType')))
                        
                        SState.dROILineX = [SState.dROILineX; SState.dROILineX(1)]; % Close line
                        SState.dROILineY = [SState.dROILineY; SState.dROILineY(1)];
                        
                        delete(SLines.hEval);
                        SState.iROIState = 0;
                        set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
                        set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn);
                        set(hF, 'WindowButtonUpFcn', '');
                        fEval(SState.csEvalROIFcns);
                        return
                    end

                    switch get(hF, 'SelectionType')
                        
                        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                        % NORMAL selection: Add point to roi
                        case 'normal'
                            if ~SState.iROIState % This is the first polygon point
                                SState.dROILineX = dPos(1, 1);
                                SState.dROILineY = dPos(1, 2);
                                for i = 1:length(SAxes.hImg)
                                    if i + SState.iStartSeries - 1 > length(SData), continue, end
                                    SLines.hEval(i) = line(SState.dROILineX, SState.dROILineY, ...
                                        'Parent'    , SAxes.hImg(i), ...
                                        'Color'     , SPref.dCOLORMAP(i,:),...
                                        'LineStyle' , '-');
                                end
                                SState.iROIState = 1;
                            else % Add point to existing polygone
                                SState.dROILineX = [SState.dROILineX; dPos(1, 1)];
                                SState.dROILineY = [SState.dROILineY; dPos(1, 2)];
                                set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
                            end
                            % End of NORMAL selection
                            % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                            
                            % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                            % Right mouse button/shift key: UNDO last point, quit
                            % if is no point remains
                        case 'alt'
                            if ~SState.iROIState, return, end    % Only perform action if painting in progress
                            
                            if length(SState.dROILineX) > 1
                                SState.dROILineX = SState.dROILineX(1:end-1); % Delete last point
                                SState.dROILineY = SState.dROILineY(1:end-1);
                                dROILineX = [SState.dROILineX; dPos(1, 1)]; % But draw line to current cursor position
                                dROILineY = [SState.dROILineY; dPos(1, 2)];
                                set(SLines.hEval, 'XData', dROILineX, 'YData', dROILineY);
                            else % Abort drawing ROI
                                SState.iROIState = 0;
                                delete(SLines.hEval);
                                SLines = rmfield(SLines, 'hEval');
                                set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
                                set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn); % Disable the button down function
                            end
                            % End of right click/shift-click
                            % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    end
                end
            % End of the ROI EVALUATION tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The LIVEWIRE EVALUATION tool
            case 'lw'
                set(hF, 'WindowButtonMotionFcn', @fWindowMouseMoveFcn);
                set(hF, 'WindowButtonDownFcn', '');
                set(hF, 'WindowButtonUpFcn', @fWindowButtonUpFcn); % But keep the button up function
                if iAxisInd ~= SMouse.iStartAxis, return, end
                
                dPos = get(SAxes.hImg(SMouse.iStartAxis), 'CurrentPoint');
                switch get(hF, 'SelectionType')
                    
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % NORMAL selection: Add point to roi
                    case 'normal'
                        if ~SState.iROIState % This is the first polygon point
                            dImg = SData(SMouse.iStartAxis + SState.iStartSeries - 1).dImg(:,:,SData(SMouse.iStartAxis + SState.iStartSeries - 1).iActiveImage);
                            SState.dLWCostFcn = fLiveWireGetCostFcn(dImg);
                            SState.dROILineX = dPos(1, 1);
                            SState.dROILineY = dPos(1, 2);
                            for i = 1:length(SAxes.hImg)
                                if i + SState.iStartSeries - 1 > length(SData), continue, end
                                SLines.hEval(i) = line(SState.dROILineX, SState.dROILineY, ...
                                    'Parent'    , SAxes.hImg(i), ...
                                    'Color'     , SPref.dCOLORMAP(i,:),...
                                    'LineStyle' , '-');
                            end
                            SState.iROIState = 1;
                            SState.iLWAnchorList = zeros(200, 1);
                            SState.iLWAnchorInd  = 0;
                        else % Add point to existing polygone
                            [iXPath, iYPath] = fLiveWireGetPath(SState.iPX, SState.iPY, dPos(1, 1), dPos(1, 2));
                            if isempty(iXPath)
                                iXPath = dPos(1, 1);
                                iYPath = dPos(1, 2);
                            end
                            SState.dROILineX = [SState.dROILineX; double(iXPath(:))];
                            SState.dROILineY = [SState.dROILineY; double(iYPath(:))];
                            set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
                        end
                        SState.iLWAnchorInd = SState.iLWAnchorInd + 1;
                        SState.iLWAnchorList(SState.iLWAnchorInd) = length(SState.dROILineX); % Save the previous path length for the undo operation
                        [SState.iPX, SState.iPY] = fLiveWireCalcP(SState.dLWCostFcn, dPos(1, 1), dPos(1, 2), SPref.dLWRADIUS);
                    % End of NORMAL selection
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -

                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    % Right mouse button/shift key: UNDO last point, quit
                    % if is no point remains
                    case 'alt'
                        if SState.iROIState
                            SState.iLWAnchorInd = SState.iLWAnchorInd - 1;
                            if SState.iLWAnchorInd
                                SState.dROILineX = SState.dROILineX(1:SState.iLWAnchorList(SState.iLWAnchorInd)); % Delete last point
                                SState.dROILineY = SState.dROILineY(1:SState.iLWAnchorList(SState.iLWAnchorInd));
                                set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
                                drawnow;
                                [SState.iPX, SState.iPY] = fLiveWireCalcP(SState.dLWCostFcn, SState.dROILineX(end), SState.dROILineY(end), SPref.dLWRADIUS);
                                fWindowMouseMoveFcn(hObject, []);
                            else % Abort drawing ROI
                                SState.iROIState = 0;
                                delete(SLines.hEval);
                                SLines = rmfield(SLines, 'hEval');
                                set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
                                set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn);
                            end
                        end
                    % End of right click/shift-click
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - - 

                    % Middle mouse button/double-click/cntl-click: CLOSE
                    % POLYGONE and quit roi action
                    case {'extend', 'open'} % Middle mouse button or double-click -> 
                        if ~SState.iROIState, return, end    % Only perform action if painting in progress
                        
                        [iXPath, iYPath] = fLiveWireGetPath(SState.iPX, SState.iPY, dPos(1, 1), dPos(1, 2));
                        if isempty(iXPath)
                            iXPath = dPos(1, 1);
                            iYPath = dPos(1, 2);
                        end
                        SState.dROILineX = [SState.dROILineX; double(iXPath(:))];
                        SState.dROILineY = [SState.dROILineY; double(iYPath(:))];
                        
                        [SState.iPX, SState.iPY] = fLiveWireCalcP(SState.dLWCostFcn, dPos(1, 1), dPos(1, 2), SPref.dLWRADIUS);
                        [iXPath, iYPath] = fLiveWireGetPath(SState.iPX, SState.iPY, SState.dROILineX(1), SState.dROILineY(1));
                        if isempty(iXPath)
                            iXPath = SState.dROILineX(1);
                            iYPath = SState.dROILineX(2);
                        end
                        SState.dROILineX = [SState.dROILineX; double(iXPath(:))];
                        SState.dROILineY = [SState.dROILineY; double(iYPath(:))];
                        set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
                        
                        delete(SLines.hEval);
                        SState.iROIState = 0;
                        set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
                        set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn);
                        set(hF, 'WindowButtonUpFcn', '');
                        fEval(SState.csEvalROIFcns);

                    % End of middle mouse button/double-click/cntl-click
                    % - - - - - - - - - - - - - - - - - - - - - - - - - - -

                end
            % End of the LIVEWIRE EVALUATION tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The REGION GROWING tool
            case 'rg'
                if ~strcmp(get(hF, 'SelectionType'), 'normal'), return, end; % Otherwise calling the context menu starts a rg
                if ~iAxisInd || iAxisInd > length(SData), return, end;

                iSeriesInd = iAxisInd + SState.iStartSeries - 1;
                iSize = size(SData(iSeriesInd).dImg);
                dPos = get(SAxes.hImg(iAxisInd), 'CurrentPoint');
                if dPos(1, 1) < 1 || dPos(1, 2) < 1 || dPos(1, 1) > iSize(2) || dPos(1, 2) > iSize(1), return, end
                
                fEval(SState.csEvalVolFcns);
            % End of the REGION GROWING tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The ISOCONTOUR tool
            case 'ic'
                if ~iAxisInd || iAxisInd > length(SData), return, end;
                
                iSeriesInd = iAxisInd + SState.iStartSeries - 1;
                iSize = size(SData(iSeriesInd).dImg);
                dPos = get(SAxes.hImg(iAxisInd), 'CurrentPoint');
                if dPos(1, 1) < 1 || dPos(1, 2) < 1 || dPos(1, 1) > iSize(2) || dPos(1, 2) > iSize(1), return, end
                
                fEval(SState.csEvalVolFcns);
            % End of the ISOCONTOUR tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
                
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The PROPERTIES tool: Rename the data
            case 'tag'
                if ~iAxisInd || iAxisInd > length(SData), return, end;
                
                iSeriesInd = SState.iStartSeries + iAxisInd - 1;
                csPrompt = {'Name', 'Voxel Size', 'Units'};
                dDim = SData(iSeriesInd).dPixelSpacing;
                sDim = sprintf('%4.2f x ', dDim([2, 1, 3]));
                csVal = {SData(iSeriesInd).sName, sDim(1:end-3), SData(iSeriesInd).sUnits};
                csAns    = inputdlg(csPrompt, sprintf('Change %s', SData(iSeriesInd).sName), 1, csVal);
                if isempty(csAns), return, end
                
                sName = csAns{1};
                iInd = find([SData.iGroupIndex] == SData(iSeriesInd).iGroupIndex);
                if length(iInd) > 1
                    if ~isnan(str2double(sName(end - 1:end))), sName = sName(1:end - 2); end % Crop the number
                end
                dDim = cell2mat(textscan(csAns{2}, '%fx%fx%f'));
                iCnt = 1;
                for i = iInd
                    if length(iInd) > 1
                        SData(i).sName = sprintf('%s%02d', sName, iCnt);
                    else
                        SData(i).sName = sName;
                    end
                    SData(i).dPixelSpacing  = dDim([2, 1, 3]);
                    SData(i).sUnits = csAns{3};
                    iCnt = iCnt + 1;
                end
                fFillPanels;
            % End of the TAG tool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        end
        % end of the tool switch-statement
        % -----------------------------------------------------------------

        fUpdateActivation();
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fWindowButtonUpFcn
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fKeyPressFcn (nested in imagine)
    % * * 
    % * * Figure callback
    % * *
    % * * Callback for keyboard actions.
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fKeyPressFcn(hObject, eventdata)
        % -----------------------------------------------------------------
        % Bail if only a modifier has been pressed
        switch eventdata.Key
            case {'shift', 'control', 'alt'}, return
        end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Get the modifier (shift, cntl, alt) keys and determine whether
        % the control key was pressed
        csModifier = eventdata.Modifier;
        sModifier = '';
        for i = 1:length(csModifier)
            if strcmp(csModifier{i}, 'shift'  ), sModifier = 'Shift'; end
            if strcmp(csModifier{i}, 'control'), sModifier = 'Cntl'; end
            if strcmp(csModifier{i}, 'alt'    ), sModifier = 'Alt'; end
        end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Look for buttons with corresponding accelerators/modifiers
        for i = 1:length(SIcons)
            if strcmp(SIcons(i).Accelerator, eventdata.Key) && ...
               strcmp(SIcons(i).Modifier, sModifier)
                fIconClick(SImg.hIcons(i), eventdata);
            end
        end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Functions not implemented by buttons
        switch eventdata.Key
            case {'numpad1', 'leftarrow'} % Image up
                fChangeImage(hObject, -1);
                
            case {'numpad2', 'rightarrow'} % Image down
                fChangeImage(hObject, 1);
                
            case {'numpad4', 'uparrow'} % Series up
                SState.iStartSeries = max([1 SState.iStartSeries - 1]);
                fFillPanels();
                fUpdateActivation();
                fWindowMouseHoverFcn(hObject, eventdata); % Update the cursor value

            case {'numpad5', 'downarrow'} % Series down
                SState.iStartSeries = min([SState.iStartSeries + 1 length(SData)]);
                SState.iStartSeries = max([SState.iStartSeries 1]);
                fFillPanels();
                fUpdateActivation();
                fWindowMouseHoverFcn(hObject, eventdata); % Update the cursor value
                
            case 'period'
                SState.iStartSeries = SState.iStartSeries + 1;
                if SState.iStartSeries > length(SData), SState.iStartSeries = 1; end
                fFillPanels();
                fUpdateActivation();
                fWindowMouseHoverFcn(hObject, eventdata); % Update the cursor value
                
            case 'space' % Cycle Tools
                iTools = find([SIcons.GroupIndex] == 255 & [SIcons.Enabled]);
                iToolInd = find(strcmp({SIcons.Name}, SState.sTool));
                iToolIndInd = find(iTools == iToolInd);
                iTools = [iTools(end), iTools, iTools(1)];
                if ~strcmp(sModifier, 'Shift'), iToolIndInd = iToolIndInd + 2; end
                iToolInd = iTools(iToolIndInd);
                fIconClick(SImg.hIcons(iToolInd), eventdata);
                
        end
        % -----------------------------------------------------------------
        set(hF, 'SelectionType', 'normal');
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fKeyPressFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fContextFcn (nested in imagine)
    % * * 
    % * * Menu callback
    % * *
    % * * Callback for context menu clicks
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fContextFcn(hObject, eventdata)
        switch get(hObject, 'Label')
            case 'Tolerance +50%', SState.dTolerance = SState.dTolerance.*1.5;
            case 'Tolerance +10%', SState.dTolerance = SState.dTolerance.*1.1;
            case 'Tolerance -10%', SState.dTolerance = SState.dTolerance./1.1;
            case 'Tolerance -50%', SState.dTolerance = SState.dTolerance./1.5;
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fContextFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fEval (nested in imagine)
    % * * 
    % * * Do the evaluation of line/ROIs
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fEval(csFcns)
        dPos = get(SAxes.hImg(fGetPanel), 'CurrentPoint');
        
        % -----------------------------------------------------------------
        % Depending on the time series setting, eval only visible or all data
        if fIsOn('clock')
            iSeries = 1:length(SData); % Eval all series
        else
            iSeries = 1:length(SData);
            iSeries = iSeries(iSeries >= SState.iStartSeries & iSeries < SState.iStartSeries + length(SAxes.hImg));
        end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Get the rawdata for evaluation and the distance/area/volume
        csSeriesName    = cell(length(iSeries), 1);
        cData           = cell(length(iSeries), 1);
        dMeasures       = zeros(length(iSeries), length(csFcns) + 1);
        csName          = cell(1, length(csFcns) + 1);
        csUnitString    = cell(1, length(csFcns) + 1);
        
        % -----------------------------------------------------------------
        % Series Loop
        for i = 1:length(iSeries)
            iSeriesInd = iSeries(i);
            csSeriesName{i} = SData(i).sName;
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Tool dependent code
            switch SState.sTool
                case 'line'
                    dXStart = SMouse.dAxesStartPos(1,1);    dYStart = SMouse.dAxesStartPos(1,2);
                    dXEnd   = dPos(1,1);                    dYEnd = dPos(1,2);
                    dDist = sqrt(((dXStart - dXEnd).*SData(iSeriesInd).dPixelSpacing(2)).^2 + ((dYStart - dYEnd).*SData(iSeriesInd).dPixelSpacing(1)).^2);
                    if dDist < 1.0, return, end % In case of a misclick
                    
                    csName{1} = 'Length';
                    csUnitString{1} = sprintf('%s', SData(iSeriesInd).sUnits);
                    dMeasures(i, 1) = dDist;
                    cData{i}    = improfile(fGetImg(iSeriesInd), [dXStart dXEnd], [dYStart, dYEnd], round(dDist), 'bilinear');
                
                case {'roi', 'lw'}
                    csName{1} = 'Area';
                    csUnitString{1} = sprintf('%s^2', SData(iSeriesInd).sUnits);
                    dImg = fGetImg(iSeriesInd);
                    lMask = poly2mask(SState.dROILineX, SState.dROILineY, size(dImg, 1), size(dImg, 2));
                    dMeasures(i, 1) = nnz(lMask).*SData(iSeriesInd).dPixelSpacing(2).*SData(iSeriesInd).dPixelSpacing(1);
                    cData{i} = dImg(lMask);
                    SData(iSeriesInd).lMask = false(size(SData(iSeriesInd).dImg));
                    SData(iSeriesInd).lMask(:,:,SData(iSeriesInd).iActiveImage) = lMask;
                    fFillPanels;
            
                case 'rg'
                    csName{1} = 'Volume';
                    csUnitString{1} = sprintf('%s^3', SData(iSeriesInd).sUnits);
                    if strcmp(SState.sDrawMode, 'phase')
                        dImg = angle(SData(iSeriesInd).dImg);
                    else
                        dImg = SData(iSeriesInd).dImg;
                        if ~isreal(dImg), dImg = abs(dImg); end
                    end
                    if i == 1 % In the first series detrmine the tolerance and use the same tolerance in the other series
                        [lMask, dTol] = fRegionGrowingAuto_mex(dImg, int16([dPos(1, 2); dPos(1, 1); SData(iSeriesInd).iActiveImage]), -1, SState.dTolerance);
                    else
                        lMask         = fRegionGrowingAuto_mex(dImg, int16([dPos(1, 2); dPos(1, 1); SData(iSeriesInd).iActiveImage]), dTol);
                    end
                    dMeasures(i, 1) = nnz(lMask).*prod(SData(iSeriesInd).dPixelSpacing);
                    cData{i} = dImg(lMask);
                    SData(iSeriesInd).lMask = lMask;
                    fFillPanels;
                    
                case 'ic'
                    csName{1} = 'Volume';
                    csUnitString{1} = sprintf('%s^3', SData(iSeriesInd).sUnits);
                    if strcmp(SState.sDrawMode, 'phase')
                        dImg = angle(SData(iSeriesInd).dImg);
                    else
                        dImg = SData(iSeriesInd).dImg;
                        if ~isreal(dImg), dImg = abs(dImg); end
                    end
                    lMask = fIsoContour_mex(dImg, int16([dPos(1, 2); dPos(1, 1); SData(iSeriesInd).iActiveImage]), 0.5);
                    dMeasures(i, 1) = nnz(lMask).*prod(SData(iSeriesInd).dPixelSpacing);
                    cData{i} = dImg(lMask);
                    SData(iSeriesInd).lMask = lMask;
                    fFillPanels;

            end
            % End of switch SState.sTool
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Do the evaluation
            sEvalString = sprintf('%s = %s %s\n', csName{1}, num2str(dMeasures(i, 1)), csUnitString{1});
            for iJ = 2:length(csFcns) + 1
                [dMeasures(i, iJ), csName{iJ}, sUnitFormat] = eval([csFcns{iJ - 1}, '(cData{i});']);
                csUnitString{iJ} = sprintf(sUnitFormat, SData(iSeriesInd).sUnits);
                if isempty(csUnitString{iJ}), csUnitString{iJ} = ''; end
                sEvalString = sprintf('%s%s = %s %s\n', sEvalString, csName{iJ}, num2str(dMeasures(i, iJ)), csUnitString{iJ});
            end
            SData(iSeriesInd).sEvalText = sEvalString(1:end-1);
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
        end
        % End of series loop
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % Plot the line profile and add name to legend
        % Check for presence of plot figure and create if necessary.
        if (fIsOn('line1') && fIsOn('clock')) || (fIsOn('line1') && ~fIsOn('clock') && strcmp(SState.sTool, 'line'))
            if ~ishandle(SState.hEvalFigure)
                SState.hEvalFigure = figure('Units', 'pixels', 'Position', [100 100 600, 400], 'NumberTitle', 'off');
                axes('Parent', SState.hEvalFigure);
                hold on;
            end
            figure(SState.hEvalFigure);
            hL = findobj(SState.hEvalFigure, 'Type', 'line');
            hAEval = gca;
            delete(hL);

            if fIsOn('clock')
                for i = 2:size(dMeasures, 2)
                    plot(dMeasures(:,i), 'Color', SPref.dCOLORMAP(i - 1,:));
                end
                legend(csName{2:end}); % Show legend
                set(SState.hEvalFigure, 'Name', 'Time Series');
                set(get(hAEval, 'XLabel'), 'String', 'Time Point');
                set(get(hAEval, 'YLabel'), 'String', 'Value');
            else
                for i = 1:length(cData);
                    plot(cData{i}, 'Color', SPref.dCOLORMAP(i,:));
                end
                legend(csSeriesName); % Show legend
                set(SState.hEvalFigure, 'Name', 'Line Profile');
                set(get(hAEval, 'XLabel'), 'String', sprintf('x [%s]', SData(SState.iStartSeries).sUnits));
                set(get(hAEval, 'YLabel'), 'String', 'Intensity');
            end
            
        end
        fFillPanels;
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Export to file if enabled
        if isempty(SState.sEvalFilename), return, end
        
        iPos = fGetEvalFilePos;
        if iPos < 0
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % File does not exist -> Write header
            fid = fopen(SState.sEvalFilename, 'w');
            if fid < 0, warning('IMAGINE: Cannot write to file ''%s''!', SState.sEvalFilename); return, end

            if fIsOn('clock')
                fprintf(fid, '\n'); % First line (series names) empty
                fprintf(fid, ['"";"";', fPrintCell('"%s";', csName), '\n']); % The eval function names
                fprintf(fid, ['"";"";', fPrintCell('"%s";', csUnitString), '\n']); % The eval function names
            else
                sFormatString = ['"%s";', repmat('"";', [1, length(csName) - 1])];
                fprintf(fid, ['"";"";', fPrintCell(sFormatString, csSeriesName), '\n']);
                fprintf(fid, ['"";"";', fPrintCell('"%s";', repmat(csName, [1, length(csSeriesName)])), '\n']); % The eval function names
                fprintf(fid, ['"";"";', fPrintCell('"%s";', repmat(csUnitString, [1, length(csSeriesName)])), '\n']); % The eval function names
            end
            
            fclose(fid);
            fprintf('Created file ''%s''!\n', SState.sEvalFilename);
            iPos = 0;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        end

        % ----------------------------------------------------------------
        % Write the measurements to file
        fid = fopen(SState.sEvalFilename, 'a');
        if fid < 0, warning('IMAGINE: Cannot write to file ''%s''!', SState.sEvalFilename); return, end

        iPos = iPos + 1;
        if fIsOn('clock')
            fprintf(fid, '\n');
            for i = 1:length(csSeriesName)
                fprintf(fid, '"%d";"%s";', iPos, csSeriesName{i});
                if SPref.lGERMANEXPORT
                    for iJ = 1:size(dMeasures, 2), fprintf(fid, '"%s";', strrep(num2str(dMeasures(i, iJ)), '.', ',')); end
                else
                    for iJ = 1:size(dMeasures, 2), fprintf(fid, '"%s";', num2str(dMeasures(i, iJ))); end
                end
                fprintf(fid, '\n');
            end
        else
            fprintf(fid, '"%d";"";', iPos);
            dMeasures = dMeasures';
            dMeasures = dMeasures(:);
            if SPref.lGERMANEXPORT
                for i = 1:length(dMeasures), fprintf(fid, '"%s";', strrep(num2str(dMeasures(i)), '.', ',')); end
            else
                for i = 1:length(dMeasures), fprintf(fid, '"%s";', num2str(dMeasures(i))); end
            end
            fprintf(fid, '\n');
        end

        fclose(fid);
        fprintf('Written to position %d in file ''%s''!\n', iPos, SState.sEvalFilename);
        % -----------------------------------------------------------------
        
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fEval
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    function sString = fPrintCell(sFormatString, csCell)
        sString = '';
        for i = 1:length(csCell);
            sString = sprintf(['%s', sFormatString], sString, csCell{i});
        end
    end
    
	function iPos = fGetEvalFilePos
        iPos = -1;
        if ~exist(SState.sEvalFilename, 'file'), return, end

        fid = fopen(SState.sEvalFilename, 'r');
        if fid < 0, return, end

        iPos = 0; i = 1;
        sLine = fgets(fid);
        while ischar(sLine)
            csText{i} = sLine;
            sLine = fgets(fid);
            i = 1 + 1;
        end
        fclose(fid);

        csPos = textscan(csText{end}, '"%d"');
        if ~isempty(csPos{1}), iPos = csPos{1}; end
    end



    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fChangeImage (nested in imagine)
    % * *
    % * * Change image index of all series (if linked) or all selected
    % * * series.
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fChangeImage(hObject, iCnt)
        % -----------------------------------------------------------------
        % Return if projection image selected or ROI drawing in progress
        % if strcmp(SState.sDrawMode, 'max') || strcmp(SState.sDrawMode, 'min') || SState.iROIState, return, end
        if SState.iROIState, return, end
        % -----------------------------------------------------------------
        
        if isstruct(iCnt), iCnt = iCnt.VerticalScrollCount; end % Origin is mouse wheel
        if isobject(iCnt), iCnt = iCnt.VerticalScrollCount; end % Origin is mouse wheel, R2014b
        % -----------------------------------------------------------------
        % Loop over all data (visible or not)
        for iSeriesInd = 1:length(SData)
            if (~fIsOn('link')) && (~SData(iSeriesInd).lActive), continue, end % Skip if axes not linked and current figure not active
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Calculate new image index and make sure it's not out of bounds
            iNewImgInd = SData(iSeriesInd).iActiveImage + iCnt;
            iNewImgInd = max([iNewImgInd, 1]);
            iNewImgInd = min([iNewImgInd, size(SData(iSeriesInd).dImg, 3)]);
            SData(iSeriesInd).iActiveImage = iNewImgInd;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Update corresponding axes if necessary (visible)
            iAxisInd = iSeriesInd - SState.iStartSeries + 1;
            if (iAxisInd) > 0 && (iAxisInd <= length(SAxes.hImg))         % Update Corresponding Axis
                set(STexts.hImg2(iAxisInd), 'String', sprintf('%u/%u', iNewImgInd, size(SData(iSeriesInd).dImg, 3)));
            end
        end
        fFillPanels;
%         fWindowMouseHoverFcn(hObject, []); % Update the cursor value
        % -----------------------------------------------------------------
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fChangeImage
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fSaveToFiles (nested in imagine)
    % * * 
    % * * Save image data of selected panels to file(s)
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fSaveToFiles(sFilename, sPath)
        
        set(hF, 'Pointer', 'watch'); drawnow
        
        
        [~, ~, sExt] = fileparts(sFilename);
        if strcmp(sExt, '.gif')
            
            iImg = zeros([size(SData(1).dImg(:,:,1)), 1, length(SData)], 'uint8');
            
            for i = 1:length(SData)
                
                if strcmp(SState.sDrawMode, 'phase')
                    dMin = -pi; dMax = pi;
                else
                    dMin = SData(1).dWindowCenter - 0.5.*SData(1).dWindowWidth;
                    dMax = SData(1).dWindowCenter + 0.5.*SData(1).dWindowWidth;
                end
                
                if ~fIsOn('link1') && ~strcmp(SState.sDrawMode, 'phase')
                    dMin = SData(i).dWindowCenter - 0.5.*SData(i).dWindowWidth;
                    dMax = SData(i).dWindowCenter + 0.5.*SData(i).dWindowWidth;
                end
                dImg = fGetImg(i);
                dImg = dImg - dMin;
                dImg = round(dImg./(dMax - dMin).*(SAp.iCOLORMAPLENGTH - 1)) + 1;
                dImg(dImg < 1) = 1;
                dImg(dImg > SAp.iCOLORMAPLENGTH) = SAp.iCOLORMAPLENGTH;
                dImg = reshape(SState.dColormapBack(dImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
                iImg(:,:,1,i) = uint8(dImg(:,:,1).*255);
            end
            imwrite(iImg, [sPath, sFilename], 'LoopCount', Inf, 'DelayTime', 0.05);
            
        else
            iNSeries = fGetNVisibleSeries;
            dMin = SData(SState.iStartSeries).dWindowCenter - 0.5.*SData(SState.iStartSeries).dWindowWidth;
            dMax = SData(SState.iStartSeries).dWindowCenter + 0.5.*SData(SState.iStartSeries).dWindowWidth;
            for i = 1:iNSeries
                iSeriesInd = i + SState.iStartSeries - 1;
                if ~fIsOn('link1')
                    dMin = SData(iSeriesInd).dWindowCenter - 0.5.*SData(iSeriesInd).dWindowWidth;
                    dMax = SData(iSeriesInd).dWindowCenter + 0.5.*SData(iSeriesInd).dWindowWidth;
                end
                if strcmp(SState.sDrawMode, 'phase')
                    dMin = -pi;
                    dMax =  pi;
                end
                switch SState.sDrawMode
                    case {'mag', 'phase'}
                        dImg = zeros(size(SData(iSeriesInd).dImg));
                        for iJ = 1:size(SData(iSeriesInd).dImg, 3);
                            dImg(:,:,iJ) = fGetImg(iSeriesInd, iJ);
                        end
                    case {'min', 'max'}
                        dImg = fGetImg(iSeriesInd);
                end
                dImg = dImg - dMin;
                iImg = round(dImg./(dMax - dMin).*(SAp.iCOLORMAPLENGTH - 1)) + 1;
                iImg(iImg < 1) = 1;
                iImg(iImg > SAp.iCOLORMAPLENGTH) = SAp.iCOLORMAPLENGTH;
                dImg = reshape(SState.dColormapBack(iImg, :), [size(iImg, 1), size(iImg, 2), size(iImg, 3), 3]);
                dImg = permute(dImg, [1 2 4 3]); % rgb mode
                dImg = dImg.*255;
                dImg(dImg < 0) = 0;
                dImg(dImg > 255) = 255;
                sSeriesFilename = strrep(sFilename, '%SeriesName%', SData(iSeriesInd).sName);
                switch SState.sDrawMode
                    case {'mag', 'phase'}
                        hW = waitbar(0, sprintf('Saving Stack ''%s''', SData(iSeriesInd).sName));
                        for iImgInd = 1:size(dImg, 4)
                            sImgFilename = strrep(sSeriesFilename, '%ImageNumber%', sprintf('%03u', iImgInd));
                            imwrite(uint8(dImg(:,:,:,iImgInd)), [sPath, filesep, sImgFilename]);
                            waitbar(iImgInd./size(dImg, 4), hW); drawnow;
                        end
                        close(hW);
                    case {'max', 'min'}
                        sImgFilename = strrep(sSeriesFilename, '%ImageNumber%', sprintf('%sProjection', SState.sDrawMode));
                        imwrite(uint8(dImg), [sPath, filesep, sImgFilename]);
                end
                
            end
        end
        set(hF, 'Pointer', 'arrow');
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fSaveToFiles
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fSaveToFiles (nested in imagine)
    % * * 
    % * * Save image data of selected panels to file(s)
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fSaveMaskToFiles(sFilename, sPath)

        set(hF, 'Pointer', 'watch'); drawnow expose
        iNSeries = fGetNVisibleSeries;
        for i = 1:iNSeries
            iSeriesInd = i + SState.iStartSeries - 1;
            lImg = SData(iSeriesInd).lMask;
            if isempty(lImg), continue, end
            
            lMask = max(max(lImg, [], 1), [], 2);
            dImg = double(lImg);
            switch nnz(lMask)
                case 0, continue % no mask
                    
                case 1 % its a 2D mask
                    iInd = find(lMask);
                    sSeriesFilename = strrep(sFilename, '%SeriesName%', SData(iSeriesInd).sName);
                    sImgFilename = strrep(sSeriesFilename, '%ImageNumber%', sprintf('%03d', iInd));
                    imwrite(dImg(:,:,iInd), [sPath, filesep, sImgFilename]);
                otherwise
                    sSeriesFilename = strrep(sFilename, '%SeriesName%', SData(iSeriesInd).sName);
                    for iInd = 1:size(dImg, 3)
                        sImgFilename = strrep(sSeriesFilename, '%ImageNumber%', sprintf('%03d', iInd));
                        imwrite(dImg(:,:,iInd), [sPath, filesep, sImgFilename]);
                    end
            end
        end
        set(hF, 'Pointer', 'arrow');
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fSaveToFiles
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fGetImg (nested in imagine)
    % * *
    % * * Return data for view according to drawmode
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function dImg = fGetImg(iInd, iImgInd)
        if nargin < 2, iImgInd = SData(iInd).iActiveImage; end
        
        if strcmp(SState.sDrawMode, 'phase')
            dImg = angle(SData(iInd).dImg(:,:,iImgInd));
            return
        end
        
        dImg = SData(iInd).dImg;
        if ~isreal(dImg), dImg = abs(dImg); end
        
        switch SState.sDrawMode
            case 'mag', dImg = dImg(:,:,iImgInd);
            case 'max'
                iMin = max(1, iImgInd - 3);
                iMax = min(size(dImg, 3), iImgInd + 3);
                dImg = max(dImg(:,:,iMin:iMax), [], 3);
            case 'min', dImg = min(dImg, [], 3);
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fGetImg
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    function fSetWindow(hObject, eventdata)
        iAxisInd = find(SImg.hColorbar == hObject);
        iSeriesInd = iAxisInd + SState.iStartSeries - 1;
        if iSeriesInd > length(SData), return, end
        
        dMin = SData(iSeriesInd).dWindowCenter - 0.5.*SData(iSeriesInd).dWindowWidth;
        dMax = SData(iSeriesInd).dWindowCenter + 0.5.*SData(iSeriesInd).dWindowWidth;
        csVal{1} = fPrintNumber(dMin);
        csVal{2} = fPrintNumber(dMax);
        csAns = inputdlg({'Min', 'Max'}, sprintf('Change %s windowing', SData(iSeriesInd).sName), 1, csVal);
        if isempty(csAns), return, end
        
        csVal = textscan([csAns{1}, ' ', csAns{2}], '%f %f');
        if ~isempty(csVal{1}), dMin = csVal{1}; end
        if ~isempty(csVal{2}), dMax = csVal{2}; end
        SData(iSeriesInd).dWindowCenter = (dMin + dMax)./2;
        SData(iSeriesInd).dWindowWidth  = (dMax - dMin);
        fFillPanels;
    end
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fUpdateActivation (nested in imagine)
    % * *
    % * * Set the activation and availability of some switches according to
    % * * the GUI state.
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fUpdateActivation

        % -----------------------------------------------------------------
        % Update states of some menubar buttons according to panel selection
        csLabels = {SIcons.Name};
        SIcons(strcmp(csLabels, 'save'))      .Enabled = fGetNActiveVisibleSeries() > 0;
        SIcons(strcmp(csLabels, 'doc_delete')).Enabled = fGetNActiveVisibleSeries() > 0;
        SIcons(strcmp(csLabels, 'exchange'))  .Enabled = fGetNActiveVisibleSeries() == 2;
        SIcons(strcmp(csLabels, 'record'))    .Enabled = isempty(SState.sEvalFilename);
        SIcons(strcmp(csLabels, 'stop'))      .Enabled = ~isempty(SState.sEvalFilename);
        SIcons(strcmp(csLabels, 'rewind'))    .Enabled = ~isempty(SState.sEvalFilename);
        % -----------------------------------------------------------------
        
        SIcons(strcmp(csLabels, 'lw')).Enabled = exist('fLiveWireCalcP') == 3; % Compiled mex file
        SIcons(strcmp(csLabels, 'rg')).Enabled = exist('fRegionGrowingAuto_mex') == 3; % Compiled mex file
        SIcons(strcmp(csLabels, 'ic')).Enabled = exist('fIsoContour_mex') == 3; % Compiled mex file

        % -----------------------------------------------------------------
        % Treat the menubar items
        dScale = ones(length(SIcons));
        dScale(~[SIcons.Enabled]) = SAp.iDISABLED_SCALE;
        dScale( [SIcons.Enabled] & ~[SIcons.Active]) = SAp.iINACTIVE_SCALE;
        for i = 1:length(SIcons), set(SImg.hIcons(i), 'CData', SIcons(i).dImg.*dScale(i)); end
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % Treat the panels
        for i = 1:length(SAxes.hImg)
            iSeriesInd = i + SState.iStartSeries - 1;
            if iSeriesInd > length(SData) || ~SData(iSeriesInd).lActive
                set(STexts.hImg1(i), 'FontWeight', 'normal');
            else
                set(STexts.hImg1(i), 'FontWeight', 'bold');
            end
        end
        % -----------------------------------------------------------------
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fUpdateActivation
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fGetNActiveVisibleSeries (nested in imagine)
    % * *
    % * * Returns the number of visible active series.
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function iNActiveSeries = fGetNActiveVisibleSeries()
        iNActiveSeries = 0;
        if isempty(SData), return, end
        
        iStartInd = SState.iStartSeries;
        iEndInd = min([iStartInd + length(SAxes.hImg) - 1, length(SData)]);
        iNActiveSeries = nnz([SData(iStartInd:iEndInd).lActive]);
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fGetNActiveVisibleSeries
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fGetNVisibleSeries (nested in imagine)
    % * *
    % * * Returns the number of visible active series.
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function iNVisibleSeries = fGetNVisibleSeries()
        if isempty(SData)
            iNVisibleSeries = 0;
        else
            iNVisibleSeries = min([length(SAxes.hImgFrame), length(SData) - SState.iStartSeries + 1]);
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fGetNVisibleSeries
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fParseInputs (nested in imagine)
    % * *
    % * * Parse the varargin input variable. It can be either pairs of
    % * * data/captions or just data. Data can be either 2D, 3D or 4D.
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fParseInputs(cInput)        
        
        iInd = 1;
        iDataInd = 0;
        
%         xInput = cInput{iInd};
%         if ~(isnumeric(xInput) || islogical(xInput)), error('First input must be image data of some kind!'); end
        
%         iDataInd = iDataInd + 1;
%         dImg = xInput;
%         sName = sprintf('Input_%02d', iDataInd);
%         dDim = [1 1 1];
%         sUnits = 'px';
%         dWindow = [];
%         lMask = [];
%         iInd = iInd + 1;
        
        while iInd <= length(cInput);
            xInput = cInput{iInd};
            if ~(isnumeric(xInput) || islogical(xInput) || iscell(xInput) || ischar(xInput)), error('Argument %d expected to be either property or data!', iInd); end

            if isnumeric(xInput) || islogical(xInput) || iscell(xInput)% New image data
                if iDataInd, fAddImageToData(dImg, sName, 'startup', dDim, sUnits, dWindow, lMask, dZoom); end% Add the last Dataset
                iDataInd = iDataInd + 1;
                sName = sprintf('Input_%02d', iDataInd);
                dDim = [1 1 1];
                dZoom = 1;
                sUnits = 'px';
                dWindow = [];
                lMask = [];
                if iscell(xInput)
                    iNDims = ndims(xInput{1});
                    xInput = xInput(:);
                    xInput = shiftdim(xInput, -iNDims);
                    dImg = cell2mat(xInput);
                else
                    dImg = xInput;
                end
            end
            
            if ischar(xInput)
                iInd = iInd + 1;
                if iInd > length(cInput), error('Argument %d (property) must be followed by a value!', iInd - 1); end
                
                xVal = cInput{iInd};
                switch lower(xInput)
                    case {'n', 'name'}
                        if ~ischar(xVal), error('Name property must be a string!'); end
                        sName = xVal;
                    case {'v', 'voxelsize'}
                        if ~isnumeric(xVal) || numel(xVal) ~= 3, error('Voxelsize property must be a [3x1] or [1x3] numeric vector!'); end
                        dDim = xVal;
                    case {'z', 'zoom'}
                        if ~isnumeric(xVal), error('Zoom property must be a numeric scalar!'); end
                        dZoom = xVal;
                    case {'u', 'units'}
                        if ~ischar(xVal), error('Units property must be a string!'); end
                        sUnits = xVal;
                    case {'w', 'window'}
                        if ~isnumeric(xVal) || numel(xVal) ~= 2, error('Window limits property must be a [2x1] or [1x2] numeric vector!'); end
                        dWindow = xVal;
                    case {'m', 'mask'}
                        if ndims(xVal) ~= ndims(dImg), error('Mask must have same number of dimensions as the image!'); end
                        if any(size(dImg) ~= size(xVal)), error('Mask must have same size as image'); end
                        lMask = xVal;
                    case {'p', 'panels'}
                        if ~isnumeric(xVal) || numel(xVal) ~= 2, error('Panel size must be a [2x1] or [1x2] numeric vector!'); end
                        SState.iPanels = xVal(:)';
                    otherwise, error('Unknown property ''%s''!', xInput);
                end
                    
            end
            iInd = iInd + 1;
        end
        if iDataInd, fAddImageToData(dImg, sName, 'startup', dDim, sUnits, dWindow, lMask, dZoom); end

        if sum(SState.iPanels) == 0
            iNumImages = length(SData);
            dRoot = sqrt(iNumImages);
            iPanelsN = ceil(dRoot);
            iPanelsM = ceil(dRoot);
            while iPanelsN*iPanelsM >= iNumImages
                iPanelsN = iPanelsN - 1;
            end
            iPanelsN = iPanelsN + 1;
            iPanelsN = min([4, iPanelsN]);
            iPanelsM = min([4, iPanelsM]);
            SState.iPanels = [iPanelsN, iPanelsM];
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fParseInputs
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fLoadFiles (nested in imagine)
    % * * 
    % * * Load image files from disk and sort into series.
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =    
    function fLoadFiles(csFilenames)
        if ~iscell(csFilenames), csFilenames = {csFilenames}; end % If only one file
        lLoaded = false(length(csFilenames), 1);
        
        SImageData = [];
        hW = waitbar(0, 'Loading files');
        for i = 1:length(csFilenames)
            [sPath, sName, sExt] = fileparts(csFilenames{i}); %#ok<ASGLU>
            switch lower(sExt)
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Standard image data: Try to group according to size
                case {'.jpg', '.jpeg', '.tif', '.tiff', '.gif', '.bmp', '.png'}
                    try
                        dImg = double(imread([SState.sPath, csFilenames{i}]))./255;
                        lLoaded(i) = true;
                    catch %#ok<CTCH>
                        disp(['Error when loading "', SState.sPath, csFilenames{i}, '": File extenstion and type do not match']);
                        continue;
                    end
                    dImg = mean(dImg, 3);
                    iInd = fServesSizeCriterion(size(dImg), SImageData);
                    if iInd
                        dImg = cat(3, SImageData(iInd).dImg, dImg);
                        SImageData(iInd).dImg = dImg;
                    else
                        iLength = length(SImageData) + 1;
                        SImageData(iLength).dImg = dImg;
                        SImageData(iLength).sOrigin = 'Image File';
                        SImageData(iLength).sName = csFilenames{i};
                        SImageData(iLength).dPixelSpacing = [1 1 1];
                    end
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % NifTy Data
                case '.nii'
                    set(hF, 'Pointer', 'watch'); drawnow;
                    [dImg, dDim] = fNifTyRead([SState.sPath, csFilenames{i}]);
                    if ndims(dImg) > 4, error('Only 4D data supported'); end
                    lLoaded(i) = true;
                    fAddImageToData(dImg, csFilenames{i}, 'NifTy File', dDim, 'mm');
                    set(hF, 'Pointer', 'arrow');
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                    
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                case '.gipl'
                    set(hF, 'Pointer', 'watch'); drawnow;
                    [dImg, dDim] = fGIPLRead([SState.sPath, csFilenames{i}]);
                    lLoaded(i) = true;
                    fAddImageToData(dImg, csFilenames{i}, 'GIPL File', dDim, 'mm');
                    set(hF, 'Pointer', 'arrow');
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                case '.mat'
                    csVars = fMatRead([SState.sPath, csFilenames{i}]);
                    lLoaded(i) = true;
                    if isempty(csVars), continue, end   % Dialog aborted
                    
                    set(hF, 'Pointer', 'watch'); drawnow;
                    for iJ = 1:length(csVars)
                        S = load([SState.sPath, csFilenames{i}], csVars{iJ});
                        eval(['dImg = S.', csVars{iJ}, ';']);
                        fAddImageToData(dImg, sprintf('%s in %s', csVars{iJ}, csFilenames{i}), 'MAT File');
                    end
                    set(hF, 'Pointer', 'arrow');
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            end
            waitbar(i/length(csFilenames), hW);
        end
        close(hW);
        
        for i = 1:length(SImageData)
            fAddImageToData(SImageData(i).dImg, SImageData.sName, 'Image File', [1 1 1]);
        end
        
        set(hF, 'Pointer', 'watch'); drawnow;
        SDicomData = fDICOMRead(csFilenames(~lLoaded), SState.sPath);
        for i = 1:length(SDicomData)
            fAddImageToData(SDicomData(i).dImg, SDicomData(i).SeriesDescriptions, 'DICOM', SDicomData(i).Aspect, 'mm');
        end
        set(hF, 'Pointer', 'arrow');
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fLoadFiles
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fAddImageToData (nested in imagine)
    % * *
    % * * Add image data to the global SDATA variable. Can handle 2D, 3D or
    % * * 4D data.
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fAddImageToData(dImage, sName, sOrigin, dDim, sUnits, dWindow, lMask, dZoom)
        if nargin < 8, dZoom = 1; end
        if nargin < 7, lMask = []; end
        if nargin < 6, dWindow = []; end
        if nargin < 5, sUnits = 'px'; end
        if nargin < 4, dDim = [1 1 1]; end
        if islogical(dImage), dImage = ones(size(dImage)).*dImage; end
        dImage = double(dImage);
        dImage(isnan(dImage)) = 0;
        iInd = length(SData) + 1;
        
        iGroupIndex = 1;
        if ~isempty(SData)
            iExistingGroups = unique([SData.iGroupIndex]);
            if ~isempty(iExistingGroups)
                while nnz(iExistingGroups == iGroupIndex), iGroupIndex = iGroupIndex + 1; end
            end
        end
       
        if size(dImage, 3) == 3
            SData(iInd).dImg = dImage;
            if ~isempty(dWindow)
                dMin = dWindow(1);
                dMax = dWindow(2);
            else
                if isreal(SData(iInd).dImg)
                    if numel(SData(iInd).dImg) > 1E6
                        dMin = min(SData(iInd).dImg(1:100:end));
                        dMax = max(SData(iInd).dImg(1:100:end));
                    else
                        dMin = min(SData(iInd).dImg(:));
                        dMax = max(SData(iInd).dImg(:));
                    end
                else
                    if numel(SData(iInd).dImg) > 1E6
                        dMin = min(abs(SData(iInd).dImg(1:100:end)));
                        dMax = max(abs(SData(iInd).dImg(1:100:end)));
                    else
                        dMin = min(abs(SData(iInd).dImg(:)));
                        dMax = max(abs(SData(iInd).dImg(:)));
                    end
                end
            end
            if dMax == dMin, dMax = dMin + 1; end
            SData(iInd).dDynamicRange = [dMin, dMax];
            SData(iInd).sOrigin = sOrigin;
            SData(iInd).dWindowCenter = (dMax + dMin)./2;
            SData(iInd).dWindowWidth  = dMax - dMin;
            SData(iInd).dZoomFactor = dZoom;
            SData(iInd).dDrawCenter = [size(SData(iInd).dImg, 1), size(SData(iInd).dImg, 2)]/2;
            SData(iInd).iActiveImage = max(1, round(size(SData(iInd).dImg, 3)/2));
            SData(iInd).lActive = false;
            if dDim(end) == 0, dDim(end) = min(dDim(1:2)); end
            SData(iInd).dPixelSpacing = dDim(:)';
            SData(iInd).sUnits = sUnits;
            SData(iInd).lMask = [];
            SData(iInd).iGroupIndex = iGroupIndex;
            SData(iInd).sEvalText = '';
            SData(iInd).sName = sName;
            iInd = iInd + 1;
        else
            
            for i = 1:size(dImage, 4)
                SData(iInd).dImg = dImage(:,:,:,i);
                if ~isempty(dWindow)
                    dMin = dWindow(1);
                    dMax = dWindow(2);
                else
                    if isreal(SData(iInd).dImg)
                    if numel(SData(iInd).dImg) > 1E6
                        dMin = min(SData(iInd).dImg(1:100:end));
                        dMax = max(SData(iInd).dImg(1:100:end));
                    else
                        dMin = min(SData(iInd).dImg(:));
                        dMax = max(SData(iInd).dImg(:));
                    end
                else
                    if numel(SData(iInd).dImg) > 1E6
                        dMin = min(abs(SData(iInd).dImg(1:100:end)));
                        dMax = max(abs(SData(iInd).dImg(1:100:end)));
                    else
                        dMin = min(abs(SData(iInd).dImg(:)));
                        dMax = max(abs(SData(iInd).dImg(:)));
                    end
                end
                end
                if dMax == dMin, dMax = dMin + 1; end
                SData(iInd).dDynamicRange = [dMin, dMax];
                SData(iInd).sOrigin = sOrigin;
                SData(iInd).dWindowCenter = (dMax + dMin)./2;
                SData(iInd).dWindowWidth  = dMax - dMin;
                SData(iInd).dZoomFactor = dZoom;
                SData(iInd).dDrawCenter = [size(SData(iInd).dImg, 1), size(SData(iInd).dImg, 2)]/2;
                SData(iInd).iActiveImage = max(1, round(size(SData(iInd).dImg, 3)/2));
                SData(iInd).lActive = false;
                if dDim(end) == 0, dDim(end) = min(dDim(1:2)); end
                SData(iInd).dPixelSpacing = dDim(:)';
                SData(iInd).sUnits = sUnits;
                if isempty(lMask)
                    SData(iInd).lMask = [];
                else
                    SData(iInd).lMask = lMask(:,:,:,i);
                end
                SData(iInd).iGroupIndex = iGroupIndex;
                SData(iInd).sEvalText = '';
                if ndims(dImage) > 3
                    SData(iInd).sName = sprintf('%s_%02u', sName, i);
                else
                    SData(iInd).sName = sName;
                end
                iInd = iInd + 1;
            end
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fAddImageToData
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    

    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fGetPanel (nested in imagine)
    % * *
    % * * Determine the panelnumber under the mouse cursor. Returns 0 if
    % * * not over a panel at all.
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function iPanelInd = fGetPanel()
        iCursorPos = get(hF, 'CurrentPoint');
        iPanelInd = uint8(0);
        for i = 1:min([length(SAxes.hImg), length(SData) - SState.iStartSeries + 1])
            dPos = get(SAxes.hImg(i), 'Position');
            if ((iCursorPos(1) >= dPos(1)) && (iCursorPos(1) < dPos(1) + dPos(3)) && ...
                    (iCursorPos(2) >= dPos(2) + SAp.iEVALBARHEIGHT) && (iCursorPos(2) < dPos(2) + dPos(4) - SAp.iTITLEBARHEIGHT - SAp.iCOLORBARHEIGHT))
                iPanelInd = uint8(i);
            end
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fGetPanel
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fServesSizeCriterion (nested in imagine)
    % * *
    % * * Determines, whether the data structure contains an image series
    % * * with the same x- and y-dimensions as iSize
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function iInd = fServesSizeCriterion(iSize, SNewData)
        iInd = 0;
        for i = 1:length(SNewData)
            if (iSize(1) == size(SNewData(i).dImg, 1)) && ...
                    (iSize(2) == size(SNewData(i).dImg, 2))
                iInd = i;
                return;
            end
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fServesSizeCriterion
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

       
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fIsOn (nested in imagine)
    % * *
    % * * Determine whether togglebutton is active
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function lOn = fIsOn(sTag)
        lOn = SIcons(strcmp({SIcons.Name}, sTag)).Active;
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fIsOn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION SDataOut (nested in imagine)
    % * *
    % * * Thomas' hack function to get the data structure
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function SDataOut = fGetData
        SDataOut = SData;
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION SDataOut
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fPrintNumber (nested in imagine3D)
    % * *
    % * * Display a value in adequate format
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function sString = fPrintNumber(xNumber)
        if ((abs(xNumber) < 0.01) && (xNumber ~= 0)) || (abs(xNumber) > 1E4)
            sString = sprintf('%2.1E', xNumber);
        else
            sString = sprintf('%4.2f', xNumber);
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fPrintNumber
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fReplicate (nested in imagine)
    % * * 
    % * * Scale image by power of 2 by nearest neighbour interpolation
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function dImgOut = fReplicate(dImg, iIter)
        dImgOut = zeros(2.*size(dImg));
        dImgOut(1:2:end, 1:2:end) = dImg;
        dImgOut(2:2:end, 1:2:end) = dImg;
        dImgOut(1:2:end, 2:2:end) = dImg;
        dImgOut(2:2:end, 2:2:end) = dImg;
        iIter = iIter - 1;
        if iIter > 0, dImgOut = fReplicate(dImgOut, iIter); end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fReplicate
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * NESTED FUNCTION fCompileMex (nested in imagine)
    % * * 
    % * * Scale image by power of 2 by nearest neighbour interpolation
    % * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fCompileMex
        fprintf('Imagine will try to compile some mex files!\n');
        sToolsPath = [SPref.sMFILEPATH, filesep, 'tools'];
        S = dir([sToolsPath, filesep, '*.cpp']);
        sPath = cd;
        cd(sToolsPath);
        lSucc = true;
        for i = 1:length(S)
            [temp, sName] = fileparts(S(i).name); %#ok<ASGLU>
            if exist(sName, 'file') == 3, continue, end
            try
                eval(['mex ', S(i).name]);
            catch
                warning('Could nor compile ''%s''!', S(i).name);
                lSucc = false;
            end
        end
        cd(sPath);
        if ~lSucc
            warndlg(sprintf('Not all mex files could be compiled, thus some tools will not be available. Try to setup the mex-compiler using ''mex -setup'' and compile the *.cpp files in the ''tools'' folder manually.'), 'IMAGINE');
        else
            fprintf('Hey, it worked!\n');
        end
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fCompileMex
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
    
    function dOut = fBlend(dBot, dTop, sMode, dAlpha)
        
        % -------------------------------------------------------------------------
        % Parse the inputs
        if nargin < 4, dAlpha = 1.0; end % Top is fully opaque
        if nargin < 3, sMode = 'overlay'; end
        if nargin < 2, error('At least 2 input arguments required!'); end
        if isa(dBot, 'uint8')
            dBot = double(dBot);
            dBot = dBot./255;
        end
        if isa(dTop, 'uint8')
            dTop = double(dTop);
            dTop = dTop./255;
        end
        % -------------------------------------------------------------------------
        
        % Check Inputs
        if numel(dTop) == 3
            %     if isscalar(dAlpha), error('If top layer is given as a color, alpha map must be supplied!'); end
            dTop = repmat(permute(dTop(:), [3 2 1]), [size(dAlpha) 1]);
        end
        dTopSize = [size(dTop, 1), size(dTop, 2), size(dTop, 3), size(dTop, 4)];
        
        
        % Check if background is monochrome
        if numel(dBot) == 1 % grayscale background
            dBot = dBot.*ones(dTopSize);
        end
        if numel(dBot) == 3 % rgb background color
            dBot = repmat(permute(dBot(:), [2 3 1]), [dTopSize(1), dTopSize(2), 1, dTopSize(4)]);
        end
        
        dBotSize = [size(dBot, 1), size(dBot, 2), size(dBot, 3), size(dBot, 4)];
        if dBotSize(3) ~= 1 && dBotSize(3) ~= 3, error('Bottom layer must be either grayscale or RGB!'); end
        if dTopSize(3) > 4, error('Size of 3rd top layer dimension must not exceed 4!'); end
        if any(dBotSize(1, 2) ~= dTopSize(1, 2)), error('Size of image data does not match'); end
        
        if dBotSize(4) ~= dTopSize(4)
            if dBotSize(4) > 1 && dTopSize(4) > 1, error('4th dimension of image data mismatch!'); end
            
            if dBotSize(4) == 1, dBot = repmat(dBot, [1, 1, 1, dTopSize(4)]); end
            if dTopSize(4) == 1, dTop = repmat(dTop, [1, 1, 1, dBotSize(4)]); end
        end
        
        %% Handle the alpha map
        if dTopSize(3) == 2 || dTopSize(3) == 4 % Alpha channel included
            dAlpha = dTop(:,:,end, :);
            dTop   = dTop(:,:,1:end-1,:);
        else
            if isscalar(dAlpha)
                dAlpha = dAlpha.*ones(dTopSize(1), dTopSize(2), 1, dTopSize(4));
            else
                dAlphaSize = [size(dAlpha, 1), size(dAlpha, 2), size(dAlpha, 3), size(dAlpha, 4)];
                if any(dAlphaSize(1:2) ~= dTopSize(1:2)), error('Top layer alpha map dimension mismatch!'); end
                if dAlphaSize(3) > 1, error('3rd dimension of alpha map must have size 1!'); end
                if dAlphaSize(4) > 1
                    if dAlphaSize(4) ~= dTopSize(4), error('Alpha map dimension mismatch!'); end
                else
                    dAlpha = repmat(dAlpha, [1, 1, 1, dTopSize(4)]);
                end
            end
        end
        
        % Bring data into the right format
        dMaxDim = max([size(dBot, 3), size(dTop, 3)]);
        if dMaxDim > 2, lRGB = true; else lRGB = false; end
        
        if lRGB && dBotSize(3) == 1, dBot = repmat(dBot, [1, 1, 3, 1]); end
        if lRGB && dTopSize(3) == 1, dTop = repmat(dTop, [1, 1, 3, 1]); end
        if lRGB, dAlpha = repmat(dAlpha, [1, 1, 3, 1]); end
        
        % Check Range
        dBot = fCheckRange(dBot);
        dTop = fCheckRange(dTop);
        dAlpha = fCheckRange(dAlpha);
        
        % Do the blending
        switch lower(sMode)
            case 'normal',      dOut = dTop;
            case 'multiply',    dOut = dBot.*dTop;
            case 'screen',      dOut = 1 - (1 - dBot).*(1 - dTop);
            case 'overlay'
                lMask = dBot < 0.5;
                dOut = 1 - 2.*(1 - dBot).*(1 - dTop);
                dOut(lMask) = 2.*dBot(lMask).*dTop(lMask);
            case 'hard_light'
                lMask = dTop < 0.5;
                dOut = 1 - 2.*(1 - dBot).*(1 - dTop);
                dOut(lMask) = 2.*dBot(lMask).*dTop(lMask);
            case 'soft_light',  dOut = (1 - 2.*dTop).*dBot.^2 + 2.*dTop.*dBot; % pegtop
            case 'darken',      dOut = min(cat(4, dTop, dBot), [], 4);
            case 'lighten',     dOut = max(cat(4, dTop, dBot), [], 4);
            otherwise,          error('Unknown blend mode ''%s''!', sMode);
        end
        dOut = dAlpha.*dOut + (1 - dAlpha).*dBot;
        
        dOut(dOut > 1) = 1;
        dOut(dOut < 0) = 0;
    end

    function dData = fCheckRange(dData)
        dData(dData < 0) = 0;
        dData(dData > 1) = 1;
    end
  
    
end
% =========================================================================
% *** END FUNCTION imagine (and its nested functions)
% =========================================================================




% #########################################################################
% ***
% ***   Helper GUIS and their callbacks
% ***
% #########################################################################


% =========================================================================
% *** FUNCTION fGridSelect
% ***
% *** Creates a tiny GUI to select the GUI layout, i.e. the number of
% *** panels and the grid dimensions.
% ***
% =========================================================================
function iSizeOut = fGridSelect(iM, iN)

iGRIDSIZE = 30;
iSizeOut = [0 0];

% -------------------------------------------------------------------------
% Create a new figure at the current mouse pointer position
iPos = get(0, 'PointerLocation');
hGridFig = figure(...
    'Position'              , [iPos(1), iPos(2) - iGRIDSIZE*iM, iGRIDSIZE*iN, iGRIDSIZE*iM], ...
    'Units'                 , 'pixels', ...
    'DockControls'          , 'off', ...
    'WindowStyle'           , 'modal', ...
    'Name'                  , '', ...
    'WindowButtonMotionFcn' , @fGridMouseMoveFcn, ...
    'WindowButtonDownFcn'   , 'uiresume(gcbf)', ... % continues the execution of this function after the uiwait when the mousebutton is pressed
    'NumberTitle'           , 'off', ...
    'Resize'                , 'off', ...
    'Colormap'              ,  [0.2 0.3 0.4; ...
                                0.3 0.4 0.5], ...
    'Visible'               , 'off');

hA = axes(...
    'Units'     , 'normalized', ...
    'Position'  , [0 0 1 1], ...
    'Parent'    , hGridFig, ...
    'XLim'      , [0 iM] + 0.5, ...
    'YLim'      , [0 iN] + 0.5, ...
    'YDir'      , 'reverse', ...
    'XGrid'     , 'on', ...
    'YGrid'     , 'on', ...
    'Layer'     , 'top', ...
    'XTick'     , (1:iN) + 0.5, ...
    'YTick'     , (1:iM) + 0.5, ...
    'TickLength', [0 0]);

hI = image(...
    'CData'         , zeros(iM, iN, 'uint8'), ...
    'CDataMapping'  , 'direct');

set(hGridFig, 'Visible', 'on');
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Handle GUI interaction
uiwait(hGridFig); % Wait until the uiresume function is called (happens when mouse button is pressed, see creation of the figure above)
try % Button was pressed, return the amount of selected panels
    delete(hGridFig); % close the figure
catch %#ok<CTCH> % if figure could not be deleted (dialog aborted), return [0 0]
    iSizeOut = [0 0];
end
% -------------------------------------------------------------------------


    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fGridMouseMoveFcn (nested in fGridSelect)
    % * *
    % * * Determine whether axes are linked
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fGridMouseMoveFcn(hObject, eventdata)
        dCursorPos = get(hA, 'CurrentPoint');
        iSizeOut = round(dCursorPos(1, 2:-1:1));
        dCData = zeros(iM, iN, 'uint8');
        dCData(1:iSizeOut(1), 1:iSizeOut(2)) = 1;
        set(hI, 'CData', dCData);
        drawnow update
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fGridMouseMoveFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

end
% =========================================================================
% *** END FUNCTION fGridSelect (and its nested functions)
% =========================================================================



% =========================================================================
% *** FUNCTION fColormapSelect
% ***
% *** Creates a tiny GUI to select the colormap.
% ***
% =========================================================================
function sColormap = fColormapSelect(hText)

iWIDTH = 128;
iBARHEIGHT = 32;

% -------------------------------------------------------------------------
% List the MATLAB built-in colormaps
csColormaps = {'gray', 'bone', 'copper', 'pink', 'hot', 'jet', 'hsv', 'cool'};
iNColormaps = length(csColormaps);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Add custom colormaps (if any)
sColormapPath = [fileparts(mfilename('fullpath')), filesep, 'colormaps'];
SDir = dir([sColormapPath, filesep, '*.m']);
for iI = 1:length(SDir)
    iNColormaps = iNColormaps + 1;
    [sPath, sName] = fileparts(SDir(iI).name); %#ok<ASGLU>
    csColormaps{iNColormaps} = sName;
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Create a new figure at the current mouse pointer position
iPos = get(0, 'PointerLocation');
iHeight = iNColormaps.*iBARHEIGHT;
hColormapFig = figure(...
    'Position'             , [iPos(1), iPos(2) - iHeight, iWIDTH, iHeight], ...
    'WindowStyle'          , 'modal', ...
    'Name'                 , '', ...
    'WindowButtonMotionFcn', @fColormapMouseMoveFcn, ...
    'WindowButtonDownFcn'  , 'uiresume(gcbf)', ... % continues the execution of this function after the uiwait when the mousebutton is pressed
    'NumberTitle'          , 'off', ...
    'Resize'               , 'off');
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Make the true-color image with the colormaps
dImg = zeros(iNColormaps, iWIDTH, 3);
dLine = zeros(iWIDTH, 3);
for iI = 1:iNColormaps
    eval(['dLine = ', csColormaps{iI}, '(iWIDTH);']);
    dImg(iI, :, :) = permute(dLine, [3, 1, 2]);
end

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create axes and image for selection
hA = axes(...
    'Units'     , 'pixels', ...
    'Position'  , [1, 1, iWIDTH, iHeight], ...
    'Parent'    , hColormapFig, ...
    'Color'     , 'w', ...
    'XLim'      , [0.5 128.5], ...
    'YLim'      , [0.5 length(csColormaps) + 0.5]);

image(dImg, 'Parent',  hA);

axis(hA, 'off');
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Handle GUI interaction
iLastInd = 0;
uiwait(hColormapFig); % Wait until the uiresume function is called (happens when mouse button is pressed, see creation of the figure above)

try % Button was pressed, return the amount of selected panels
    dPos = get(hA, 'CurrentPoint');
    iInd = round(dPos(1, 2));
    sColormap = csColormaps{iInd};
    delete(hColormapFig); % close the figure
catch %#ok<CTCH> % if figure could not be deleted (dialog aborted), return [0 0]
    sColormap = 'gray';
end
% -------------------------------------------------------------------------


    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fColormapMouseMoveFcn (nested in fColormapSelect)
    % * *
    % * * Determine whether axes are linked
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fColormapMouseMoveFcn(hObject, eventdata)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Determine over which colormap the mouse pointer is located
        dPos = get(hA, 'CurrentPoint');
        iInd = round(dPos(1, 2));
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Update the figure's colormap if desired
        if iInd ~= iLastInd
            set(hText, 'String', csColormaps{iInd});
            iLastInd = iInd;
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fColormapMouseMoveFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

end
% =========================================================================
% *** END FUNCTION fColormapSelect (and its nested functions)
% =========================================================================


% =========================================================================
% *** FUNCTION fSelectEvalFcns
% ***
% *** Lets the user select the eval functions for evaluation
% ***
% =========================================================================
function csFcns = fSelectEvalFcns(csActive, sPath)

iFIGUREWIDTH = 300;
iFIGUREHEIGHT = 400;
iBUTTONHEIGHT = 24;

csFcns = 0;
iPos = get(0, 'ScreenSize');

SDir = dir([sPath, filesep, '*.m']);
lActive = false(length(SDir), 1);
csNames = cell(length(SDir), 1);
for iI = 1:length(SDir)
    csNames{iI} = SDir(iI).name(1:end-2);
    for iJ = 1:length(csActive);
        if strcmp(csNames{iI}, csActive{iJ}), lActive(iI) = true; end
    end
end

% -------------------------------------------------------------------------
% Create figure and GUI elements
hF = figure( ...
    'Position'              , [(iPos(3) - iFIGUREWIDTH)/2, (iPos(4) - iFIGUREHEIGHT)/2, iFIGUREWIDTH, iFIGUREHEIGHT], ...
    'WindowStyle'           , 'modal', ...
    'Name'                  , 'Select Eval Functions...', ...
    'NumberTitle'           , 'off', ...
    'KeyPressFcn'           , @SelectEvalCallback, ...
    'Resize'                , 'off');

hList = uicontrol(hF, ...
    'Style'                 , 'listbox', ...
    'Position'              , [1 iBUTTONHEIGHT + 1 iFIGUREWIDTH iFIGUREHEIGHT - iBUTTONHEIGHT], ...
    'String'                , csNames, ...
    'Min'                   , 0, ...
    'Max'                   , 2, ...
    'Value'                 , find(lActive), ...
    'KeyPressFcn'           , @SelectEvalCallback, ...
    'Callback'              , @SelectEvalCallback);

hButOK = uicontrol(hF, ...
    'Style'                 , 'pushbutton', ...
    'Position'              , [1 1 iFIGUREWIDTH/2 iBUTTONHEIGHT], ...
    'Callback'              , @SelectEvalCallback, ...
    'String'                , 'OK');

uicontrol(hF, ...
    'Style'                 , 'pushbutton', ...
    'Position'              , [iFIGUREWIDTH/2 + 1 1 iFIGUREWIDTH/2 iBUTTONHEIGHT], ...
    'Callback'              , 'uiresume(gcf);', ...
    'String'                , 'Cancel');
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Set default action and enable gui interaction
sAction = 'Cancel';
uiwait(hF);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% uiresume was triggered (in fMouseActionFcn) -> return
if strcmp(sAction, 'OK')
    iList = get(hList, 'Value');
    csFcns = cell(length(iList), 1);
    for iI = 1:length(iList)
        csFcns(iI) = csNames(iList(iI));
    end
end
try %#ok<TRYNC>
    close(hF);
end
% -------------------------------------------------------------------------


    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION SelectEvalCallback (nested in fSelectEvalFcns)
    % * *
    % * * Determine whether axes are linked
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function SelectEvalCallback(hObject, eventdata)
        if isfield(eventdata, 'Key')
            switch eventdata.Key
                case 'escape', uiresume(hF);
                case 'return'
                    sAction = 'OK';
                    uiresume(hF);
            end
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % React on action depending on its source component
        switch(hObject)
            
            case hList
                if strcmp(get(hF, 'SelectionType'), 'open')
                    sAction = 'OK';
                    uiresume(hF);
                end

            case hButOK
                sAction = 'OK';
                uiresume(hF);

            otherwise

        end
        % End of switch statement
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION SelectEvalCallback
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
end
% =========================================================================
% *** END FUNCTION fSelectEvalFcns (and its nested functions)
% =========================================================================
