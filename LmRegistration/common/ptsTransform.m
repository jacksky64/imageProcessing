function transpts = ptsTransform(inputPts, transMatrix)


transpts(:,2) = inputPts*[transMatrix(2) transMatrix(1)]' ...
                    + repmat(transMatrix(5),size(inputPts,1),1);
transpts(:,1) = inputPts*[transMatrix(4) transMatrix(3)]' ...
                    + repmat(transMatrix(6),size(inputPts,1),1);