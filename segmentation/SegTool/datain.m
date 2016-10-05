function datain(imagefig, varargins)
% DATAIN - This function is used to track and plot the mouse pointer
% location
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global variables referenced in this funciton
global fgflag;

hold on;
% Sample current mouse position, in axes units
temp = get(gca,'currentpoint'); 

% Keep current position in figure property 'USERDATA'
set(gcf,'userdata',[get(gcf,'userdata'); temp(1,1:2), toc  ]);

% Get data for processing
X = get(gcf,'userdata'); 
Len = size(X,1);

% FG or BG seed?
if(fgflag == 1)
    plot(X(Len,1),X(Len,2),'.r'); %%% Plot the last sampled position
elseif(fgflag == 0)
    plot(X(Len,1),X(Len,2),'.b'); %%% Plot the last sampled position
end

