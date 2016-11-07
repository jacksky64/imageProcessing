%IM_GAUSS Gaussian filter of images stored in a dataset/datafile (Matlab)
%
%	B = IM_GAUSS(A,SX,SY)
%	B = A*IM_GAUSS([],SX,SY)
%
% INPUT
%   A     Dataset with object images dataset (possibly multi-band)
%   SX    Desired horizontal standard deviation for filter, default SX = 1
%   SY    Desired vertical standard deviation for filter, default SY = SX
%
% OUTPUT
%   B     Dataset/datafile with Gaussian filtered images
%
% DESCRIPTION
% All, possibly multi-band, 2D images in A are Gaussian filtered using the
% Matlab command CONV2. In case DIPImage is available, IM_GAUSSF may be
% used instead for faster processing.
%
% SEE ALSO
% DATASETS, DATAFILES, IM_GAUSSF, FILTIM

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


function b = im_gauss(a,sx,sy)

	prtrace(mfilename);
	
  if nargin < 3, sy = []; end
	if nargin < 2 | isempty(sx), sx = 1; end
  if isempty(sy), sy = sx; end
	
  if nargin < 1 | isempty(a)
    b = mapping(mfilename,'fixed',{sx,sy});
    b = setname(b,'Gaussian filter');
	elseif isa(a,'dataset') % allows datafiles too
		isobjim(a);
    b = filtim(a,mfilename,{sx,sy});
  elseif isa(a,'double')  % here we have a single image
    if sx == 0
      fx = 1;
    else
      rx = round(3*sx);
      fx = exp((-[-rx:1:rx].^2)/(2*sx*sx)); fx = fx/sum(fx);
    end
    if sy == 0
      fy = 1;
    else
      ry = round(3*sy);
      fy = exp((-[-ry:1:ry].^2)/(2*sy*sy)); fy = fy/sum(fy);
    end
		n = size(a,3);
		b = zeros(size(a));
		for j=1:n
    	b = conv2(fy,fx,a(:,:,j),'full');
    	%b(:,:,j) = conv2(fy,fx,a(:,:,j),'same');
		end
	end
	
return
