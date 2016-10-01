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


% P is the problem context
global P

% solver parameters
P.SOLVER.outer_maxk = 8;     % maximum outer iterations
P.SOLVER.inner_maxk = 600;   % maximum inner iterations
P.SOLVER.inner_eps  = 1e-9;  % inner solver precision
P.SOLVER.epsilon    = 1e-10; % added to numerators and denominators to avoid division by zero

% algorithm parameters
while true
P.REG_p = input('\nregularization norm [1,2]? ', 's');
switch P.REG_p
case {'1','2'}
    P.REG_p = str2num(P.REG_p);
    break;
otherwise
    fprintf('please make a valid choice (1 or 2)\n');
end
end %while true

fprintf('\nyou can choose how to set algorithm parameters lambdaC,lambdaD\n');
fprintf('guess   : ask user to provide values\n');
fprintf('fmin1   : find the best lambda using a funny and rather robust bounded search method\n');
fprintf('fmincon : find the best lambda using MATLAB''s fmincon\n');
fprintf('fmin1 may take longer but prints current best values and you can monitor and stop or resume it at any time\n');

SEARCHMETHOD = lower(input('which do you prefer [GUESS,fmin1,fmincon]? ','s'));
while true
switch SEARCHMETHOD
case {'','guess'}
    SEARCHMETHOD = 'guess';
    while true
    lambda = input('\nplease enter [lambdaC,lambdaD] [MATLAB vector of size 2]: ');
    if length(lambda) == 2
        break;
    else
        fprintf('please provide a MATLAB vector of length 2, enclosed in []\n'); 
    end
    end % while true


    % use the ground truth (if available) to estimate input noise
    if ~any(strcmp('Yt3',fieldnames(P)))
        ORACLE = 'none';
    else
        ORACLE = 'oracle';
    end

    break;

case {'fmin1','fmincon'}
    lambdamin =   .5e-3*[1;1];
    lambdamax = 50.0   *[1;1];
    fprintf('\nthe current search intervals for lambdaC and lambdaD are:\n');
    fprintf('lambdaC: %2.2f .. %2.2f\nlambdaD: %2.2f ..%2.2f\n',lambdamin(1),lambdamax(1),lambdamin(2),lambdamax(2));
    q = lower(input('change [y/N]? ','s'));
    if q == 'y'
        while true
        lambdamin = input('please enter [lambdaCmin,lambdaDmin] [MATLAB vector of size 2]: ');
        if length(lambdamin) == 2
            break;
        else
            fprintf('please provide a MATLAB vector of length 2, enclosed in []\n'); 
        end
        end % while true
        while true
        lambdamax = input('please enter [lambdaCmax,lambdaDmax] [MATLAB vector of size 2]: ');
        if length(lambdamax) == 2
            break;
        else
            fprintf('please provide a MATLAB vector of length 2, enclosed in []\n'); 
        end
        end % while true
    end

    fprintf('\nit is now time to choose the criterion to use for optimizing lambda\n');
    fprintf('the following criteria have been implemented:\n');
    fprintf('oracle : use the ground truth (faster but available only if ground truth is known)\n');
    fprintf('sure   : Stein''s unbiased risk estimate (assumes Gaussian noise)\n');
    fprintf('gcv    : generalized cross validation\n');
    fprintf('oracle is faster and more accurate, but only available if the ground truth is known\n');
    while true
        ORACLE = lower(input('which criterion do you want to use [ORACLE, sure, gcv]? ','s'));
        switch ORACLE 
        case {'','oracle'}
            ORACLE = 'oracle';
            if ~any(strcmp('Yt3',fieldnames(P)))
                fprintf('you cannot use the oracle without providing the ground truth (variables P.Yt1, P.Yt2, P.Yt3)\n');
            else
                break;
            end
        case {'sure','gcv'}
            break;
        otherwise
            fprintf('please make a valid choice\n');
        end
    end % while true

    break

otherwise
end
end % while true

switch SEARCHMETHOD
case 'fmin1'
    fminctxt  = [];
    relerr    = 1e-2;
    objerr    = .2;

case 'fmincon'
    fminconmeth = 'interior-point';
    snrtol      = .01;
    fminconopts = optimset('TolFun',snrtol,'Algorithm',fminconmeth);

otherwise
end
