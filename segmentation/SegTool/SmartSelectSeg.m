function SmartSelectSeg
% SMARTSELECTSEG  - This function displays chosen image and creates buttons
% for marking seeds and calling Segment function
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global Variables
% Req by radio button RadioButtonFn
global hfig longfilename;

% Get handle to current figure;
hfig = gcf;


% Call built-in file dialog to select image file
[filename,pathname] = uigetfile('images/*.*','Select image file');
if ~ischar(filename); return; end

%%%%%%%%%%%%%%%%%%%Radio Buttons%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = uibuttongroup('visible','off','Position',[0.7 0.7 0.15 0.18]);
u0 = uicontrol('Style','Radio','String','SmartRectangle',...
    'pos',[10 20 120 30],'parent',h,'HandleVisibility','off');
u1 = uicontrol('Style','Radio','String','SmartRefine',...
    'pos',[10 60 120 30],'parent',h,'HandleVisibility','off');
set(h,'SelectionChangeFcn',@RadioButtonFn);
set(h,'SelectedObject',[]);
set(h,'Visible','on');

%%%%%%%%%%%%%%%%%%%Draw Image%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load  Image file
longfilename = strcat(pathname,filename);
Im = imread(longfilename);

% Get the position of the image
data.ui.ah_img = axes('Position',[0.01 0.2 .603 .604]);
data.ui.ih_img = image;

% Set the image
set(data.ui.ih_img, 'Cdata', Im);
axis('image');axis('ij');axis('off');
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RadioButtonFn(source, eventdata)
% RADIOBUTTONFUNCTION - This function is called whenever there is change in
% choice of radio button

% Global Variables
global hfig longfilename;

% Pass string value to seed selection function
strg = get(eventdata.NewValue,'String');

%%%%%%%%%%%%%%%%Seed Selection Buttons%%%%%%%%%%%%%%%%%%%
% Calls fginput - gets foreground pixels from the user
data.ui.push_fg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .6 .1 .05], ...
    'String','Foreground','Callback', ['fginput ',strg]);

% Calls bginput - gets background pixels from the user
data.ui.push_bg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .5 .1 .05], ...
    'String','Background','Callback', ['bginput ',strg]);

% Calls Segment - graph-cuts on the image
data.ui.push_bg = uicontrol(hfig, 'Style','pushbutton', 'Units', 'Normalized','Position',[.7 .4 .1 .05], ...
    'String','Graph Cuts','Callback', ['Segment ',longfilename]);
drawnow;

