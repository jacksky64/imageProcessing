%--------------------------------------------------------------------------
function  bginput(strg)
% BGINPUT  - This function gets the background pixels from user input
% BGINPUT(STRG) - strg  - Smart Refine or Smart Rectangle
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global variables referenced in this funciton
global fgflag fgbc bgbc fgpixels bgpixels;



if(strcmp(strg,'SmartRectangle'))

    % Gui related flag
    fgflag = 2;

    % Get two points from the user
    bp = ginput(2);
    bp = round(bp);

    % Form the rectangular bounding box from the two points
    [bx,by] = meshgrid(min(bp(:,1)):max(bp(:,1)),min(bp(:,2)):max(bp(:,2)));
    bpixelsx =[];
    bpixelsy =[];
    for(i = 1:size(bx,2))
        bpixelsx = [bpixelsx bx(:,i)'];
        bpixelsy = [bpixelsy by(:,i)'];
    end

    bpixels = [bpixelsx' bpixelsy'];

    % Concatenate
    bgpixels = vertcat(bgpixels,bpixels);

    % Plot the Rectangle
    hfig = gcf;
    axis('image');axis('ij');axis('off');
    hold on;
    plot(bgpixels(:,1),bgpixels(:,2),'b.');

else
    hfig = gcf;
    hold on;

    % Gui related flag
    fgflag = 0;

    % Call track function on button press
    set(hfig,'windowbuttondownfcn',{@track});
end
