function varargout = Registration(varargin)
% REGISTRATION MATLAB code for Registration.fig
%      REGISTRATION, by itself, creates a new REGISTRATION or raises the existing
%      singleton*.
%
%      H = REGISTRATION returns the handle to a new REGISTRATION or the handle to
%      the existing singleton*.
%
%      REGISTRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTRATION.M with the given input arguments.
%
%      REGISTRATION('Property','Value',...) creates a new REGISTRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Registration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Registration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Registration

% Last Modified by GUIDE v2.5 23-May-2012 10:01:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Registration_OpeningFcn, ...
                   'gui_OutputFcn',  @Registration_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

addpath('common');
addpath('output');
addpath('testdata');
% End initialization code - DO NOT EDIT


% --- Executes just before Registration is made visible.
function Registration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Registration (see VARARGIN)

% Choose default command line output for Registration
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Registration wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Registration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in opensourceButton.
function opensourceButton_Callback(hObject, eventdata, handles)

%get source file
[filename, pathname] = uigetfile({'*.png', 'PNG files (*.png)'; ...
                                 '*.jpg', 'JPEG files (*.jpg)'; ...
                                 '*.*', 'All files (*.*)'}, ...
                                 'Choose a source image');
     
if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
       %warndlg('User pressed cancel');
else
    fullpath = fullfile(pathname, filename);
    disp(['User selected ', fullpath]);
    
    % display source file
    axes(handles.sourceAxes);
    handles.sourceImg = imread(fullpath);
    handles.sourcePath = fullpath;
    handles.cursourceImg = handles.sourceImg;
    %handles.cursourcedispImg = handles.cursourceImg;
    imshow(handles.cursourceImg);
       
end


guidata(hObject, handles);


% --- Executes on button press in opentargetButton.
function opentargetButton_Callback(hObject, eventdata, handles)

% get target file
[filename, pathname] = uigetfile({'*.png', 'PNG files (*.png)'; ...
                                 '*.jpg', 'JPEG files (*.jpg)'; ...
                                 '*.*', 'All files (*.*)'}, ...
                                 'Choose a target image');
if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
else
    fullpath = fullfile(pathname, filename);
    disp(['User selected ', fullpath]);
    
    % display target file
    axes(handles.targetAxes);
    handles.targetImg = imread(fullpath);
    handles.curtargetImg = handles.targetImg;
    handles.targetPath = fullpath;
    imshow(handles.curtargetImg);
    
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sourceAxes_CreateFcn(hObject, eventdata, handles)

axis off; 
% test application data
%matrices.rand_35 = randn(35);
%setappdata(hObject,'mydata',matrices);



% --- Executes during object creation, after setting all properties.
function targetAxes_CreateFcn(hObject, eventdata, handles)

axis off;
% Hint: place code in OpeningFcn to populate targetAxes


% --- Executes on button press in sourceinverseButton.
function sourceinverseButton_Callback(hObject, eventdata, handles)

% inverse the intensity
if ~isfield(handles, 'cursourceImg');
    %display('Open a source image first...');
    warndlg('Open a source image first...');
else
    handles.cursourceImg = imcomplement(handles.cursourceImg);
    % display 
    axes(handles.sourceAxes);
    imshow(handles.cursourceImg);
end

% update guidata
guidata(hObject, handles);


% --- Executes on button press in sourcethresholdButton.
function sourcethresholdButton_Callback(hObject, eventdata, handles)

% get threshold value
%sourcethresholdVal = get(handles.sourcethresholdSlider, 'Value');
sourcethresholdVal = str2double(get(handles.sourcethresholdEdit, 'String'));
if sourcethresholdVal>=0.0 && sourcethresholdVal <=1.0
    set(handles.sourcethresholdSlider, 'Value', sourcethresholdVal);
    handles.cursrcThreshold = sourcethresholdVal;
    % binarization with given threshold
    if ~isfield(handles, 'cursourceImg');
        %display('Open a source image first...');
        warndlg('Open a source image first...');
    
    else
        handles.bisrcImg = im2bw(handles.cursourceImg, sourcethresholdVal);
        % display
        axes(handles.sourceAxes);
        imshow(handles.bisrcImg);
    end
else
%display('Input a valid threshold(0-1)...');  
warndlg('Input a valid threshold(0-1)...'); 
   
end

% update guidata
guidata(hObject, handles);


% --- Executes on button press in srcextractchannelButton.
function srcextractchannelButton_Callback(hObject, eventdata, handles)


if ~isfield(handles, 'sourceImg')
    %display('Open a source image first...');
    warndlg('Open a source image first...');
else
    % get channel
    [~, ~, d] = size(handles.sourceImg);
    if ~isfield(handles, 'cursrcChannel')
        %handles.cursrcChannel = 1;
        %display('Choose a channel first...');
        warndlg('Choose a channel first...');
    else

        if handles.cursrcChannel > 0 && d > 1
            handles.cursourceImg = handles.sourceImg(:,:,handles.cursrcChannel);
        else if handles.cursrcChannel == 0
                handles.cursourceImg = rgb2gray(handles.cursourceImg);
            else
                handles.cursourceImg = handles.cursourceImg(:,:,1);
            end
        end
        % display
        axes(handles.sourceAxes);
        imshow(handles.cursourceImg);
    end
end

% update guidata
guidata(hObject, handles);


% --- Executes on slider movement.
function sourcethresholdSlider_Callback(hObject, eventdata, handles)

% get source threshold
handles.cursrcThreshold = get(hObject, 'Value');
% display theshold
%set(handles.cursrcthresholdStatic, 'string', handles.cursrcThreshold);
set(handles.sourcethresholdEdit, 'string', handles.cursrcThreshold);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sourcethresholdSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in extractsrcfiducialButton.
function extractsrcfiducialButton_Callback(hObject, eventdata, handles)

% extract fiducials
if ~isfield(handles, 'cursourceImg');
    %display('Open a source image first...');
    warndlg('Open a source image first...');
else
    if ~isfield(handles, 'cursrcThreshold')
        %display('Choose a threshold first...');
        warndlg('Choose a threshold first...');
    else
        handles.sourcePts = extractLM( handles.cursourceImg, handles.cursrcThreshold);
    
        % display
        axes(handles.sourceAxes);
        hold on
        plot(handles.sourcePts(:, 2), handles.sourcePts(:, 1), 'bo', 'LineWidth', 2, ...
         'MarkerSize', 15);
        hold off
        % save result
        if isfield(handles, 'srcRect')
            handles.sourcePts = bsxfun(@plus, handles.sourcePts, [handles.srcRect(2) handles.srcRect(1)] ) ;
        end
        sourcePts = handles.sourcePts;
        save('output/sourcePts.txt', 'sourcePts', '-ASCII');
    end
end

% update
guidata(hObject, handles);


function resultAxes_CreateFcn(hObject, eventdata, handles)
axis off;



function sourcepreGroup_SelectionChangeFcn(hObject, eventdata, handles)

curchannelTag = get(eventdata.NewValue, 'Tag');
switch curchannelTag
    case 'redradiobutton'
        handles.cursrcChannel = 1;
    case 'greenradiobutton'
        handles.cursrcChannel = 2;
    case 'blueradiobutton'
        handles.cursrcChannel = 3;
    case 'grayradiobutton'
        handles.cursrcChannel = 0;
    otherwise
        handles.cursrcChannel = -1;
end
% debug
handles.cursrcChannel

guidata(hObject, handles);


function extracttarfiducialButton_Callback(hObject, eventdata, handles)

% extract fiducials
if ~isfield(handles, 'curtargetImg');
    %display('Open a target image first...');
    warndlg('Open a target image first...');
else
    if ~isfield(handles, 'curtarThreshold')
        %display('Choose a threshold first...');
        warndlg('Choose a threshold first...');
    else
        handles.targetPts = extractLM( handles.curtargetImg, handles.curtarThreshold);

        % display
        axes(handles.targetAxes);
        hold on
        plot(handles.targetPts(:, 2), handles.targetPts(:, 1), 'r+', 'LineWidth', 2, ...
         'MarkerSize', 15);
        hold off
        % save result
        if isfield(handles, 'tarRect')
            handles.targetPts = bsxfun(@plus, handles.targetPts, [handles.tarRect(2) handles.tarRect(1)] ) ;
        end
        targetPts = handles.targetPts;
        save('output/targetPts.txt', 'targetPts', '-ASCII');
    end
end

% update
guidata(hObject, handles);


function targetthresholdSlider_Callback(hObject, eventdata, handles)

% get source threshold
handles.curtarThreshold = get(hObject, 'Value');
% display theshold
%set(handles.curtarthresholdStatic, 'string', handles.curtarThreshold);
set(handles.targetthresholdEdit, 'string', handles.curtarThreshold);
guidata(hObject, handles);


function targetthresholdSlider_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function targetinverseButton_Callback(hObject, eventdata, handles)

% inverse the intensity
if ~isfield(handles, 'curtargetImg');
    %display('Open a target image first...');
    warndlg('Open a target image first...');
else
    handles.curtargetImg = imcomplement(handles.curtargetImg);
    % display 
    axes(handles.targetAxes);
    imshow(handles.curtargetImg);
end

% update guidata
guidata(hObject, handles);


function tarextractchannelButton_Callback(hObject, eventdata, handles)

if ~isfield(handles, 'targetImg');
    %display('Open a target image first...');
    warndlg('Open a target image first...');
else
    % get channel
    [~,~,d] = size(handles.targetImg);
    if ~isfield(handles, 'curtarChannel')
        %handles.curtarChannel = 1;
        %display('Choose a channel first...');
        warndlg('Choose a channel first...');
        
    else
        
        if handles.curtarChannel > 0 && d > 1
            handles.curtargetImg = handles.targetImg(:,:,handles.curtarChannel);
        else
            if handles.curtarChannel == 0
                handles.curtargetImg = rgb2gray(handles.curtargetImg);
            else
                handles.curtargetImg = handles.curtargetImg(:,:,1);
            end
        end
        % display
        axes(handles.targetAxes);
        imshow(handles.curtargetImg);
    end
end

% update guidata
guidata(hObject, handles);


function targetthresholdButton_Callback(hObject, eventdata, handles)

% get threshold value
%targetthresholdVal = get(handles.targetthresholdSlider, 'Value');
targetthresholdVal = str2double(get(handles.targetthresholdEdit, 'String'));
% binarization with given threshold
if targetthresholdVal>=0.0 && targetthresholdVal <=1.0
    set(handles.targetthresholdSlider, 'Value', targetthresholdVal);
    handles.curtarThreshold = targetthresholdVal;
    if ~isfield(handles, 'curtargetImg');
        %display('Open a target image first...');
        warndlg('Open a target image first...');
    else
        handles.bitarImg = im2bw(handles.curtargetImg, targetthresholdVal);
        % display
        axes(handles.targetAxes);
        imshow(handles.bitarImg);
    end
else
    %display('Input a valid threshold(0-1)...');
    warndlg('Input a valid threshold(0-1)...');
end
% update guidata
guidata(hObject, handles);


function targetpreGroup_SelectionChangeFcn(hObject, eventdata, handles)

curchannelTag = get(eventdata.NewValue, 'Tag');
switch curchannelTag
    case 'redradiobutton'
        handles.curtarChannel = 1;
    case 'greenradiobutton'
        handles.curtarChannel = 2;
    case 'blueradiobutton'
        handles.curtarChannel = 3;
    case 'grayradiobutton'
        handles.curtarChannel = 0;
    otherwise
        handles.curtarChannel = -1;
end
% debug
handles.curtarChannel

guidata(hObject, handles);


function regButton_Callback(hObject, eventdata, handles)

% landmark/fiducial based registration
% initialize parameters
distthreshold = get(handles.distthresholdEdit, 'String');
params.distthreshold = str2num(distthreshold); %7;

simithreshold = get(handles.simithresholdEdit, 'String');
params.simithreshold = str2num(simithreshold); %0.02;

if ~isfield(handles, 'curmodel')
    %display('Choose a model evaluation method...');
    warndlg('Choose a model evaluation method...');
else
    params.checkinliner  = handles.curmodel;
end

leastsquares = get(handles.lsCheckbox, 'Value');
if leastsquares == get(handles.lsCheckbox, 'Max')
    params.leastsquares  = 1;
else
    params.leastsquares = 0;
end

params.debug = 0;

if ~isfield(handles, 'curoutput')
    %display('Choose a output method...');
    warndlg('Choose a output method...');
else
if ~isfield(handles,'sourcePts') || ~isfield(handles, 'targetPts')
    %display('Extract landmarks/fiducials first');
    warndlg('Extract landmarks/fiducials first');
else
    %
    % display
    axes(handles.resultAxes);
    %if ~isfield(handles, 'matchinfo') || ~isfield(handles, 'lsmatchinfo')
        [handles.matchinfo, handles.lsmatchinfo] = lmRegistration(handles.sourcePts, handles.targetPts, params);
    %end
    
    if handles.curoutput == 1
        
        registered = imgTransform( handles.sourceImg, size(handles.targetImg), handles.lsmatchinfo.affinematrix, 'affine');
        imshow(registered)
        hold on
        h = imshow(handles.targetImg);
        set(h, 'AlphaData', 0.6)
        hold off
        
        f = getframe(gca);
        imwrite(f.cdata, 'output/resultImg.png');
        %print(h, '-dpng', 'resultImg');

    else

        h = plot(handles.targetPts(:, 2), handles.targetPts(:, 1), 'r+', 'LineWidth', 2, 'MarkerSize', 10);
        hold on
        plot(handles.lsmatchinfo.sourceptstrans(:,2), handles.lsmatchinfo.sourceptstrans(:,1), 'bo', 'LineWidth', 2, 'MarkerSize', 10); 
        hold off
        
        f = getframe(gca);
        imwrite(f.cdata, 'output/resultPts.png');
        %print(handles.resultAxes, '-dpng', 'resultPts');
    end
    
    % 
    % save matchedpts
    matchedPts = [handles.lsmatchinfo.matchsourcetranspts handles.lsmatchinfo.matchtargetpts];
    save('output/matchedPts.txt', 'matchedPts', '-ASCII');
end
end


guidata(hObject, handles);


function srcresetButton_Callback(hObject, eventdata, handles)

if ~isfield(handles, 'sourcePath')
       %disp('Open a new file first...')
       warndlg('Open a new file first...')
else   
    fullpath = handles.sourcePath;
    display(['Reset ', fullpath]);
    
    % display target file
    axes(handles.sourceAxes);
    handles.sourceImg = imread(fullpath);
    handles.cursourceImg = handles.sourceImg;
    imshow(handles.cursourceImg);   
end

guidata(hObject, handles);


function tarresetButton_Callback(hObject, eventdata, handles)

if ~isfield(handles, 'targetPath')
       %disp('Open a new file first...')
       warndlg('Open a new file first...')
else
    fullpath = handles.targetPath;
    display(['Reset ', fullpath]);
    
    % display target file
    axes(handles.targetAxes);
    handles.targetImg = imread(fullpath);
    handles.curtargetImg = handles.targetImg;
    imshow(handles.curtargetImg);    
end

guidata(hObject, handles);


function targetcropButton_Callback(hObject, eventdata, handles)

axes(handles.targetAxes);
if ~isfield(handles, 'curtargetImg');
    %display('Open a target image first');
    warndlg('Open a target image first');
else
    rect = fix(getrect);
    [r, c] = size(handles.curtargetImg);
    
    % validate rect coordinates
    if rect(2) < 1
        rect(4) = rect(4) + rect(2) - 1;
        rect(2) = 1;
    end
    if rect(2) >= r
        rect(2) = 0;
    end
    if rect(1) < 1
        rect(3) = rect(3) + rect(1) - 1;
    end
    if rect(1) >= c
        rect(1) = 0;
    end
    if rect(2) + rect(4) > r && ~rect(2) == 0 
        rect(4) = r - rect(2);
    end
    if rect(1) + rect(3) > c && ~rect(1) == 0
        rect(3) = c - rect(1);
    end
    
    if rect(2) == 0 || rect(1) == 0
        %display('Choose a valid rect region');
        warndlg('Choose a valid rect region...');
    else
        %cropedImg = handles.curtargetImg(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3), :);
        cropedImg = imcrop(handles.curtargetImg, rect);
        handles.tarRect = rect;
        handles.curtargetImg = cropedImg;
        imshow(cropedImg);
    end
end

guidata(hObject, handles);

function sourcecropButton_Callback(hObject, eventdata, handles) %#ok<*INUSL>

axes(handles.sourceAxes);
if ~isfield(handles, 'cursourceImg');
    %display('Open a source image first...');
    warndlg('Open a source image first...');
else
    rect = fix(getrect);

    [r, c] = size(handles.cursourceImg);
    
        
    % validate rect coordinates
    if rect(2) < 1
        rect(4) = rect(4) + rect(2) - 1;
        rect(2) = 1;
    end
    if rect(2) >= r
        rect(2) = 0;
    end
    if rect(1) < 1
        rect(3) = rect(3) + rect(1) - 1;
    end
    if rect(1) >= c
        rect(1) = 0;
    end
    if rect(2) + rect(4) > r && ~rect(2) == 0 
        rect(4) = r - rect(2);
    end
    if rect(1) + rect(3) > c && ~rect(1) == 0
        rect(3) = c - rect(1);
    end
    
    if rect(2) == 0 || rect(1) == 0
        %display('Choose a valid rect region...');
        warndlg('Choose a valid rect region...');
    else
        %cropedImg = handles.cursourceImg(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3), :);
        cropedImg = imcrop(handles.cursourceImg, rect);
        
        handles.srcRect = rect;
        handles.cursourceImg = cropedImg;
        %handles.cursourceImg = zeros(size(handles.cursourceImg));
        %handles.cursourceImg(rect(2):rect(2)+rect(4), rect(1):rect(1)+rect(3), :) = cropedImg;
        imshow(cropedImg);
    end
end

guidata(hObject, handles);


function distthresholdEdit_Callback(hObject, eventdata, handles) %#ok<*INUSD>


function distthresholdEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function simithresholdEdit_Callback(hObject, eventdata, handles)


function simithresholdEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lsCheckbox_Callback(hObject, eventdata, handles)


function modelGroup_SelectionChangeFcn(hObject, eventdata, handles)

curmodelTag = get(eventdata.NewValue, 'Tag');
switch curmodelTag
    case 'medianradioButton'
        handles.curmodel = 1;
    case 'allradioButton'
        handles.curmodel = 0;
    otherwise
        handles.curmodel = 0;
end

guidata(hObject, handles);


function outputGroup_SelectionChangeFcn(hObject, eventdata, handles)

curoutputTag = get(eventdata.NewValue, 'Tag');
switch curoutputTag
    case 'imgradioButton'
        handles.curoutput = 1;
    case 'ptsradioButton'
        handles.curoutput = 0;
    otherwise
        handles.curoutput = 1;
end

guidata(hObject, handles);


function sourcepreGroup_CreateFcn(hObject, eventdata, handles)

handles.cursrcChannel = 1;

guidata(hObject, handles);


function targetpreGroup_CreateFcn(hObject, eventdata, handles)

handles.curtarChannel = 1;

guidata(hObject, handles);


function modelGroup_CreateFcn(hObject, eventdata, handles)

handles.curmodel = 1;

guidata(hObject, handles);


function outputGroup_CreateFcn(hObject, eventdata, handles)

handles.curoutput = 1;

guidata(hObject, handles);


function targetthresholdEdit_Callback(hObject, eventdata, handles)


function targetthresholdEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sourcethresholdEdit_Callback(hObject, eventdata, handles)


function sourcethresholdEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
