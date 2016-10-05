function sopt = mksopt
% MKSOPT - Initializes all constants associated with the Segmentation task
% Anything and everything that needs to be tweaked is here.
% Authors - Mohit Gupta, Krishnan Ramnath
% Affiliation - Robotics Institute, CMU, Pittsburgh
% 2006-05-15


% Lambda value and number of iterations for AutoCut (GrabCut) Tool
% (SegmentGC.m)
% Lamdba refers to the relative weightage between the region and the
% boundary term in the graph cut minimization function. Higher values of
% lambda favors more region ie more grouping.
% Lambda is probably the most important parameter and can be tweaked to get
% a good segmentation
sopt.lambda_AC = 0.9;

% Numer of iterations the grab cut algorithm should run. Higher values are
% usually good, but only upto a certain limit, no point in iterating when
% the algorithm has converged.
sopt.numIter_AC = 12;

% Lambda value and number of iterations for 
% AutoCutRefine (GrabCut + Lazy Snapping) Tool 
% (SegmentRefine.m)
% This parameter is the lambda value for the refine ment step. We usually
% want higher lambdas for refinement (more coherent regions.)
sopt.lambda_ACR = 5;

% Number of iterations for the refinement step. This should usually be just
% one
sopt.numIter_ACR = 1;


% Number of clusters used by kmeans for SmartSelect (Lazy Snapping) Tool
% (Segment.m)
sopt.NumFClusters_SS = 60;
sopt.NumBClusters_SS = 60;

% Strip width specifying background pixels for AutoCut (GrabCut) 
% and AutoCutRefine (GrabCut + Lazy Snapping) Tool
% (SegmentGC.m and SegmentRefine.m)
sopt.StripWidth_AC_ACR = 30;   

% Number of clusters used by kmeans for AutoCut (GrabCut) Tool
% (SegmentGC.m)
sopt.NumFClusters_AC = 5;
sopt.NumBClusters_AC = 5;


