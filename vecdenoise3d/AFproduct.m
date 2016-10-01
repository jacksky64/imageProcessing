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

function [AF1,AF2,AF3] = AFproduct(cinv,dinv,lambdaC,lambdaD,F1,F2,F3,epsilon)

% this is slightly less efficient but cleaner
[d1F1,d2F1,d3F1] = findiff3(F1,'mirror');
[d1F2,d2F2,d3F2] = findiff3(F2,'mirror');
[d1F3,d2F3,d3F3] = findiff3(F3,'mirror');

% curl part
%CCF1 = lambdaC * (d2F1-d1F2 + d3F1-d1F3 + epsilon) ./ (cinv + epsilon);
%CCF2 = lambdaC * (d1F2-d2F1 + d3F2-d2F3 + epsilon) ./ (cinv + epsilon);
%CCF3 = lambdaC * (d1F3-d3F1 + d2F3-d3F2 + epsilon) ./ (cinv + epsilon);

% CCFki
tmp = lambdaC * (d2F1-d1F2 + epsilon/2) ./ (cinv + epsilon);
CCF12 =  tmp - shiftmirror(tmp,[0 -1 0],'mirror');
CCF21 = -tmp + shiftmirror(tmp,[-1 0 0],'mirror');

tmp = lambdaC * (d3F1-d1F3 + epsilon/2) ./ (cinv + epsilon);
CCF13 =  tmp - shiftmirror(tmp,[0 0 -1],'mirror');
CCF31 = -tmp + shiftmirror(tmp,[-1 0 0],'mirror');

tmp = lambdaC * (d3F2-d2F3 + epsilon/2) ./ (cinv + epsilon);
CCF23 =  tmp - shiftmirror(tmp,[0 0 -1],'mirror');
CCF32 = -tmp + shiftmirror(tmp,[0 -1 0],'mirror');

AF1 = CCF12 + CCF13;
AF2 = CCF21 + CCF23;
AF3 = CCF31 + CCF32;

% div part

DDFt = lambdaD * (d1F1 + d2F2 + d3F3 + epsilon) ./ (dinv + epsilon);

AF1 = F1 + AF1 + DDFt - shiftmirror(DDFt,[-1 0 0],'mirror');
AF2 = F2 + AF2 + DDFt - shiftmirror(DDFt,[0 -1 0],'mirror');
AF3 = F3 + AF3 + DDFt - shiftmirror(DDFt,[0 0 -1],'mirror');
