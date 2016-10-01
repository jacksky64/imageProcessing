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

function MSEo = MSEest(ORACLE,lambda,PRINT_LEVEL,CONTINUE)

global P

if nargin < 4,
    CONTINUE = 0;
end;

lambdaC = lambda(1);
lambdaD = lambda(2);

if PRINT_LEVEL > 1,
    fprintf('\nlambdaC = %.3e, lambdaD = %.3e\n',lambdaC,lambdaD);
elseif PRINT_LEVEL > 0,
    fprintf('lambdaC = %.3e, lambdaD = %.3e _',lambdaC,lambdaD);
end;

if CONTINUE && exist('P.F3','var'),
    [P.F1,P.F2,P.F3] = vecdenoise3(P.Y1,P.Y2,P.Y3,lambdaC,lambdaD,P.REG_p,P.SOLVER,PRINT_LEVEL,P.F1,P.F2,P.F3);
else,
    [P.F1,P.F2,P.F3] = vecdenoise3(P.Y1,P.Y2,P.Y3,lambdaC,lambdaD,P.REG_p,P.SOLVER,PRINT_LEVEL);
end;

if PRINT_LEVEL > 1,
    fprintf('++ ORACLE ++\n');
elseif PRINT_LEVEL > 0,
    fprintf(' _');
end;

switch ORACLE,
case 'oracle',
    MSEo = 10 * log10(norm(P.Yt1(:)-P.F1(:)).^2 + norm(P.Yt2(:)-P.F2(:)).^2 + norm(P.Yt3(:)-P.F3(:)).^2) - 10*log10(3*prod(P.IY));
case 'none',
    MSEo = nan;
case 'gcv',
    MSEo = MSEest_GCV(lambda,PRINT_LEVEL,P.F1,P.F2,P.F3,trace(P.sigmaNe)/3);
    % XXX for debugging only
    %MSEo_oracle = 10 * log10(norm(P.Yt1(:)-F1(:)).^2 + norm(P.Yt2(:)-F2(:)).^2 + norm(P.Yt3(:)-F3(:)).^2) - 10*log10(3*prod(P.IY));
    %fprintf(' oracle = %f, GCV = %f',MSEo_oracle,MSEo);
case 'sure',
    MSEo = MSEest_SURE(lambda,PRINT_LEVEL,P.F1,P.F2,P.F3,trace(P.sigmaNe)/3);
    % XXX for debugging only
    %MSEo_oracle = 10 * log10(norm(P.Yt1(:)-F1(:)).^2 + norm(P.Yt2(:)-F2(:)).^2 + norm(P.Yt3(:)-F3(:)).^2) - 10*log10(3*prod(P.IY));
    %fprintf(' oracle = %f, SURE = %f',MSEo_oracle,MSEo);
otherwise,
    error('not implemented.');
end;

if PRINT_LEVEL > 0,
    fprintf(' MSEo = % -2.2f dB\n',MSEo);
end;
