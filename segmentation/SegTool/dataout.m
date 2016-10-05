function dataout(imagefig,varargins)
% DATAOUT  - This function adds all the stroke points to previous ones
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global Variables
global sopt fgflag fgpixels bgpixels;

% Ignore motion
set(gcf,'WindowButtonMotionFcn',[]);

% If Button down start tracking
set(gcf,'windowbuttondownfcn',{@track});


% Get current data
temp=get(gcf,'userdata');
coords = floor(temp(:,1:2));
coords = union(coords,coords,'rows');


if(fgflag == 1)
    % Concatenate
    fgpixels = vertcat(fgpixels,coords);
elseif(fgflag == 0)
    % Concatenate
    bgpixels = vertcat(bgpixels,coords);
end
