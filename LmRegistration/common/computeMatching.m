function matchinfo = computeMatching(sourcetransPts, targetPts, params)

% compute mae and std of matching pts

distpts = dist2(sourcetransPts, targetPts);
[mindistpts, indmin]= min(distpts, [], 2);
ind = find(mindistpts <= params.distthreshold^2);

mindist = mindistpts(ind);
sqrtmindist = sqrt(mindist);
matchinfo.mae = sum(sqrtmindist)./size(sqrtmindist,1);
matchinfo.minstd = std(sqrtmindist);
matchinfo.ind = ind;
matchinfo.indmin = indmin;

%
%matchinfo.matchsourcepts = sourcePts(ind, 1:2);
matchinfo.matchtargetpts = targetPts(indmin(ind), 1:2);
matchinfo.matchsourcetranspts = sourcetransPts(ind, 1:2);