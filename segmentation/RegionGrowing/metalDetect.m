function metalDetect(image, dMaxDif )

dOPACITY = 0.6;
bManual = false;

%% If the mex file has not been compiled yet, try to do so.
if exist('RegionGrowing_mex', 'file') ~= 3
    fprintf(1, 'Trying to compile mex file...');
    sCurrentPath = cd;
    sPath = fileparts(mfilename('fullpath'));
    cd(sPath)
    try
        mex([sPath, filesep, 'RegionGrowing_mex.cpp']);
        fprintf(1, 'done\n');
    catch
        error('Could not compile the mex file :(. Please try to do so manually!');
    end
    cd(sCurrentPath);
end

%% read input image
if (nargin < 1)
    image=double(imread('.\sampleData\test1.png'));
end

if ndims(image) > 2, error('Input image must be 2D !'); end
if (nargin < 2)
    dMaxDif = 0.05;
end
if ~isscalar(dMaxDif), error('Second input argument (MaxDif) must be a scalar!'); end


%% variance stab
image = sqrt(image);
image = image / max(image(:));

%% total mask
totalMask = zeros(size(image));
totalMask(1:5,:)=1;totalMask(end-5:end,:)=1;
totalMask(:,1:5)=1;totalMask(:,end-5:end)=1;
nLabel = 1;
blobFeatures = [];

while(1)
    %% get seed
    if (bManual)
        iSeed = uint16(fGetSeed(image));
    else
        [Y,I] = min(image(:)+totalMask(:)*1e3);
        [ii jj]=ind2sub(size(image),I);
        iSeed = uint16([ii jj]);
    end
    
    
    if isempty(iSeed)
        figure(1);
        plot(blobFeatures.mean);
        imtool(totalMask)
        return;
    end
    
    %% Start the region growing process by calling the mex function
    if max(image(:)) == min(image(:))
        lMask = true(size(image));
        warning('All image elements have the same value!');
    else
        lMask = RegionGrowing_mex(image, iSeed, dMaxDif);
    end
    
    maxBlobAreaPerc = 0.2;
    bTerminate = (image(iSeed(1),iSeed(2)) > 0.2) | sum(lMask(:)==true)>numel(image)*maxBlobAreaPerc;
    
    if (bTerminate)
        figure(1);
        plot(blobFeatures.mean);
        imtool(totalMask)
        return;
    end
    
    totalMask = totalMask + (lMask==true)*nLabel;
    blobFeatures.mean(nLabel) =  mean(image(lMask));
    nLabel = nLabel+1;
    
    
    %% If no output requested, visualize the result
    if ~nargout
        dImage = image - min(image(:)); % Normalize the dImage
        dImage = dImage./max(dImage(:));
        dImage = permute(dImage, [1 2 4 3]); % Change to RGB-mode
        dImage = repmat(dImage, [1 1 3 1]);
        dMask = double(permute(lMask, [1 2 4 3]));
        dMask = cat(3, dMask, zeros(size(dMask)), zeros(size(dMask))); % Make mask the red channel -> red overlay
        
        dImage = 1 - (1 - dImage).*(1 - dOPACITY.*dMask); % The 'screen' overlay mode
        
        % reduce montage size by selecting the interesting slices, only
        lSlices = squeeze(sum(sum(dMask(:,:,1,:), 1), 2) > 0 );
        figure, montage(dImage(:,:,:,lSlices));
    end
end


end


