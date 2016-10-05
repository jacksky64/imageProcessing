function Q = srm_randimseg(map)
% IMSEG Color an image based on the segmentation
%   ISEG = IMSEG(I,LABELS) Labels ISEG with the average color from I of
%   each cluster indicated by LABELS

[M,N] = size(map) ;
Q = zeros(M,N,3) ;

l=unique(map);
for i=1:length(l)
    idx=find(map==l(i));
    b=rand(1,3);
    Q([idx;idx+M*N;idx+2*M*N])=repmat(b,[length(idx) 1]);
end

Q = min(1,Q);