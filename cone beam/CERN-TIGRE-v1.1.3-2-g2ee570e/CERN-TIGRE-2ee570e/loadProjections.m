function projections = loadProjections(folder, filesType)

if (~exist(folder,'dir'))
    error ('input folder not found');
end

% Files = dir([folder,'\*.dcm']);
% for idx=1:numel(Files)
%     projections(:,:,idx) = dicomread(Files(idx).name);
% end

filelist = dir(fullfile(folder,filesType));
for cnt = 1 : numel(filelist)
    projections(:,:,cnt) = imread(fullfile(folder,filelist(cnt).name));  
end