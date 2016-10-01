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

function [F1,F2,F3] = vecdenoise3(Y1,Y2,Y3,lambdaC,lambdaD,REG_p,SOLVER,PRINT_LEVEL,F1,F2,F3)
%
% function [F1,F2,F3] = vecdenoise3(Y1,Y2,Y3,lambdaC,lambdaD,REG_p,SOLVER,PRINT_LEVEL)
%
% REG_p == 1 -> L1 regularization, REG_p ==2 -> L2 regularization
% SOLVER.outer_maxk, SOLVER.inner_maxk, SOLVER.inner_eps : iteration parameters
% SOLVER.epsilon is added to numerators and denuminators to avoid division by zero

IY = size(Y1);

if nargin < 11,
    F1 = zeros(IY);
    F2 = zeros(IY);
    F3 = zeros(IY);
end;

% OUTER MM ITERATION
ko = 0;
while 1, % outer
    ko = ko + 1;
    if ko > SOLVER.outer_maxk,
        break;
    end;
    if PRINT_LEVEL > 1,
        fprintf('== %d ==\n',ko);
    elseif PRINT_LEVEL > 0,
        if mod(ko,10) == 0,
            fprintf('o');
        else,
            fprintf('.');
        end;
    end;


    % diffs
    [d1F1,d2F1,d3F1] = findiff3(F1,'mirror');
    [d1F2,d2F2,d3F2] = findiff3(F2,'mirror');
    [d1F3,d2F3,d3F3] = findiff3(F3,'mirror');

    % div
    DF = d1F1 + d2F2 + d3F3;

    % curl
    CF1 = d3F2 - d2F3;
    CF2 = d1F3 - d3F1;
    CF3 = d2F1 - d1F2;

    if ko == 1, % zero initialization
        AF1 = F1;
        AF2 = F2;
        AF3 = F3;

        dinv = ones(size(AF1));
        cinv = ones(size(AF1));
    else,
        % weights
        switch REG_p,
        case 1,
            dinv = abs(DF);
            cinv = sqrt(CF1.^2 + CF2.^2 + CF3.^2);
            if PRINT_LEVEL > 1,
                fprintf('J[L1] in = %2.3f\n',norm(F1(:)-Y1(:))^2+norm(F2(:)-Y2(:))^2+norm(F3(:)-Y3(:))^2+lambdaC*sum(cinv(:))+lambdaD*sum(dinv(:)));
            end;
        case 2,
            dinv = 1;
            cinv = 1;
        otherwise,
            error('not implemented.');
        end;

        % matrix-vector product
        [AF1,AF2,AF3] = AFproduct(cinv,dinv,lambdaC,lambdaD,F1,F2,F3,SOLVER.epsilon);
    end;

    % INNER CG ITERATION
    % local variables k r1,r2,r3,rr,rr_new p1,p2,p3,pAp  alpha,beta

    r1 = Y1 - AF1;
    r2 = Y2 - AF2;
    r3 = Y3 - AF3;
    rr = r1(:)'*r1(:) + r2(:)'*r2(:) + r3(:)'*r3(:);

    p1 = r1;
    p2 = r2;
    p3 = r3;

    for ki=1:SOLVER.inner_maxk, % inner
        if PRINT_LEVEL > 1,
        if mod(ki,10) == 0,
            fprintf('o');
        else,
            fprintf('.');
        end;
        end;

        [Ap1,Ap2,Ap3] = AFproduct(cinv,dinv,lambdaC,lambdaD,p1,p2,p3,SOLVER.epsilon);

        pAp = p1(:)'*Ap1(:) + p2(:)'*Ap2(:) + p3(:)'*Ap3(:);
        alpha = rr/pAp;

        F1 = F1 + alpha*p1;
        F2 = F2 + alpha*p2;
        F3 = F3 + alpha*p3;
        
        r1 = r1 - alpha*Ap1;
        r2 = r2 - alpha*Ap2;
        r3 = r3 - alpha*Ap3;
        rr_new = r1(:)'*r1(:) + r2(:)'*r2(:) + r3(:)'*r3(:);

        beta = rr_new/rr;

        if sqrt(rr_new) < SOLVER.inner_eps, % fixme XXX replace by cond on beta
            break;
        end;

        p1 = r1 + beta*p1;
        p2 = r2 + beta*p2;
        p3 = r3 + beta*p3;

        rr = rr_new;
    end; %inner
    if PRINT_LEVEL > 1,
        fprintf(' (%d)\n',ki);
    end;

end; % outer

