% Statistical Region Merging
%
% Nock, Richard and Nielsen, Frank 2004. Statistical Region Merging. IEEE Trans. Pattern Anal. Mach. Intell. 26, 11 (Nov. 2004), 1452-1458.
% DOI= http://dx.doi.org/10.1109/TPAMI.2004.110

%Segmentation parameter Q; Q small few segments, Q large may segments

function [maps,images]=srm(image,Qlevels)

% Smoothing the image, comment this line if you work on clean or synthetic images
h=fspecial('gaussian',[3 3],1);
image=imfilter(image,h,'symmetric');

smallest_region_allowed=10;

size_image=size(image);
n_pixels=size_image(1)*size_image(2);

% Compute image gradient
[Ix,Iy]=srm_imgGrad(image(:,:,:));
Ix=max(abs(Ix),[],3);
Iy=max(abs(Iy),[],3);
normgradient=sqrt(Ix.^2+Iy.^2);

Ix(:,end)=[];
Iy(end,:)=[];

[~,index]=sort(abs([Iy(:);Ix(:)]));

n_levels=numel(Qlevels);
maps=cell(n_levels,1);
images=cell(n_levels,1);
im_final=zeros(size_image);

map=reshape(1:n_pixels,size_image(1:2));
% gaps=zeros(size(map)); % For future release
treerank=zeros(size_image(1:2));

size_segments=ones(size_image(1:2));
image_seg=image;

%Building pairs
n_pairs=numel(index);
idx2=reshape(map(:,1:end-1),[],1);
idx1=reshape(map(1:end-1,:),[],1);

pairs1=[ idx1;idx2 ];
pairs2=[ idx1+1;idx2+size_image(1) ];

for Q=Qlevels
    iter=find(Q==Qlevels);
    
    for i=1:n_pairs
        C1=pairs1(index(i));
        C2=pairs2(index(i));
        
        %Union-Find structure, here are the finds, average complexity O(1)
        while (map(C1)~=C1 ); C1=map(C1); end
        while (map(C2)~=C2 ); C2=map(C2); end
        
        % Compute the predicate, region merging test
        g=256;
        logdelta=2*log(6*n_pixels);
        
        dR=(image_seg(C1)-image_seg(C2))^2;
        dG=(image_seg(C1+n_pixels)-image_seg(C2+n_pixels))^2;
        dB=(image_seg(C1+2*n_pixels)-image_seg(C2+2*n_pixels))^2;
        
        logreg1 = min(g,size_segments(C1))*log(1.0+size_segments(C1));
        logreg2 = min(g,size_segments(C2))*log(1.0+size_segments(C2));
        
        dev1=((g*g)/(2.0*Q*size_segments(C1)))*(logreg1 + logdelta);
        dev2=((g*g)/(2.0*Q*size_segments(C2)))*(logreg2 + logdelta);
        
        dev=dev1+dev2;
        
        
        predicat=( (dR<dev) && (dG<dev) && (dB<dev) );
        
        
        if (((C1~=C2)&&predicat) ||  xor(size_segments(C1)<=smallest_region_allowed, size_segments(C2)<=smallest_region_allowed))
            % Find the new root for both regions
            if treerank(C1) > treerank(C2)
                map(C2) = C1; reg=C1;
            elseif treerank(C1) < treerank(C2)
                map(C1) = C2; reg=C2;
            elseif C1 ~= C2
                map(C2) = C1; reg=C1;
                treerank(C1) = treerank(C1) + 1;
            end
            
            if C1~=C2
                % Merge regions
                nreg=size_segments(C1)+size_segments(C2);
                image_seg(reg)=(size_segments(C1)*image_seg(C1)+size_segments(C2)*image_seg(C2))/nreg;
                image_seg(reg+n_pixels)=(size_segments(C1)*image_seg(C1+n_pixels)+size_segments(C2)*image_seg(C2+n_pixels))/nreg;
                image_seg(reg+2*n_pixels)=(size_segments(C1)*image_seg(C1+2*n_pixels)+size_segments(C2)*image_seg(C2+2*n_pixels))/nreg;
                size_segments(reg)=nreg;
            end
        end
    end
    
    
    % Done, building two result figures, figure 1 is the segmentation map,
    % figure 2 is the segmentation map with the average color in each segment
    
    
    while 1
        map_ = map(map) ;
        if isequal(map_,map) ; break ; end
        map = map_ ;
    end
    
    
    
    for i=1:3
        im_final(:,:,i)=image_seg(map+(i-1)*n_pixels);
    end
    images{iter}=im_final;
    
    [clusterlist,~,labels] = unique(map)  ;
    labels=reshape(labels,size(map));
    nlabels=numel(clusterlist);
    maps{iter}=map;
    bgradient = sparse(srm_boundarygradient(labels, nlabels, normgradient));
    bgradient = bgradient - tril(bgradient);
    idx=find(bgradient>0);
    [~,index]=sort(bgradient(idx));
    n_pairs=numel(idx);
    [xlabels,ylabels]=ind2sub([nlabels,nlabels],idx);
    pairs1=clusterlist(xlabels);
    pairs2=clusterlist(ylabels);
end










