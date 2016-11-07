%SHIFTOP Shift operating point of classifier
%
%		S = SHIFTOP(D,E,C)
%   S = SHIFTOP([],E,C);
%
% INPUT
%   D      Dataset, classification matrix (two classes only)
%   E      Desired error class N for D*TESTC
%   C      Index of desired class (default: C = 1)
%
% OUTPUT
%   S      Mapping, such that E = TESTC(D*S,[],LABEL)
%
% DESCRIPTION
% If D = A*W, with A a test dataset and W a trained classifier, then an ROC
% curve can be computed and plotted by ER = ROC(D,C), PLOTE(ER). C is the
% desired class number for which the error is plotted along the horizontal 
% axis.
% The classifier W can be given any operating point along this curve by
% W = W*SHIFTOP(D,E,C)
%
% The class index C refers to its position in the label list of the dataset
% A used for training the classifier that yielded D. The relation to LABEL
% is LABEL = CLASSNAME(A,C); C = GETCLASSI(A,LABEL).
%
% SEE ALSO 
% DATASETS, MAPPINGS, TESTC, ROC, PLOTE, CLASSNAME, GETCLASSI

function w = shiftop(d,e,n)

isdataset(d);

if any(any(+d)) < 0
	error('Classification matrix should have non-negative entries only')
end

[m,c] = size(d);
if c ~= 2
	error('Only two-class classification matrices are supported')
end

if nargin < 3 | isempty(n)
	n = 1;
end

s = classsizes(d);
d = seldat(d,n)*normm;
[~,L] = sort(+d(:,n));
k = floor(e*s(n));
k = max(k,1);    % avoid k = 0
alf = +(d(L(k),:)+d(L(k+1),:))/2;
if n == 1
	w = diag([alf(2)/alf(1) 1]);
else
	w = diag([1 alf(1)/alf(2)]);
end
w = affine(w);