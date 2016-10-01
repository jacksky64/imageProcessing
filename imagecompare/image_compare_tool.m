
function image_compare_tool(left_image, right_image)

% Create the figure
hFig = figure('Toolbar','none',...
              'Menubar','none',...
              'Name','Image Compare Tool',...
              'NumberTitle','off',...
              'IntegerHandle','off');
          
% Display left image              
subplot(121)  
hImL = imshow(left_image);

% Display right image
subplot(122)
hImR = imshow(right_image);

% Create a scroll panel for left image
hSpL = imscrollpanel(hFig,hImL);
set(hSpL,'Units','normalized',...
    'Position',[0 0.1 .5 0.9])

% Create scroll panel for right image
hSpR = imscrollpanel(hFig,hImR);
set(hSpR,'Units','normalized',...
    'Position',[0.5 0.1 .5 0.9])

% Add a Magnification box 
hMagBox = immagbox(hFig,hImL);
pos = get(hMagBox,'Position');
set(hMagBox,'Position',[0 0 pos(3) pos(4)])

% Add a pixel info  
hl = impixelinfo(hFig,hImL);
set(hl,'Position',[20 20 200 pos(4)])
hr = impixelinfo(hFig,hImR);
set(hr,'Position',[220 20 200 pos(4)])

%% Add an Overview tool
imoverview(hImL) 

%% Get APIs from the scroll panels 
apiL = iptgetapi(hSpL);
apiR = iptgetapi(hSpR);

%% Synchronize left and right scroll panels
apiL.setMagnification(apiR.getMagnification())
apiL.setVisibleLocation(apiR.getVisibleLocation())

% When magnification changes on left scroll panel, 
% tell right scroll panel
apiL.addNewMagnificationCallback(apiR.setMagnification);

% When magnification changes on right scroll panel, 
% tell left scroll panel
apiR.addNewMagnificationCallback(apiL.setMagnification);

% When location changes on left scroll panel, 
% tell right scroll panel
apiL.addNewLocationCallback(apiR.setVisibleLocation);

% When location changes on right scroll panel, 
% tell left scroll panel
apiR.addNewLocationCallback(apiL.setVisibleLocation);

hf1=imcontrast(hImL);
hf2=imcontrast(hImR);