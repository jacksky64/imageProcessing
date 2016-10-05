function  fginput(strg)
% FGINPUT  - This function gets the foreground pixels from user inputn
% FGINPUT(STRG) - strg  - Smart Refine or Smart Rectangle
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15


% Global variables referenced in this funciton
global sopt fgflag fgpixels bgpixels;

% If using the SmartRectangle Function
if(strcmp(strg,'SmartRectangle'))

    % GUI related flag
    fgflag = 2;

    % Get two points from the user
    fp = ginput(2);
    fp = round(fp);

    % Form the rectangular bounding box from the two points
    [fx,fy] = meshgrid(min(fp(:,1)):max(fp(:,1)),min(fp(:,2)):max(fp(:,2)));
    fpixelsx =[];
    fpixelsy =[];
    for(i = 1:size(fx,2))
        fpixelsx = [fpixelsx fx(:,i)'];
        fpixelsy = [fpixelsy fy(:,i)'];
    end
    fpixels = [fpixelsx' fpixelsy'];

    % Add to previous strokes
    fgpixels = vertcat(fgpixels,fpixels);

    % Plot the Rectangle
    hfig = gcf;
    axis('image');axis('ij');axis('off');
    hold on;
    plot(fgpixels(:,1),fgpixels(:,2),'r.');

else
    hfig = gcf;
    hold on;

    % Gui related flag
    fgflag = 1;

    % Call track function on button press
    set(hfig,'windowbuttondownfcn',{@track});
end