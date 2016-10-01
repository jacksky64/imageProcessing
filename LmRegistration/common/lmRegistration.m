
function [matchinfo, lsmatchinfo] = lmRegistration(sourcepts, targetpts, params)
%
%lmRegistration - Landmark/Fiducial based Registraiton
%
%Input:
%       sourcepts: landmarks/fiducials in source image
%       targetpts: lamdmarks/fiducials in target image
%       params   : parameters for registration
%
%Outpup:
%       matchinfo  : registration results without least squares matching
%       lsmatchinfo: registration results with least squares matching
%       minmatchptsind: index of matched landmarks/fiducials in both image
%       minaffinematrix: affine transform matrix
%
%Author:
%       Tian Cao, Department of Computer Science, UNC-Chapel Hill
%

sourceptssize = size(sourcepts,1);
targetptssize = size(targetpts,1);
distmatrixsource = zeros(sourceptssize, sourceptssize);
distmatrixtarget = zeros(targetptssize, targetptssize);

%% generate distance matrix
%for i = 1:sourceptssize
%    for j = 1:sourceptssize
%        distmatrixsource(i,j) = sqrt((sourcepts(i,1)-sourcepts(j,1))^2 ...
%            + (sourcepts(i,2) - sourcepts(j,2))^2);
%    end
% end

distmatrixsource = sqrt(dist2(sourcepts(:,1), sourcepts(:,1)) + ...
    dist2(sourcepts(:,2), sourcepts(:,2)));

%for i = 1:targetptssize
%    for j = 1:targetptssize
%        distmatrixtarget(i,j) = sqrt((targetpts(i,1)-targetpts(j,1))^2 ...
%            + (targetpts(i,2) - targetpts(j,2))^2);
%    end
%end

distmatrixtarget = sqrt(dist2(targetpts(:,1), targetpts(:,1)) + ...
    dist2(targetpts(:,2), targetpts(:,2)));

% find close neighbors for each landmark/fiducial from distance matries
closestneighborsource = zeros(sourceptssize, 3);
closestneighborsourceratio = zeros(sourceptssize, 1);
for i = 1:sourceptssize
    sourcedist = distmatrixsource(i,:);
    [~, I] = sort(sourcedist);
    closestneighborsource(i,1) = i;
    closestneighborsource(i,2) = I(2);
    closestneighborsource(i,3) = I(3);
    
    closestneighborsourceratio(i) = distmatrixsource(i, I(2))/distmatrixsource(i, I(3));
end

%[~, ind] = sort(distmatrixsource, 2);
%closestneighborsource(:,1:3) = ind(:,1:3);
%closestneighborsourceratio(i) = distmatrixsource(:, ind(:,2))./distmatrixsource(:, ind(:,3));

closestneighbortarget = zeros(targetptssize, 3);
closestneighbortargetratio = zeros(targetptssize, 1);
for i = 1:targetptssize
    targetdist = distmatrixtarget(i,:);
    [~, I] = sort(targetdist);
    closestneighbortarget(i,1) = i;
    closestneighbortarget(i,2) = I(2);
    closestneighbortarget(i,3) = I(3);
    
    closestneighbortargetratio(i) = distmatrixtarget(i, I(2))/distmatrixtarget(i, I(3));
end

%% begin registration
affinetransformResult = zeros(size(sourcepts,1)*size(targetpts,1), 9);
ptsind = 0;

if size(sourcepts,1) >= size(targetpts,1)
    validptsnum = size(targetpts,1);
else
    validptsnum = size(sourcepts,1);
end

for i = 1: size(sourcepts,1)
    for j = 1:size(targetpts,1)
        
        
        if (closestneighborsourceratio(i) <= closestneighbortargetratio(j)*(1+params.simithreshold)) ...
                && (closestneighborsourceratio(i) >= closestneighbortargetratio(j)*(1-params.simithreshold))
            A = zeros(6,6);
            B = zeros(6,1);
            %affinematrix = zeros(6,1);
            
            % compute affine transform matrix
            X1 = [sourcepts(closestneighborsource(i,1),2) sourcepts(closestneighborsource(i,1),1)];
            X2 = [sourcepts(closestneighborsource(i,2),2) sourcepts(closestneighborsource(i,2),1)];
            X3 = [sourcepts(closestneighborsource(i,3),2) sourcepts(closestneighborsource(i,3),1)];
            
            A(1,:) = [X1(1) X1(2) 0 0 1 0];
            A(2,:) = [0 0 X1(1) X1(2) 0 1];
            A(3,:) = [X2(1) X2(2) 0 0 1 0];
            A(4,:) = [0 0 X2(1) X2(2) 0 1];
            A(5,:) = [X3(1) X3(2) 0 0 1 0];
            A(6,:) = [0 0 X3(1) X3(2) 0 1];
            
            B(1) = targetpts(closestneighbortarget(j,1),2);
            B(2) = targetpts(closestneighbortarget(j,1),1);
            B(3) = targetpts(closestneighbortarget(j,2),2);
            B(4) = targetpts(closestneighbortarget(j,2),1);
            B(5) = targetpts(closestneighbortarget(j,3),2);
            B(6) = targetpts(closestneighbortarget(j,3),1);
            
            if ~(det(A)==0)
                affinematrix = A\B;
                sourceptstrans = zeros(size(sourcepts,1), size(sourcepts,2));
                
                % transformed source pts
                sourceptstrans(:,2) = sourcepts*[affinematrix(2) affinematrix(1)]' ...
                    + repmat(affinematrix(5),size(sourcepts,1),1);
                sourceptstrans(:,1) = sourcepts*[affinematrix(4) affinematrix(3)]' ...
                    + repmat(affinematrix(6),size(sourcepts,1),1);
                
                % compute dist between transformed source pts and target pts
                distpts = dist2(sourceptstrans, targetpts);
                
                [mindistpts, minind] = min(distpts, [], 2);
                inliernum = numel(unique(minind(find(mindistpts <= params.distthreshold^2))));
                %display([i, j, inliernum]);
                
                ptsind = ptsind + 1;
                affinetransformResult(ptsind, 1:2) = [i j];
                [sortedmindispts, ind] = sort(mindistpts);
                if ~params.checkinliner == 1
                    affinetransformResult(ptsind, 3) = median(sortedmindispts(1:validptsnum));
                else
                    affinetransformResult(ptsind, 3) = inliernum;
                end
                %affinetransformResult(ptsind, 3) = median(mindistpts(1:validptsnum));
                %affinetransformResult(ptsind, 3) = sortedmindispts(5);
                affinetransformResult(ptsind, 4:end) = affinematrix;
            end
        end
    end
end

affinetransformResult(find(affinetransformResult(:,1) == 0),:) = [];

if ~params.checkinliner == 1
    [~, mind] = min(affinetransformResult(:, 3), [], 1);
else
    [~, mind] = max(affinetransformResult(:, 3), [], 1);
end
%mind = 55;
%mind = 45;
matchptsind = affinetransformResult(mind, 1:2);
affinematrix = affinetransformResult(mind, 4:end);


% transformed source pts
sourceptstrans = ptsTransform( sourcepts, affinematrix);

%% computer mae and std of matching pts
matchinfo = computeMatching(sourceptstrans, targetpts, params);
matchinfo.matchsourcepts = sourcepts(matchinfo.ind, 1:2);
matchinfo.sourceptstrans = sourceptstrans;
matchinfo.affinematrix = affinematrix;
matchinfo.matchptsind = matchptsind;

%% least square affine registration

if params.leastsquares == 1
      
    ind = matchinfo.ind;
    indmin = matchinfo.indmin;
    
    % for debug
    if params.debug == 1
        % display matching pts
        matchinfo.matchsourcetranspts = sourceptstrans(ind, 1:2);
        figure
        plot(matchinfo.matchtargetpts(:, 2), matchinfo.matchtargetpts(:, 1), 'r+');
        hold on
        plot(matchinof.matchsourcetranspts(:,2), matchinof.matchsourcetranspts(:,1), 'b*');
    end
    
    matchptssize = size(matchinfo.matchsourcepts,1);
    A = zeros(2*matchptssize, 6);
    B = zeros(2*matchptssize, 1);
    
    A(1:matchptssize, :) = [matchinfo.matchsourcepts(:,2) matchinfo.matchsourcepts(:,1) zeros(matchptssize,1) ...
        zeros(matchptssize,1) ones(matchptssize,1) zeros(matchptssize,1)];
    A(matchptssize+1:end, :) = [zeros(matchptssize,1) zeros(matchptssize,1) matchinfo.matchsourcepts(:,2)...
        matchinfo.matchsourcepts(:,1) zeros(matchptssize,1) ones(matchptssize, 1)];
    
    B(1:matchptssize) = matchinfo.matchtargetpts(:,2);
    B(matchptssize+1:end) = matchinfo.matchtargetpts(:,1);
    
    if ~(det(A'*A)==0)
        minaffinematrix = (A'*A)\(A'*B);
        minmatchptsind = [ind indmin(ind)];
    else
        minaffinematrix = affinematrix;
        minmatchptsind = matchptsind;
    end
    
    lssourceptstrans = ptsTransform( sourcepts, minaffinematrix);
    
    %% compute mae and std of matching pts
    
    lsmatchinfo = computeMatching(lssourceptstrans, targetpts, params);
    lsmatchinfo.matchsourcepts = sourcepts(lsmatchinfo.ind, 1:2);
    %lsmatchinfo.matchtargetpts = targetpts()
    lsmatchinfo.sourceptstrans = lssourceptstrans;
    lsmatchinfo.affinematrix = minaffinematrix;
    lsmatchinfo.matchptsind = minmatchptsind;
    
else
    
    %minaffinematrix = affinematrix;
    %minmatchptsind = matchptsind;
    
    lsmatchinfo = matchinfo;
    
end
