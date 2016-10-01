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

function MSEo = MSEest_SURE(lambda,PRINT_LEVEL,F1,F2,F3,sigma)

global P

sigma2 = sigma*sigma;
%epsi = .01;
epsi = .01*sigma;
Npts = 3*prod(P.IY);

lambdaC = lambda(1);
lambdaD = lambda(2);

% add noise
N1 = randn(P.IY);
N2 = randn(P.IY);
N3 = randn(P.IY);

[FN1,FN2,FN3] = vecdenoise3(P.Y1+epsi*N1,P.Y2+epsi*N2,P.Y3+epsi*N3,lambdaC,lambdaD,P.REG_p,P.SOLVER,PRINT_LEVEL);
divNpts = (N1(:)'*(FN1(:)-F1(:))+N2(:)'*(FN2(:)-F2(:))+N3(:)'*(FN3(:)-F3(:)))/(Npts*epsi);
MSEo = ((norm(P.Y1(:)-F1(:)).^2 + norm(P.Y2(:)-F2(:)).^2 + norm(P.Y3(:)-F3(:)).^2) / Npts) - sigma2 + 2*sigma2*divNpts;
MSEo = 10 * log10(MSEo);
