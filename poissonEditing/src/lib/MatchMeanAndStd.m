function Iout = MatchMeanAndStd(I,I_ref)
% Iout = MatchMeanAndStd(I,I_ref),
% Correct the dynamic range of I so it matches the mean and variance of the 
% reference image I_ref. This is the normalization chosen in [1] to 
% to have comparable results after applying retinex like algoriths. 
% 
% Inputs>
%   - Iin: HxWxC color of gray input image, 
%   - I_ref: Reference image (from which we extract mean and std)
% Outputs>
%   - Iout: Normalized output image.
% ----------------------------------------------------------------------- %
% refs:
%   [1] Nicolas Limare, Ana Belén Petro, Catalina Sbert, and 
%       Jean-Michel Morel, Retinex Poisson Equation: a Model for Color 
%       Perception, Image Processing On Line, 1 (2011).
%       http://dx.doi.org/10.5201/ipol.2011.lmps_rpe
% ----------------------------------------------------------------------- %
% (c) matias di martino, matiasdm@fing.edu.uy                Paris, 9/2016
% ----------------------------------------------------------------------- %

% -------------------------------------------- %
% - If the input is a color image, compute   - %
% - the method for each channel indep.       - %
% -------------------------------------------- %
I = double(I); I_ref = double(I_ref);

if size(I,3)>1,
    Iout = I; % mem. preloc.
    for c = 1:size(I,3),
        Iout(:,:,c) = MatchMeanAndStd(I(:,:,c),I_ref(:,:,c));
    end
    return
end
% ELSE
% -------------------------------------------- %
% - Perform the norm. for the gray im.       - %
% -------------------------------------------- %
mean_ref = mean(I_ref(:));
std_ref  = std(I_ref(:));

% Remove the current mean of the signal
I = I-mean(I(:)); 

% Amplify/Attenuate I so it matches I_ref standar deviation, 
I = I/std(I(:)) * std_ref;

% Add reference mean,
Iout = I + mean_ref;

end

