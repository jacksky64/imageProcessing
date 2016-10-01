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

EMAIL       = 'me@myhost.invalid';  %% to send email, you will also need to set the send parameters in send_mail.m
SAVEPATH    = './SAVE/';
PRINT_LEVEL = 1;

clc;
fprintf('-------------------------------------------------------\n');
fprintf('vector denoising with rotation-invariant regularization\n');
fprintf('author: Pouya Dehghani Tafti <pouya.tafti@a3.epfl.ch>  \n');
fprintf('        Biomedical Imaging Group, EPFL, Lausanne       \n');
fprintf('        http://bigwww.epfl.ch/                         \n');
fprintf('date:   Feb. 2011                                      \n');
fprintf('-------------------------------------------------------\n\n');

%% initialize
q = lower(input('reset [Y/n]? ','s'));
if q == 'n'
    clear;
else
    q = lower(input('\nload data from .mat file [y/N]? ','s'));
    if q == 'y'
        data;
    else
        phantom;
    end

    setparams;
end

q = input(sprintf('\nsend email alerts to %s (edit EMAIL in demo.m) [y/N]?',EMAIL),'s');
SENDMAIL = (lower(q) == 'y');


%% estimate noise
switch ORACLE
case 'oracle'
    P.sigmaNe(1,1) = norm(P.Y1(:)-P.Yt1(:)) / sqrt(length(P.Y1));
    P.sigmaNe(2,2) = norm(P.Y2(:)-P.Yt2(:)) / sqrt(length(P.Y2));
    P.sigmaNe(3,3) = norm(P.Y3(:)-P.Yt3(:)) / sqrt(length(P.Y3));

case {'none','sure','gcv'}
    P.sigmaNe = sigmaNest(0);

end
fprintf('estimated noise std (%s) = [% 2.3f, %2.3f, %2.3f]\n',ORACLE,P.sigmaNe(1,1),P.sigmaNe(2,2),P.sigmaNe(3,3));


%% find best lambda
tic;
switch SEARCHMETHOD
case 'guess'
case 'fmin1'
    finished=0;
    PRINT_LEVEL = 1;
    while ~finished
        [lambda fminctxt finished] = fmin1(@(l1,l2) MSEest(ORACLE,[l1 l2],PRINT_LEVEL),lambdamin,lambdamax,relerr,objerr,fminctxt,1);
    end;

case 'fmincon'
    lambda = fmincon(@(l) MSEest(ORACLE,l,PRINT_LEVEL),lambda,[],[],[],[],lambdamin,[],[],fminconopts);

end
fprintf('\nbest lambdaC = %.2e, lambdaD = %.2e\n',lambda(1),lambda(2));


%% denoise
PRINT_LEVEL = 2;
MSEo = MSEest(ORACLE,lambda,PRINT_LEVEL);
MSEi = 10*log10(P.sigmaNe(1,1)^2+P.sigmaNe(2,2)^2+P.sigmaNe(3,3)^2);
fprintf('estimated SNR improvement = % -2.2f dB\n',MSEi-MSEo);

elapsedtime = toc;


%% alert and save
if SENDMAIL
    [dummy,host] = system('hostname');
    send_mail(EMAIL, 'vector denoising', sprintf('(%s) phanid = %d, REG_p = %d, ORACLE = %s, MSEi = % -2.2f dB, MSEo = % -2.2f dB [total time: % 2.2f s]',host,phanid,P.REG_p,ORACLE,MSEi,MSEo,elapsedtime));
    q = 'y';
else
    q = lower(input('save .mat and .vtk files [y/N]? ','s'));
end

if q == 'y'
    VTKwrite;
end
