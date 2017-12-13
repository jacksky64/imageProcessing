% =================================== %
% = Aux file to compile src files   = %
% =================================== %
setenv('MCC_USE_DEPFUN','1'); % set env variable,

files = {'main_SeamlessCloning','main_FiltImage'}; % files to be comp.

% Create a folder to store the compiled programs.
!mkdir ../bin
% first remove old files
!rm ../bin/*

for k = 1:length(files),
    mcc('-m',[files{k} '.m'],'-a','lib','-R','-nodisplay','-d','../bin/')
end

