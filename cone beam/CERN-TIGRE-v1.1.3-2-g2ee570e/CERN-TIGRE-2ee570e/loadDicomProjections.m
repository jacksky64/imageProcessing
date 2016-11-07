function projections = loadDicomProjections(folder)

if (~exist(folder,'dir'))
    error ('input folder not found');
end

% Files = dir([folder,'\*.dcm']);
% for idx=1:numel(Files)
%     projections(:,:,idx) = dicomread(Files(idx).name);
% end

dicomlist = dir(fullfile(folder,'*.dcm'));
for cnt = 1 : numel(dicomlist)
    projections(:,:,cnt) = dicomread(fullfile(folder,dicomlist(cnt).name));  
end