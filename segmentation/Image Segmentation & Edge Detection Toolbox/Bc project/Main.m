function varargout = Main(varargin)
% MAIN MATLAB code for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 31-Aug-2015 12:04:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_OutputFcn, ...
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


% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;
handles.image = 0;
handles.resultImage = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;
addpath('regionGrowing');
addpath('PSO');
addpath('GraphSeg');
addpath('adaptcluster_kmeans');
addpath('FCMLSM');
addpath('ISODATA');
addpath('html');


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, filepath] = uigetfile({'*.jpg;*.png;*.bmp;*.jpeg;*.tiff','Image Files (*.jpg,*.png,*.bmp,*.jpeg,*.tiff)'});
    
handles.image = imread(strcat(filepath,filename));
guidata(hObject, handles);
imshow(handles.image, 'Parent', handles.axes1);


% --- Executes on selection change in chooseMethod.
function chooseMethod_Callback(hObject, eventdata, handles)
% hObject    handle to chooseMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseMethod

persistent t;
persistent k;
if (isfield(handles, 't'))
            handles = rmfield	(handles, 't');
            delete(t);

end
if (isfield(handles, 'k'))
            handles = rmfield	 (handles, 'k');
            delete(k);

end
option = get(handles.chooseMethod, 'Value');
switch option
    
    
     case 3
         f = handles.figure1;
         t = uicontrol(f, 'style', 'text', 'string', 'K : levels of segmentation = 2', 'position', [710 540 140 17.8]);
         k = uicontrol(f, 'style', 'slider', 'min', 2, 'max', 20, 'value', 2, 'position', [870 540 140 17.8], 'sliderstep' , [1/18 1/18]);
         handles.t = t;
         handles.k = k;
     %k = uicontrol(f, 'Style', 'slider', 
     case 13
         f = handles.figure1;
         t = uicontrol(f, 'style', 'text', 'string', 'K : levels of segmentation = 2', 'position', [710 540 140 17.8]);
         k = uicontrol(f, 'style', 'slider', 'min', 2, 'max', 20, 'value', 2, 'position', [870 540 140 17.8], 'sliderstep' , [1/18 1/18]);
         handles.t = t;
         handles.k = k;
     case 14
         f = handles.figure1;
         t = uicontrol(f, 'style', 'text', 'string', 'K : levels of segmentation = 2', 'position', [710 540 140 17.8]);
         k = uicontrol(f, 'style', 'slider', 'min', 2, 'max', 20, 'value', 2, 'position', [870 540 140 17.8], 'sliderstep' , [1/18 1/18]);
         handles.t = t;
         handles.k = k;
     case 15
         f = handles.figure1;
         t = uicontrol(f, 'style', 'text', 'string', 'K : levels of segmentation = 2', 'position', [710 540 140 17.8]);
         k = uicontrol(f, 'style', 'slider', 'min', 2, 'max', 20, 'value', 2, 'position', [850 540 140 17.8], 'sliderstep' , [1/18 1/18]);
         handles.t = t;
         handles.k = k;
     case 16
         f = handles.figure1;
         t = uicontrol(f, 'style', 'text', 'string', 'K : levels of segmentation = 2', 'position', [710 540 140 17.8]);
         k = uicontrol(f, 'style', 'slider', 'min', 2, 'max', 20, 'value', 2, 'position', [850 540 140 17.8], 'sliderstep' , [1/18 1/18]);
         handles.t = t;
         handles.k = k;
    
       


end
        guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function chooseMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in do.
function do_Callback(hObject, eventdata, handles)
% hObject    handle to do (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
image = imread('please-wait.png');
imshow(image, 'Parent', handles.axes2);
pause(1);
option = get(handles.chooseMethod, 'Value');
switch option
    case 2
         level = graythresh(handles.image);
         image = im2bw(handles.image,level);
         handles.resultImage = image;
    
     case 3
         k = get(handles.k,'Value');
         image = (handles.image);
         level = multithresh(handles.image,k);
         image = imquantize(image,level);
         image = label2rgb(image);
         handles.resultImage = image;
    case 4
        labledImage = adaptcluster_kmeans(handles.image);
        image = label2rgb(labledImage);
        handles.resultImage = image;
    case 5
        image = (handles.image);
        image = edge(image,'Canny');
        handles.resultImage = image;
    case 6
        image = (handles.image);
        image = edge(image,'log');
        handles.resultImage = image;
    case 7
        image = (handles.image);
        image = edge(image,'Prewitt');
        handles.resultImage = image;
    case 8
        image = (handles.image);
        image = edge(image,'Roberts');
        handles.resultImage = image;
    case 9
        image = (handles.image);
        image = edge(image,'Sobel');
        handles.resultImage = image;
    case 10
        image = (handles.image);
        image = edge(image,'zerocross');
        handles.resultImage = image;
    case 11
        image = (handles.image);
        [~, threshold] = edge (image, 'Sobel');
        fudgeFactor = 0.5;
        BWs = edge(image,'sobel', threshold * fudgeFactor);
        se90 = strel('line', 3, 90);
        se0 = strel('line', 3, 0);
        BWsdil = imdilate(BWs, [se90 se0]);
        BWdfill = imfill(BWsdil, 'holes');
        seD = strel('diamond',1);
        BWfinal = imerode(BWdfill,seD);
        BWfinal = imerode(BWfinal,seD);
        BWoutline = bwperim(BWfinal);
        Segout = handles.image;
        Segout(repmat(BWoutline,[1,1,size(handles.image,3)])) = 255;
        handles.resultImage = Segout;
    case 12
        image = (handles.image);
        [x, y] = size(image);
        [~, mask] = regionGrowing(image,[floor(rand()*x), floor(rand()*y)]);
        image = double(handles.image).*repmat(mask,[1,1,size(handles.image,3)]);
        handles.resultImage = image;
    case 13
        k = get(handles.k,'Value');
        image = segmentation(handles.image,k,'PSO');
        handles.resultImage = image;
    case 14
        k = get(handles.k,'Value');
        image = segmentation(handles.image,k,'DPSO');
        handles.resultImage = image;
    case 15
        k = get(handles.k,'Value');
        image = segmentation(handles.image,k,'FODPSO');
        handles.resultImage = image;
    case 16
        k = get(handles.k,'Value');
        image = (handles.image);
        image = SFCM2D(image,k);
        for i= 1:k
            resultImage(:,:,i) = reshape(image(i,:,:),size(handles.image,1),size(handles.image,2));
        end
       % h = vision.AlphaBlender;
       % image = resultImage(:,:,1);
       % for i=2:k
            %image = step(h,image, resultImage(:,:,i));
      %      image = imfuse(image, resultImage(:,:,i),'blend');
       % end
        %image = reshape(image(1,:,:),size(handles.image,1),size(handles.image,2));
        image = ones(size(resultImage,1),size(resultImage,2),1,size(resultImage,3));
        image(:,:,1,:) = resultImage;
        montage(image,'Size',[NaN 3]);
    case 17
       [~, image] = isodata(( handles.image));
       handles.resultImage = image;
        
end
guidata(hObject, handles);
if (option ~= 16)
    imshow(handles.resultImage, 'Parent', handles.axes2);
end
function k_Callback(handles)
set(handles.t, 'string', strcat('K : levels of segmentation = ', handles.get(k,'value')));
