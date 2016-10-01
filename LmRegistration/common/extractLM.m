function outputPts = extractLM( inputImg, threshold)

% binarize image
biImg = im2bw(inputImg, threshold); %graythresh(Iconf));

% connect components
%cbiImg = bwconncomp(biImg);

% label connect components
lcbiImg = bwlabel(biImg);

% display results
%debug = 0;
%if debug == 1
%    rgb1 = label2rgb(lcbiImg);
%    figure, imshow(rgb1)
%end

% find the center of each connect component
ptssize1 = max(lcbiImg(:));

outputPts = zeros(ptssize1, 2);

for i = 1:ptssize1
    [r, c] = find(lcbiImg == i);
    if size(r,1) > 1
        outputPts(i, 1) = sum(r)/size(r,1);
        outputPts(i, 2) = sum(c)/size(c,1);
    end
end

% elimilate zeros
outputPts(find(outputPts(:,1) == 0),:) = [];
outputPts(find(outputPts(:,2) == 0),:) = [];