function [] = SegmentRefine(ImName)
% SEGMENTREFINE  - Main graph cuts segmentation function
% SEGMENTREFINE(IMNAME) - ImName - Image to segment
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global Variables
global sopt ih_img fgpixels bgpixels fgflag segImageHandle;

% GUI specific flag
fgflag = 2;

% Data from GC(AutoCut) or prev GC+LZ(AutoCutRefine)
load('iter_data');

% Stop unnecessary warnings
warning('off','all');

% Read input image
I = imread(ImName);
I1 = I(:,:,1);
I2 = I(:,:,2);
I3 = I(:,:,3);

%%%% Final Segmented Image
SegImage = zeros(size(I));

% LZ
% Get Foreground and Background Pixels for Smart Refine
if(~isempty(fgpixels))
    FY = fgpixels(:,1);
    FX = fgpixels(:,2);
end
if(~isempty(bgpixels))
    BY = bgpixels(:,1);
    BX = bgpixels(:,2);
end

% GC - fp bounding rectangle
load rectpts;

%% Width of Strip
StripWidth = sopt.StripWidth_AC_ACR;

[fxi,fyi] = meshgrid(min(fp(:,1)):max(fp(:,1)),min(fp(:,2)):max(fp(:,2)));
InsideFindices = sub2ind(size(I1),fyi, fxi);
InsideFindices = InsideFindices(:);

%Form the Outside rectangular bounding box -- add StripWidth on all 4 sides

[fxo,fyo] = meshgrid( max((min(fp(:,1)) - StripWidth),1) : min((max(fp(:,1)) + StripWidth), size(I1,2)) , max((min(fp(:,2)) - StripWidth),1) : min((max(fp(:,2)) + StripWidth), size(I1,1)) );
OutsideFindices = sub2ind(size(I1),fyo, fxo);
OutsideFindices = OutsideFindices(:);

Bindices = setdiff(OutsideFindices, InsideFindices);
Allindices = [1:size(I1,1)*size(I1,2)]';
Findices = InsideFindices;

numLabels = max(L(:));
PI = regionprops(L,'PixelIdxList');


%%%% BLabels remain fixed -- no change
%%%% ULabels -- Uncertain labels -- on which optimization done...
ULabels = FLabels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Finding Foreground and Background Labels from pixel seeds%%
try
    if(~isempty(fgpixels))
        FindicesStr = sub2ind(size(I1),FX,FY);
        FLabelsStr = L(int32(FindicesStr));
        FLabelsStr = union(FLabelsStr,[]);         %% Set-ifying the set of labels (Sorting?)
        if(FLabelsStr(1)==0)                   %% Removing Boundary Labels
            FLabelsStr = FLabelsStr(2:end);
        end
        % Get Common label indices to index into fdist and bdist
        [FLabelsCom FIndCom] = intersect(ULabels, FLabelsStr);
    end

    if(~isempty(bgpixels))
        BindicesStr = sub2ind(size(I1),BX,BY);
        BLabelsStr = L(int32(BindicesStr));
        BLabelsStr = union(BLabelsStr,[]);         %% Set-ifying the set of labels
        if(BLabelsStr(1)==0)                   %% Removing Boundary Labels
            BLabelsStr = BLabelsStr(2:end);
        end

        [BLabelsCom BIndCom] = intersect(ULabels, BLabelsStr);
    end
catch
    beep
    disp('Error: Seeds are outside Image limits ...Please restart');
    return;
end

FColors = MeanColors(FLabels,:);
BColors = MeanColors(BLabels,:);
%%%%%%%%%%%% GMM's Initialized %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% The iterative Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda = sopt.lambda_ACR;
numIter = sopt.numIter_ACR;
for i = 1:numIter
    disp(['Iteration - ', num2str(i)]);

    % Foreground and Background edge weights
    [FDist, FInd] = ClustDistMembership(MeanColors(ULabels,:), FCClusters, FCovs, FWeights);
    [BDist, BInd] = ClustDistMembership(MeanColors(ULabels,:), BCClusters, BCovs, BWeights);

    % Hard Seeds
    if(~isempty(fgpixels))
        FDist(FIndCom) = 0;
        BDist(FIndCom) = 1000;
    end

    if(~isempty(bgpixels))
        FDist(BIndCom) = 1000;
        BDist(BIndCom) = 0;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Segments labeled from 0 now -- -1 is for boundary pixels
    L = L-1;
    FLabels = FLabels-1;
    BLabels = BLabels-1;
    ULabels = ULabels-1;
    %%%%%%%%%%%%%  The Mex Function for GraphCutSegment %%%%%%%%%%%%
    %%% SegImage is the segmented image, %%% LLabels is the binary label
    %%% for each watershed label
    [SegImage LLabels] = GraphCutSegment(L, MeanColors, ULabels, BLabels, FDist, BDist, lambda);    %%% SegImage is the segmented image, %%% LLabels is the binary label for each watershed label

    %% Again Labeled from 1...
    L = L+1;
    FLabels = FLabels+1;
    BLabels = BLabels+1;
    ULabels = ULabels+1;

    if(i < numIter)
        %%%%%% Do NOT do this if final iteration -- just display the segmented image
        %%%%%% Making new FLabels and BLabels based on the segmentation %%%%%%
        newFLabels = ULabels(find(LLabels==1.0));
        newBLabels = ULabels(find(LLabels==0.0));

        %%%%%% Whether new background labels will contain the old ones?
        % newBLabels = union(newBLabels,BLabels);

        FColors = MeanColors(newFLabels,:);
        BColors = MeanColors(newBLabels,:);

        %%%%%%%% Calculating FG and BG distances based on new segmentation
        %%%%%%%% %%%%%%%%%%%%%%%%%%

        [newFDists newFInd] = ClustDistMembership(FColors, FCClusters, FCovs, FWeights);
        [newBDists newBInd] = ClustDistMembership(BColors, BCClusters, BCovs, BWeights);

        for k=1:NumFClusters
            relColors = FColors(find(newFInd==k),:);        %% Colors belonging to cluster k
            FCClusters(:,k) = mean(relColors,1)';
            FCovs(:,:,k) = cov(relColors);
            FWeights(1,k) = length(find(newFInd==k)) / length(newFInd);
        end

        for k=1:NumBClusters
            relColors = BColors(find(newBInd==k),:);        %% Colors belonging to cluster k
            BCClusters(:,k) = mean(relColors,1)';
            BCovs(:,:,k) = cov(relColors);
            BWeights(1,k) = length(find(newBInd==k)) / length(newBInd);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%    Display the segmented image   %%%%%%%%%%%%%%%%%%%

edge_img = edge(SegImage,'canny');

% Put image on black background
SegImage = repmat(SegImage,[1,1,3]);
SegNewImage = uint8(SegImage) .* uint8(I);


% Mark a segmentation boundary on original image
% Set the image
[IInd,JInd] = ind2sub(size(I1),find(edge_img));
boundImage1 = I(:,:,2);
boundImage1(find(edge_img)) = 255;
boundImage = I;
boundImage(:,:,2) = boundImage1;

set(ih_img, 'Cdata', uint8(boundImage));
axis('image');axis('ij');axis('off');
drawnow;
figure(segImageHandle);
imshow(uint8(SegNewImage));

SegMask = SegImage;
SegResult = SegNewImage;

% Save Segmentation Result
save('SegResult', 'SegMask', 'SegResult');

% Required for AutoRefine
save('iter_data','L', 'MeanColors', 'FLabels', 'BLabels', 'FCClusters',...
    'FCovs', 'FWeights', 'BCClusters', 'BCovs', 'BWeights');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Helper Functions declarations  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FDist, FInd] = ClustDistMembership(MeanColors, FCClusters, FCovs, FWeights)
% CLUSTDISTMEMBERSHIP - Calcuates FG and BG Distances
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

NumFClusters = size(FCClusters,2);
numULabels = size(MeanColors,1);

FDist = zeros(numULabels,1);
FInd = zeros(numULabels,1);

Ftmp = zeros(numULabels, NumFClusters);

for k=1:NumFClusters
    M = FCClusters(:,k);
    CovM = FCovs(:,:,k);
    W = FWeights(1,k);

    V = MeanColors - repmat(M',numULabels,1);
    Ftmp(:,k) = -log((W / sqrt(det(CovM))) * exp(-( sum( ((V * inv(CovM)) .* V),2) /2)));
end

[FDist, FInd] = min(Ftmp,[],2);
