% Vector Field Denoising with DIV-CURL Regularization
% 
% Author: Pouya Dehghani Tafti <pouya.tafti@a3.epfl.ch>
%         Biomedical Imaging Group, EPFL, Lausanne
%         http://bigwww.epfl.ch/
% 
% Dates:  08 Feb. 2012 (current release)
%         ?? Feb. 2011 (this implementation)
% 
% References:
% 
% P. D. Tafti and M. Unser, On regularized reconstruction of vector fields,
% IEEE Trans. Image Process., vol. 20, no. 11, pp. 3163–78, 2011.
% 
% P. D. Tafti, R. Delgado-Gonzalo, A. F. Stalder, and M. Unser, Variational
% enhancement and denoising of flow field images, Proc. 8th IEEE Int. Symp.
% Biomed. Imaging (ISBI 2011), pp. 1061–4, Chicago, IL, 2011.

function AFjo = shiftmirror(AFj,e,boundary_conditions);
% AFjo = AFj[.-e] with boundary conditions applied.

I = size(AFj);

if boundary_conditions ~= 'mirror',
    error('not implemented');
end;

s = abs(e(1));
if      e(1) > 0,
    AFjo = cat(1,AFj(s:-1:1,:,:),AFj(1:end-s,:,:));
elseif  e(1) < 0,
    AFjo = cat(1,AFj(s+1:end,:,:),AFj(end:-1:end-s+1,:,:));
end;

s = abs(e(2));
if      e(2) > 0,
    AFjo = cat(2,AFj(:,s:-1:1,:),AFj(:,1:end-s,:));
elseif  e(2) < 0,
    AFjo = cat(2,AFj(:,s+1:end,:),AFj(:,end:-1:end-s+1,:));
end;

s = abs(e(3));
if      e(3) > 0,
    AFjo = cat(3,AFj(:,:,s:-1:1),AFj(:,:,1:end-s));
elseif  e(3) < 0,
    AFjo = cat(3,AFj(:,:,s+1:end),AFj(:,:,end:-1:end-s+1));
end;
