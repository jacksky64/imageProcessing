function track(imagefig, varargins)
% TRACK - This function is used to track the mouse pointer position
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global Variables
global fgflag;

% Setting figure properties to start tracking
hold on;
if(fgflag == 0 || fgflag == 1)
    set(gcf,'windowbuttondownfcn',@dataout);
    set(gcf,'WindowButtonMotionFcn',@datain);
    set(gcf,'userdata',[]);

    % Begin time measuring (if needed)
    tic;
end


