function [] = SegmentGC(ImName);
%%%Main Grab Cuts segmentation function
global ih_img fgpixels bgpixels;

load segimage;
BiImage = SegImage;
figure;
imagesc(BiImage);
SegImage = [];

I = imread(ImName);
I1 = I(:,:,1);
I2 = I(:,:,2);
I3 = I(:,:,3);

%%%% Final Segmented Image
SegImage = zeros(size(I));

Findices = find(BiImage);
Bindices = find(BiImage == 0);


% Get Foreground and Background Pixels for Smart Refine
FY = fgpixels(:,1);
FX = fgpixels(:,2);

BY = bgpixels(:,1);
BX = bgpixels(:,2);

% LZ
FindicesStr = sub2ind(size(I1),FX,FY);
BindicesStr = sub2ind(size(I1),BX,BY);
size(FindicesStr)
size(BindicesStr)
'indices'

Findices = union(Findices,FindicesStr);
[WrongB WrIndB] = intersect(Bindices,FindicesStr);
size(WrIndB)
'Wrindb'
Bindices(WrIndB) = [];


Bindices = union(Bindices,BindicesStr);
[WrongF WrIndF] = intersect(Findices,BindicesStr);
size(WrIndF)
'Wrinf'
Findices(WrIndF) = [];


L = watershed(I(:,:,1));        %%%% Doing watershed on the red channel -- SEE if you can do it on the color image

%%%%%%%%% Finding Mean colors of the regions  %%%%%%%%%%%%%%%%%%
%%%%% SEE if this can be vectorised  %%%%%%%%%%%%%%%%%%%%%%%%%%%

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
FLabels = union(FLabels,[]);         %% Set-ifying the set of labels (Sorting?)
if(FLabels(1)==0)                   %% Removing Boundary Labels
    FLabels = FLabels(2:end);
end

BLabels = L(int32(Bindices));
BLabels = union(BLabels,[]);         %% Set-ifying the set of labels
if(BLabels(1)==0)                   %% Removing Boundary Labels
    BLabels = BLabels(2:end);
end


% Common labels and indices among GC and LZ
[FIndCom] = intersect(Findices, FindicesStr);
[BIndCom] = intersect(Bindices, BindicesStr);


size(FIndCom)
size(BIndCom)

%%%% BLabels remain fixed -- no change
%%%% ULabels -- Uncertain labels -- on which optimization done...
ULabels = FLabels;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Finding Initial Estimate of foregound and background color clusters %%%%%%%%%%%%

NumFClusters = 5;
NumBClusters = 5;

FColors = MeanColors(FLabels,:);
BColors = MeanColors(BLabels,:);

%%%%%%%%%%% Initializing the GMM's %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Using EM_GM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [FWeights,FCClusters,FCovs,FLikelihood] = EM_GM(FColors,NumFClusters);
% [BWeights,BCClusters,BCovs,BLikelihood] = EM_GM(BColors,NumBClusters);

%%%%%%%%%%% Using Just kmeans %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[FId FCClusters] = vgg_kmeans(FColors, NumFClusters);
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

[BId BCClusters] = vgg_kmeans(BColors, NumBClusters);
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

% % Initialize FDist and BDist with LZ values
% FDist  = zeros(length(FLabels),1);
% BDist  = zeros(length(BLabels),1);



numIter = 6;
for i=1:numIter
    i
    [FDist, FInd] = ClustDistMembership(MeanColors(ULabels,:), FCClusters, FCovs, FWeights);
    [BDist, BInd] = ClustDistMembership(MeanColors(ULabels,:), BCClusters, BCovs, BWeights);

    % Lets hope somebody doesnt choose the same thing as FG and BG, BG will
    % prevail
    FDist(FIndCom) = 0;
    BDist(FIndCom) = 10000;

    FDist(BIndCom) = 10000;
    BDist(BIndCom) = 0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%  The Mex Function for GraphCutSegment %%%%%%%%%%%%
    L = L-1;        %% Segments labeled from 0 now -- -1 is for boundary pixels
    FLabels = FLabels-1;
    BLabels = BLabels-1;
    ULabels = ULabels-1;
    [SegImage LLabels] = GraphCutSegment(L, MeanColors, ULabels, BLabels, FDist, BDist);    %%% SegImage is the segmented image, %%% LLabels is the binary label for each watershed label

    L = L+1;        %% Again Labeled from 1...
    FLabels = FLabels+1;
    BLabels = BLabels+1;
    ULabels = ULabels+1;

    %%%%%%%%%% Showing the intermediate segmentation %%%%%%%%%%%%%%%%%%%%%
    %     edge_img = edge(SegImage,'canny');
    %
    %
    %     figure;
    %     imshow(I);
    %     [IInd,JInd] = ind2sub(size(I1),find(edge_img));
    %     hold on;plot(JInd,IInd,'b.');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if(i<numIter)       %%%%%% Do NOT do this if final iteration -- just display the segmented image
        %%%%%% Making new FLabels and BLabels based on the segmentation %%%%%%
        newFLabels = ULabels(find(LLabels==1.0));
        newBLabels = ULabels(find(LLabels==0.0));

        %         newBLabels = union(newBLabels,BLabels);                 %%%%%% Whether new background labels will contain the old ones?

        FColors = MeanColors(newFLabels,:);
        BColors = MeanColors(newBLabels,:);

        %%%%%%%% Making new GMM's based on new segmentation %%%%%%%%%%%%%%%%%%
        %%%%%%%% Used for defining distances in the next iterative step %%%%%%
        %         [FWeights,FCClusters,FCovs,FLikelihood] = EM_GM(FColors,NumFClusters);
        %         [BWeights,BCClusters,BCovs,BLikelihood] = EM_GM(BColors,NumBClusters);

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

%set position
% data.ui.ah_img = axes('Position',[0.5 0.2 .603 .604]);%,'drawmode','fast');
% data.ui.ih_img = imagesc;
% %set image data
% set(data.ui.ih_img, 'Cdata', SegImage);
% axis('image');axis('ij');axis('off');
% drawnow;

edge_img = edge(SegImage,'canny');



% Put image on black background
SegNewImage1 = zeros(size(SegImage));
SegNewImage2 = zeros(size(SegImage));
SegNewImage3 = zeros(size(SegImage));
idx = find(SegImage);
length(idx)

for(i = 1:length(idx))
    SegNewImage1(int32(idx(i))) = I1(int32(idx(i)));
    SegNewImage2(int32(idx(i))) = I2(int32(idx(i)));
    SegNewImage3(int32(idx(i))) = I3(int32(idx(i)));
end

SegNewImage(:,:,1) = SegNewImage1;
SegNewImage(:,:,2) = SegNewImage2;
SegNewImage(:,:,3) = SegNewImage3;

set(ih_img, 'Cdata', uint8(SegNewImage));
axis('image');axis('ij');axis('off');
drawnow;
figure;
imshow(uint8(SegNewImage));

save segnewimage SegNewImage;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Helper Functions declarations  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FDist, FInd] = ClustDistMembership(MeanColors, FCClusters, FCovs, FWeights)

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
    %     keyboard
end

[FDist, FInd] = min(Ftmp,[],2);
