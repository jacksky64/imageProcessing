function [] = SegmentGC(ImName, ih, alg)
% SEGMENTGC  - Main GrabCut segmentation function
% SEGMENTGC(IMNAME, IH, ALG) - ImName - Image to segment
% IH - Image Handle
% ALG - AutoCut or AutoRefine (0 or 1)
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15

% Global Variables
global sopt segImageHandle;

% Read input image
I = imread(ImName);
I1 = I(:,:,1);
I2 = I(:,:,2);
I3 = I(:,:,3);

% Final Segmented Image
SegImage = zeros(size(I));

% Stop unnecessary warnings
warning('off','all');

%%%%%%% Marking the Inner Rectangle around the foreground object
%%%%%%% Get two points from the user
% Set the image
set(ih, 'Cdata', I);
axis('image');axis('ij');axis('off');
drawnow;

fp = ginput(2);
fp = round(fp);

% Save the points for future use
save rectpts fp;

% Width of Strip
StripWidth = sopt.StripWidth_AC_ACR;       

% Get inner indices
[fxi,fyi] = meshgrid(min(fp(:,1)):max(fp(:,1)),min(fp(:,2)):max(fp(:,2)));
InsideFindices = sub2ind(size(I1),fyi, fxi);
InsideFindices = InsideFindices(:);

% Form the Outside rectangular bounding box -- add StripWidth on all 4 sides
[fxo,fyo] = meshgrid( max((min(fp(:,1)) - StripWidth),1) : min((max(fp(:,1)) + StripWidth), size(I1,2)) , max((min(fp(:,2)) - StripWidth),1) : min((max(fp(:,2)) + StripWidth), size(I1,1)) );
OutsideFindices = sub2ind(size(I1),fyo, fxo);
OutsideFindices = OutsideFindices(:);

Bindices = setdiff(OutsideFindices, InsideFindices);
Allindices = [1:size(I1,1)*size(I1,2)]';
Findices = InsideFindices;

% Water shed pixels
L = watershed(I(:,:,1));

%%%%%%%%% Finding Mean colors of the regions  %%%%%%%%%%%%%%%%%%
numLabels = max(L(:));
PI = regionprops(L,'PixelIdxList');

MeanColors = zeros(numLabels,3);
for i=1:numLabels
    MeanColors(i,1) = mean(I1(PI(i).PixelIdxList));
    MeanColors(i,2) = mean(I2(PI(i).PixelIdxList));
    MeanColors(i,3) = mean(I3(PI(i).PixelIdxList));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Finding Foreground and Background Labels from pixels%%

FLabels = L(int32(Findices));
FLabels = union(FLabels,[]);         %% Set-ifying the set of labels (Sorting)
if(FLabels(1)==0)                   %% Removing Boundary Labels
    FLabels = FLabels(2:end);
end

BLabels = L(int32(Bindices));
BLabels = union(BLabels,[]);         %% Set-ifying the set of labels
if(BLabels(1)==0)                   %% Removing Boundary Labels
    BLabels = BLabels(2:end);
end

%%%% BLabels remain fixed -- no change
%%%% ULabels -- Uncertain labels -- on which optimization done...
ULabels = FLabels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Finding Initial Estimate of foregound and background color clusters %%%%%%%%%%%%

NumFClusters = sopt.NumFClusters_AC;
NumBClusters = sopt.NumBClusters_AC;

FColors = MeanColors(FLabels,:);
BColors = MeanColors(BLabels,:);

%%%%%%%%%%% Initializing the GMM's %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Using Just kmeans %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[FId FCClusters] = kmeans(FColors, NumFClusters);
Fdim = size(FColors,2);

FCClusters = zeros(Fdim, NumFClusters);
FWeights = zeros(1,NumFClusters);
FCovs = zeros(Fdim, Fdim, NumFClusters);
for k=1:NumFClusters
    relColors = FColors(find(FId==k),:);        %% Colors belonging to cluster k
    FCClusters(:,k) = mean(relColors,1)';
    FCovs(:,:,k) = cov(relColors);
    FWeights(1,k) = length(find(FId==k)) / length(FId);
end

[BId BCClusters] = kmeans(BColors, NumBClusters);
Bdim = size(BColors,2);

BCClusters = zeros(Bdim, NumBClusters);
BWeights = zeros(1,NumBClusters);
BCovs = zeros(Bdim, Bdim, NumBClusters);
for k=1:NumBClusters
    relColors = BColors(find(BId==k),:);        %% Colors belonging to cluster k
    BCClusters(:,k) = mean(relColors,1)';
    BCovs(:,:,k) = cov(relColors);
    BWeights(1,k) = length(find(BId==k)) / length(BId);
end

%%%%%%%%%%%% GMM's Initialized %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% The iterative Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda = sopt.lambda_AC;
numIter = sopt.numIter_AC;
for i = 1:numIter
    disp(['Iteration - ', num2str(i)]);

    % Foreground and Background edge weights
    [FDist, FInd] = ClustDistMembership(MeanColors(ULabels,:), FCClusters, FCovs, FWeights);
    [BDist, BInd] = ClustDistMembership(MeanColors(ULabels,:), BCClusters, BCovs, BWeights);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Segments labeled from 0 now -- -1 is for boundary pixels
    L = L-1;
    FLabels = FLabels-1;
    BLabels = BLabels-1;
    ULabels = ULabels-1;
    %%%%%%%%%%%%%  The Mex Function for GraphCutSegment %%%%%%%%%%%%
    %%% SegImage is the segmented image, %%% LLabels is the binary label
    %%% for each watershed label
    [SegImage LLabels] = GraphCutSegment(L, MeanColors, ULabels, BLabels,...
        FDist, BDist, lambda);

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

        %%%%%%%% Calculating FG and BG distances based on new segmentation %%%%%%%%%%%%%%%%%%
        [newFDists newFInd] = ClustDistMembership(FColors, FCClusters, FCovs, FWeights);
        [newBDists newBInd] = ClustDistMembership(BColors, BCClusters, BCovs, BWeights);

        for k = 1:NumFClusters
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

% If AutoCut, just show the image
if(~alg)    
    figure;
    imshow(uint8(SegNewImage));
else
    % If AutoRefine mark a segmentation boundary on original image
    [IInd,JInd] = ind2sub(size(I1),find(edge_img));
    boundImage1 = I(:,:,2);
    boundImage1(find(edge_img)) = 255;
    boundImage = I;
    boundImage(:,:,2) = boundImage1;
    
    % Set the image
    set(ih, 'Cdata', uint8(boundImage));
    axis('image');axis('ij');axis('off');
    drawnow;
    segImageHandle = figure;
    imshow(uint8(SegNewImage));
end
SegMask = SegImage;
SegResult = SegNewImage;

% Save Segmentation Result
save('SegResult', 'SegMask', 'SegResult');

% Required for AutoCutRefine
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

for k = 1:NumFClusters
    M = FCClusters(:,k);
    CovM = FCovs(:,:,k);
    W = FWeights(1,k);

    V = MeanColors - repmat(M',numULabels,1);
    Ftmp(:,k) = -log((W / sqrt(det(CovM))) * exp(-( sum( ((V * inv(CovM)) .* V),2) /2)));

end

[FDist, FInd] = min(Ftmp,[],2);
