function varargout = ActiveCountorsGUI(varargin)
% ACTIVECOUNTORSGUI M-file for ActiveCountorsGUI.fig
%      ACTIVECOUNTORSGUI, by itself, creates a new ACTIVECOUNTORSGUI or raises the existing
%      singleton*.
%
%      H = ACTIVECOUNTORSGUI returns the handle to a new ACTIVECOUNTORSGUI or the handle to
%      the existing singleton*.
%
%      ACTIVECOUNTORSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACTIVECOUNTORSGUI.M with the given input arguments.
%
%      ACTIVECOUNTORSGUI('Property','Value',...) creates a new ACTIVECOUNTORSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ActiveCountorsGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ActiveCountorsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above NoiseLambdaText to modify the response to help ActiveCountorsGUI

% Last Modified by GUIDE v2.5 28-Jun-2011 11:26:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ActiveCountorsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ActiveCountorsGUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before ActiveCountorsGUI is made visible.
function ActiveCountorsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ActiveCountorsGUI (see VARARGIN)

% Choose default command line output for ActiveCountorsGUI
handles.output = hObject;

% subplot('Position',[0.29,0.12,0.79,0.79]);
X=zeros(300,250,3);
X(:,:,2)=200;
imshow(uint8(X),'Parent',handles.Axes);

txt_hndl=zeros(1,2);
txt_hndl(1)=text(20,146,{
'Welcome to our GUI!',... 
' ','1. Choose image file for segmentation,','  using ''Load Image File'' button.',... 
' ','2. Choose noise model parameters in ','  ''Noise Model'' panel.',... 
' ','3. Choose the Gaussian blur filter Sigma value in ','  ''Blur denoise panel''.',... 
' ','4. Choose the color space and colr element in  ','  ''Color space'' panel.',... 
' ','5. Choose the contour based segmentation algorithm ','  to apply and set desired algorithm parameters.',... 
' ','6. Choose your display settings in the','  ''Display Menu'' panel.',... 
' ','7. Choose refresh rate of displayed images','  and save rate of saved images.',... 
' ','8. Choose output path for saved images during','  algorithm application (default - current directory).',... 
' ','9. Finally, press ''Run'' below, and enjoy the magic...'},... 
'FontSize',12); 
txt_hndl(2)=text(50,308,'\copyright Nikolay S. & Alex B.','FontSize',10,'FontAngle','italic','Color','r'); 
set(txt_hndl,'Units','Normalized');
set(txt_hndl,'FontUnits','Normalized');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ActiveCountorsGUI wait for user response (see UIRESUME)
% uiwait(handles.GUIfig);


% --- Outputs from this function are returned to the command line.
function varargout = ActiveCountorsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function GUIfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GUIfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes on button press in ShowContour.
clc;clear all;warning off;
fprintf('%s\n\n','Active Contours GUI started.'); 


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function OutDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles=guidata(hObject);
directory_name=cd; %default value is current directory
handles.OutDirPath=directory_name;
guidata(hObject,handles);


% --- Executes on button press in OutDir.
function OutDir_Callback(hObject, eventdata, handles)
% hObject    handle to OutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
directory_name = uigetdir;
handles.OutDirPath=directory_name;
guidata(hObject,handles);


% --- Executes on button press in LoadFileButton.
function LoadFileButton_Callback(hObject, eventdata, handles) 
% hObject handle to LoadFileButton (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
FilterSpec={'*.jpg;*.jpeg;*.gif;*.bmp;*.png;*.tiff;*.tif','Image Files (*.jpg;*.jpeg;*.gif;*.bmp;*.png;*.tiff;*.tif)'}; 
DialogTitle='Select image file'; 
[FileName,PathName] = uigetfile(FilterSpec,DialogTitle); 
if (isequal(FileName,0)) 
    disp('File could not be loaded'); 
    return; 
end
handles.ImageFileAddr=[PathName,FileName];
guidata(hObject,handles);
handles.ImageData=add_noise2image(hObject);
set([handles.AlgParamsPanel,handles.AlgTypePanel,handles.NoiseModelPanel,...
    handles.DispMenuPanel,handles.RunPanel,handles.ColorSpacePanel,...
    handles.BlurUipanel],'Visible','on'); 
% for each new image, demand a new mask definition
handles.UserMask=[];
set(handles.UserDefineMaskButton,'String','Define Mask');

guidata(hObject,handles);


function MiuAlgEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MiuAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MiuAlgEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of MiuAlgEdit as a double
handles=guidata(hObject);
set(hObject,'Value',str2num(get(hObject,'String'))); % set value property equal to string numerical value property
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function MiuAlgEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MiuAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NuAlgEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NuAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NuAlgEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of NuAlgEdit as a double
handles=guidata(hObject);
set(hObject,'Value',str2num(get(hObject,'String'))); % set value property equal to string numerical value property
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function NuAlgEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NuAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DeltaTAlgEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DeltaTAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DeltaTAlgEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of DeltaTAlgEdit as a double
handles=guidata(hObject);
set(hObject,'Value',str2num(get(hObject,'String'))); % set value property equal to string numerical value property
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function DeltaTAlgEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeltaTAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Lambda1AlgEdit_Callback(hObject, eventdata, handles)
% hObject    handle to Lambda1AlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lambda1AlgEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of Lambda1AlgEdit as a double
handles=guidata(hObject);
set(hObject,'Value',str2num(get(hObject,'String'))); % set value property equal to string numerical value property
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Lambda1AlgEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lambda1AlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Lambda2AlgEdit_Callback(hObject, eventdata, handles)
% hObject    handle to Lambda2AlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lambda2AlgEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of Lambda2AlgEdit as a double
handles=guidata(hObject);
set(hObject,'Value',str2num(get(hObject,'String'))); % set value property equal to string numerical value property
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Lambda2AlgEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lambda2AlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NAlgEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NAlgEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of NAlgEdit as a double
handles=guidata(hObject);
set(hObject,'Value',round(str2num(get(hObject,'String')))); % set value property equal to string numerical value property
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function NAlgEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NAlgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SegmentOn.
function SegmentOn_Callback(hObject, eventdata, handles)
% hObject    handle to SegmentOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SegmentOn


% --- Executes on button press in EnergyOn.
function EnergyOn_Callback(hObject, eventdata, handles)
% hObject    handle to EnergyOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnergyOn
handles=guidata(hObject);

if (get(hObject,'Value')) % Hide or Show Energy plot panel
    set(handles.EnergyPlotType,'Visible','on');
else
        set(handles.EnergyPlotType,'Visible','off');
end

guidata(hObject,handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function NoiseMiuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseMiuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of NoiseMiuEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of NoiseMiuEdit as a double
handles=guidata(hObject);
set(hObject,'Value',str2num(get(hObject,'String'))); % set value property equal to string numerical value property
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function NoiseMiuEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoiseMiuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NoiseSigmaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NoiseSigmaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NoiseSigmaEdit as NoiseLambdaText
%        str2num(get(hObject,'String')) returns contents of NoiseSigmaEdit as a double
handles=guidata(hObject);
set(hObject,'Value',str2num(get(hObject,'String'))); % set value property equal to string numerical value property
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function NoiseSigmaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoiseSigmaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RealisticNoise.
function RealisticNoise_Callback(hObject, eventdata, handles)
% hObject    handle to RealisticNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RealisticNoise
handles=guidata(hObject);
set([handles.NoiseMiuEdit,handles.NoiseSigmaEdit],'Enable','off');
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes on button press in WhiteNoise.
function WhiteNoise_Callback(hObject, eventdata, handles)
% hObject    handle to WhiteNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WhiteNoise
handles=guidata(hObject);
set([handles.NoiseMiuEdit,handles.NoiseSigmaEdit],'Enable','on');
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes on button press in GaussianNoise.
function GaussianNoise_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GaussianNoise
handles=guidata(hObject);
set([handles.NoiseMiuEdit,handles.NoiseSigmaEdit],'Enable','on');
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes on button press in PoissonNoise.
function PoissonNoise_Callback(hObject, eventdata, handles)
% hObject    handle to PoissonNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PoissonNoise
handles=guidata(hObject);
set([handles.NoiseMiuEdit,handles.NoiseSigmaEdit],'Enable','off');
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes on button press in NoNoise.
function NoNoise_Callback(hObject, eventdata, handles)
% hObject    handle to NoNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NoNoise
handles=guidata(hObject);
set([handles.NoiseMiuEdit,handles.NoiseSigmaEdit],'Enable','off');
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


function RefreshRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefreshRateEdit as text
%        str2num(get(hObject,'String')) returns contents of RefreshRateEdit as a double
handles=guidata(hObject);
rate=str2num(get(hObject,'String'));
if mode(rate,1) % if not an integer
    rate=max(1,round(rate));
    set(hObject,'String',num2str(rate));
end
set(hObject,'Value',rate); % set value property equal to string numerical value property
SaveRateEdit_Callback(hObject, eventdata, handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function RefreshRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefreshRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SaveRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SaveRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SaveRateEdit as text
%        str2num(get(hObject,'String')) returns contents of SaveRateEdit as a double
handles=guidata(hObject);

ShowRate=get(handles.RefreshRateEdit,'Value');
SaveRate=str2num(get(handles.SaveRateEdit,'String'));
if (SaveRate/ShowRate>floor(SaveRate/ShowRate)) % SaveRate should be a multiplication of ShowRate
    SaveRate=ShowRate*ceil(SaveRate/ShowRate);
    set(handles.SaveRateEdit,'String',num2str(SaveRate));
end
set(handles.SaveRateEdit,'Value',SaveRate); % set value property equal to string numerical value property

guidata(handles.SaveRateEdit,handles);


% --- Executes during object creation, after setting all properties.
function SaveRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in EnergyPlotTypeMenu.
function EnergyPlotTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to EnergyPlotTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns EnergyPlotTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EnergyPlotTypeMenu


% --- Executes during object creation, after setting all properties.
function EnergyPlotTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EnergyPlotTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AlgActiveContNoEdges.
function AlgActiveContNoEdges_Callback(hObject, eventdata, handles)
% hObject    handle to AlgActiveContNoEdges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AlgActiveContNoEdges
handles=guidata(hObject);

set([handles.MiuAlgEdit,handles.NuAlgEdit,handles.Lambda1AlgEdit,handles.Lambda2AlgEdit,...
    handles.DeltaTAlgEdit,handles.NAlgEdit],'Enable','on'); % turn buttons on
set([handles.DispMenuPanel,handles.RefreshRateEdit,handles.SaveRateEdit],'Visible','on'); % show panels

set(handles.MiuAlgEdit,'Value',65.025);set(handles.MiuAlgEdit,'String','(255^2)*1e-3');
set(handles.NuAlgEdit,'Value',0.1);set(handles.NuAlgEdit,'String','1e-1');set(handles.NuAlgText,'String','n');
set(handles.Lambda1AlgEdit,'Value',1);set(handles.Lambda1AlgEdit,'String','1');set(handles.Lambda1AlgText,'String','l1');
set(handles.Lambda2AlgEdit,'Value',1);set(handles.Lambda2AlgEdit,'String','1');set(handles.Lambda2AlgText,'String','l2');
set(handles.DeltaTAlgEdit,'Value',1);set(handles.DeltaTAlgEdit,'String','1');set(handles.DeltaTAlgText,'String','DT');
% set(handles.NAlgEdit,'Value',10);set(handles.NAlgEdit,'String','10');

guidata(hObject,handles);


% --- Executes on button press in AlgLocRegBased.
function AlgLocRegBased_Callback(hObject, eventdata, handles)
% hObject    handle to AlgLocRegBased (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AlgLocRegBased

handles=guidata(hObject);

set([handles.MiuAlgEdit,handles.Lambda2AlgEdit,...
    handles.DeltaTAlgEdit],'Enable','off'); % turn buttons off
set([handles.DispMenuPanel,handles.SaveRateEdit],'Visible','off'); % hide panels
set([handles.NuAlgEdit,handles.NAlgEdit,handles.Lambda1AlgEdit],'Enable','on');
[dimy,dimx,dimz] = size(handles.ImageData);
init_rad = round((dimy+dimx)/(2*8));%default init rad value /2 if full image is used

set(handles.NuAlgEdit,'Value',init_rad); set(handles.NuAlgEdit,'String',num2str(init_rad));
set(handles.NuAlgText,'String','R');
set(handles.Lambda1AlgEdit,'Value',.2); set(handles.Lambda1AlgEdit,'String','.2');%default alpha value
set(handles.Lambda1AlgText,'String','a');

guidata(hObject,handles);


% --- Executes on button press in AlgLevelSetEvol.
function AlgLevelSetEvol_Callback(hObject, eventdata, handles)
% hObject    handle to AlgLevelSetEvol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AlgLevelSetEvol
handles=guidata(hObject);
set([handles.MiuAlgEdit,handles.NuAlgEdit,handles.Lambda1AlgEdit,handles.Lambda2AlgEdit,...
    handles.DeltaTAlgEdit,handles.NAlgEdit],'Enable','on'); % turn buttons on
set([handles.DispMenuPanel,handles.SaveRateEdit],'Visible','off'); % hide panels
set(handles.MiuAlgEdit,'Value',0.04);set(handles.MiuAlgEdit,'String','0.04');
set(handles.NuAlgEdit,'Value',1.5);set(handles.NuAlgEdit,'String','1.5');set(handles.NuAlgText,'String','e');
set(handles.Lambda1AlgEdit,'Value',5);set(handles.Lambda1AlgEdit,'String','5');set(handles.Lambda1AlgText,'String','l');
set(handles.Lambda2AlgEdit,'Value',1.5);set(handles.Lambda2AlgEdit,'String','1.5');set(handles.Lambda2AlgText,'String','a');
set(handles.DeltaTAlgEdit,'Value',1.5);set(handles.DeltaTAlgEdit,'String','1.5');set(handles.DeltaTAlgText,'String','s');

guidata(hObject,handles);


%% ############################# Main Function ###############################
% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
fprintf('%s \n\n\n',['Run started at: ',datestr(clock)]);

set(hObject,'String','Busy');% change the string on the button
set(hObject,'BackgroundColor',[1,0,0,]);%change button color
set(hObject,'ForegroundColor',[0,0,0,]); %change text color
set(hObject,'Enable','off'); %disable button
file_str=handles.ImageFileAddr;

text_line_length=60;     
%% divide name too long to cell array to allow  compact presentation in text command
length_file_str=length(file_str);
cell_array_length=ceil(length_file_str/text_line_length);
file_str4text=cell(1,cell_array_length);
for ind=1:cell_array_length-1 
    file_str4text{ind}=[file_str((1+(ind-1)*text_line_length):...
        ind*text_line_length),'...'];
end
file_str4text{ind+1}=file_str((1+ind*text_line_length):end);

%load image
Img=handles.ImageData; %get image
[img_x,img_y]=size(Img);

if isempty(handles.UserMask) % if mask defined by user
    mask = false(img_x,img_y);   %-- create initial mask
    mask(round(img_x*0.12):round(img_x*0.88),round(img_y*0.12):round(img_y*0.88)) = true;
else
    mask=handles.UserMask;
end

if get(handles.AlgActiveContNoEdges,'Value')
    ActiveContoursWihoutEdges(hObject,mask);
    hold off;
elseif get(handles.AlgLocRegBased,'Value')
    N=get(handles.NAlgEdit,'Value');%number of iterations
    Aplha=get(handles.Lambda1AlgEdit,'Value');
    InitRad=get(handles.NuAlgEdit,'Value');
    PlotRate=get(handles.RefreshRateEdit,'Value');
    title('Segmentation by Active Contours Without Edges','FontSize',14);
    localized_seg(Img, mask, N,InitRad,Aplha,2,PlotRate);  %-- run segmentation
    text(ceil(img_x/2),img_y+15,{'Applied to file:',file_str4text{:}},...
        'HorizontalAlignment','center','FontSize',11);


elseif get(handles.AlgLevelSetEvol,'Value')
    sigma=get(handles.DeltaTAlgEdit,'Value');%1.5;   % scale parameter in Gaussian kernel for smoothing.
    epsilon=get(handles.NuAlgEdit,'Value');%1.5; % the papramater in the definition of smoothed Dirac function
    mu=get(handles.MiuAlgEdit,'Value');%0.04;     % coefficient of the internal (penalizing) energy term P(\phi)
    lambda=get(handles.Lambda1AlgEdit,'Value');%5;    % coefficient of the weighted length term Lg(\phi)
    alf=get(handles.Lambda2AlgEdit,'Value');%1.5;     % coefficient of the weighted area term Ag(\phi);
    N=get(handles.NAlgEdit,'Value');%number of iterations
    c0=4;        % the constant value used to define binary level set function;
    PlotRate=get(handles.RefreshRateEdit,'Value');

    LevelSetEvolutionWithoutReinitialization(Img,sigma,epsilon,mu,lambda,alf,c0,N,PlotRate,mask);
    text(ceil(img_x/2),img_y+15,{'Applied to file:',file_str4text{:}},...
        'HorizontalAlignment','center','FontSize',11);

end
hold off;


set(hObject,'String','Run');% cahnge the string on the button
set(hObject,'BackgroundColor',[0.501,1,0.502]);
set(hObject,'ForegroundColor',[1,0,0,]);
set(hObject,'Enable','on'); %disable button

guidata(hObject,handles);


%% @@@@@@@@@@@@@@@@@@@@@@@@@@@@ User functions @@@@@@@@@@@@@@@@@@@@@@@@@@@@

function out_img=add_noise2image(hObject)
% Adds noise accourdirdic to a model and the parameters the user has choosen
handles=guidata(hObject); %load handles structure

file_str=handles.ImageFileAddr;
img=imread(file_str); % get the image
if size(img,3)~=3
   img=repmat(img,[1,1,3]);
end

if (get(handles.RealisticNoise,'value'))
%     K_gray=get(handles.NoiseMiuEdit,'value');
%     G_electr=get(handles.NoiseSigmaEdit,'value');
    out_img= AddRealisticNoise(img);%realistic noise is added accourding to 
% Netanel Ratner, and Yoav Y. Schechner, “Illumination multiplexing
% within fundamental limits”, Proc. IEEE CVPR (2007).
elseif (get(handles.GaussianNoise,'value'))
     out_img=double(imnoise(img,'gaussian',get(handles.NoiseMiuEdit,'value'),get(handles.NoiseSigmaEdit,'value'))); % Gauss noise model applied.
 elseif (get(handles.PoissonNoise,'value'))
     out_img=double(imnoise(img,'poisson')); % Poisson noise model applied.
 elseif (get(handles.WhiteNoise,'value'))
     out_img=double(img);
     out_img=out_img+ get(handles.NoiseMiuEdit,'value')+get(handles.NoiseSigmaEdit,'value')*(rand(size(out_img))-.5);  % white noise model applied.
elseif (get(handles.NoNoise,'value'))
    out_img=double(img); % no noise is added
end
% if (size(out_img,3)>1)
%     out_img=double(rgb2gray(uint8(out_img))); %convert image to gray scale, basing on Human Eye property
% %     out_img=sqrt(sum(out_img.^2,3)); %convert image to gray scale, basing on mean energy
% end
colorSpace=get(get(handles.ColorRadioButtonGroup,'SelectedObject'),'String');
out_img=uint8(out_img);
switch(upper(colorSpace))
   case('LAB')
      % convert RGB 2 LAB
      cForm = makecform('srgb2lab'); %consider taking this out to the calling function
      out_img = applycform(out_img,cForm);
   case('RGB')
%       out_img = out_img;
   %case('YCBCR')
   otherwise
      % convert RGB 2 YCBCR
      out_img = rgb2ycbcr(out_img);
end

iClrComponent=get(handles.ColorComponentPopupmenu,'Value');
out_img=out_img(:,:,iClrComponent);
if strcmpi('uint8',class(out_img))
   out_img=double(out_img); %convert image to gray scale, basing on Human Eye property
end

sliderValue=get(handles.GaussianSigmaSlider,'Value');
if sliderValue>0
   N=get(handles.NBlurEdit,'Value');
   if sliderValue<100
      Alpha=100/(sliderValue*5);
      gaussian1DFilt=gausswin(N,Alpha);
      gaussian1DFilt=gaussian1DFilt/sum(gaussian1DFilt);
      % figure; plot(gaussian1DFilt);
      gaussian2DFilt=gaussian1DFilt*gaussian1DFilt.';
   else
      gaussian2DFilt=ones(N,N)/(N*N);      
   end
   out_img=imfilter(out_img,gaussian2DFilt,'same','symmetric');
end

subplot(1,1,1);
imshow(out_img,[]);
title('Investigated image with chosen noise model','FontSize',16);
text(ceil(size(out_img,1)/2),size(out_img,2)+10,{'Applied to file:',file_str},...
    'HorizontalAlignment','center','FontSize',11);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NoisyImage] = AddRealisticNoise(OrigImage,K_gray,G_electr)
% function [NoisyImage] = AddRealisticNoise(OrigImage)
% this function receives an image matrix, 
% and returnes a noisy image matrix.
% Added noise is based on Poison distribution model,
% with parameters of Redlake MotionPro HSI camera

if nargin<3
    G_electr=62; % g_electr value for Redlake MotionPro HSI camera
    if nargin<2
        K_gray=1.18; % k_gray value for Redlake MotionPro HSI camera
    end
end
 
OrigImage=double(OrigImage);
VarVal=(K_gray^2)*ones(size(OrigImage))+OrigImage/G_electr; 
% In Poisson distribution Var=Mean=Lambda=k_gray^2+GrayValue/g_electr
NoisyImage=OrigImage+poissrnd(VarVal); % create nosiy image


% --- Executes on button press in UserDefineMaskButton.
function UserDefineMaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to UserDefineMaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
fig_handle=figure;
imshow(handles.ImageData,[]);
hFreeHandVec=text(5,50,{'1. Left click the mouse and mark the ROI.',...
   '2. Release mouse left button to finish current ROI marking.',...
   '3. Drag the ROI markup, if needed.',...
   '4. Double click to Finilize ROI selction.'...
   '5. Choose "Done" to finish mask selection, choose "Not yet" to mark additional ROI'},...
   'FontSize',12,'Color','r');
axis equal;axis off;

maskSum=false(size(handles.ImageData,1),size(handles.ImageData,2));

markROIdlg='Not yet';
hFreeHandVec=[];
while ~strcmpi(markROIdlg,'Done')
   hFreeHand = imfreehand;
   wait(hFreeHand); % Wait till double click
   hFreeHandVec=[hFreeHandVec,hFreeHand];
   maskFreeHand = createMask(hFreeHand);
   maskSum=maskSum | maskFreeHand;
   
   markROIdlg = questdlg({'Press ''Done'', if all ROI''s were marked.',...
      'Press ''Not yet'' if you wish to add additional ROI''s.'},...
      'Setting the initail mask for Active Contours.',...
      'Done','Not yet','Done');
end
delete(hFreeHandVec);
close(fig_handle);
handles.UserMask=maskSum;
set(hObject,'String','Re-define Mask');

guidata(hObject,handles);



% --- Executes on button press in HTBasedAlg.
function HTBasedAlg_Callback(hObject, eventdata, handles)
% hObject    handle to HTBasedAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HTBasedAlg


% --------------------------------------------------------------------
function AboutMenuBttn_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to AboutMenuBttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('InfoFiles', 'file')==7;
    web ('InfoFiles\ActiveContoursAbout.htm', '-new',...
        '-noaddressbox', '-notoolbar');
elseif exist('ActiveContoursAbout.htm', 'file')==2
    web ('ActiveContoursAbout.htm', '-new', '-noaddressbox', '-notoolbar');
end

% --------------------------------------------------------------------
function HelpMenuBttn_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to HelpMenuBttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('InfoFiles', 'file')==7;
    web ('InfoFiles\ActiveContoursHelp.htm', '-new',...
        '-noaddressbox', '-notoolbar');
elseif exist('ActiveContoursAbout.htm', 'file')==2
    web ('ActiveContoursHelp.htm', '-new', '-noaddressbox', '-notoolbar');
end


% --- Executes on selection change in ColorComponentPopupmenu.
function ColorComponentPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ColorComponentPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ColorComponentPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ColorComponentPopupmenu
handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ColorComponentPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorComponentPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in ColorRadioButtonGroup.
function ColorRadioButtonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ColorRadioButtonGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

colorSpace=get(eventdata.NewValue,'String');
switch(upper(colorSpace))
   case('LAB')
      set(handles.ColorComponentPopupmenu,'String',{'L';'A';'B'});
   case('RGB')
      set(handles.ColorComponentPopupmenu,'String',{'R';'G';'B'});
   %case('YCBCR')
   otherwise
      set(handles.ColorComponentPopupmenu,'String',{'Y';'Cb';'Cr'});
end
ColorComponentPopupmenu_Callback(hObject, eventdata, handles);



function GaussianSigmaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianSigmaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GaussianSigmaEdit as text
%        str2double(get(hObject,'String')) returns contents of GaussianSigmaEdit as a double
editString=get(handles.GaussianSigmaEdit,'String');
editValue=str2double(editString);
editValue=max(0,editValue);	% No values under 0 is possible
editValue=min(editValue,100); % No values above 100 is possible

if editValue==round(editValue)
   set(handles.GaussianSigmaEdit,'String',num2str(editValue));
else
   set(handles.GaussianSigmaEdit,'String',num2str(editValue,'%.2f'));
end
set(handles.GaussianSigmaSlider,'Value',editValue);

handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function GaussianSigmaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussianSigmaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function GaussianSigmaSlider_Callback(hObject, eventdata, handles)
% hObject    handle to GaussianSigmaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue=get(handles.GaussianSigmaSlider,'Value');
% sliderValue=round(sliderValue); % use only integer values
% set(handles.GaussianSigmaSlider,'Value',sliderValue);

set(handles.GaussianSigmaEdit,'Value',sliderValue);
if sliderValue==round(sliderValue)
   set(handles.GaussianSigmaEdit,'String',num2str(sliderValue));
else
   set(handles.GaussianSigmaEdit,'String',num2str(sliderValue,'%.2f'));
end

handles.ImageData=add_noise2image(hObject);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function GaussianSigmaSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussianSigmaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function NBlurEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NBlurEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NBlurEdit as text
%        str2double(get(hObject,'String')) returns contents of NBlurEdit as a double
NString=get(handles.NBlurEdit,'String');
N=str2double(NString);
N=round(N);
N=max(4,N);
imgDims=size(handles.ImageData);
N=min(N,min(imgDims(1:2)));

newNString=num2str(N);
if ~strcmpi(NString,newNString)
   set(handles.NBlurEdit,'String',newNString);
end
set(handles.NBlurEdit,'Value',N);
add_noise2image(hObject);


% --- Executes during object creation, after setting all properties.
function NBlurEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NBlurEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
