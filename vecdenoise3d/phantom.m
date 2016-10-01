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

% export P,SNRi,MSEi,phanid

% initialize randomizer if cleared.  Otherwise reset to the previous one.
if exist('RST'),
    defaultStream = RandStream.getGlobalStream;
    defaultStream.State = RST;
else
    RandStream.setGlobalStream(RandStream.create('mt19937ar','seed',sum(100*clock)));
    defaultStream = RandStream.getGlobalStream;
    RST=defaultStream.State;
end;

while true
phanid = input('phantom type [1: gradient field, 2: pipes, 3: pipe and torus]? ');
if (phanid == 1) || (phanid == 2) || (phanid == 3)
    break;
end
end

SNRi = [];
while isempty(SNRi);
    SNRi = input('input SNR [dB]? ');
end

P.name = sprintf('3Dphantom%1d_SNRi%02d',phanid,SNRi);

switch phanid,
case 1,
    [P.X1,P.X2,P.X3] = ndgrid(-2:.1:2, -2:.1:2,-2:.1:2);
    phi = P.X1 .* P.X2 .* exp(-P.X1.^2 - P.X2.^2 - P.X3.^2);
    [P.Yt1,P.Yt2,P.Yt3] = gradient(phi,.1,.1,.1);

    P.IY = size(P.Yt1);     % data dimensions

case 2,
    [P.X1,P.X2,P.X3] = ndgrid(-5:.2:5, -5:.2:5,-5:.2:5);
    P.Yt1 = zeros(size(P.X1));
    P.Yt2 = zeros(size(P.X1));
    P.Yt3 = zeros(size(P.X1));

    P.IY = size(P.Yt1);     % data dimensions
    
%   shape1 = (abs(X1) + abs(X2) <= 2);
    shape1 = ((P.X1+1).^2 + (P.X2+1).^2 <= 3);
    shape2 = ((P.X1-3).^2 + (P.X2-3).^2 <= 1);

    P.Yt3(shape1) = 4 - (P.X1(shape1).^2 + P.X2(shape1).^2);
    P.Yt3(shape2) = -4 + 2*(P.X1(shape2).^2 + P.X2(shape2).^2);

case 3,
    [P.X1,P.X2,P.X3] = ndgrid(-5:.4:5, -5:.4:5,-5:.4:5);
    R12 = sqrt(P.X1.^2+P.X2.^2);

    P.Yt1 = zeros(size(P.X1));
    P.Yt2 = zeros(size(P.X1));
    P.Yt3 = zeros(size(P.X1));

    P.IY = size(P.Yt1);     % data dimensions
    
    shape1 = (P.X1.^2 + P.X2.^2 <= 1);
    shape2 = (3 - R12).^2 + P.X3.^2 <= 1;

    P.Yt3(shape1) = 2 - (P.X1(shape1).^2 + P.X2(shape1).^2);

    
    P.Yt1(shape2) = -P.X2(shape2) ./ R12(shape2);
    P.Yt2(shape2) =  P.X1(shape2) ./ R12(shape2);

otherwise,
    error('not implemented.');
end;

% add noise
N1 = randn(P.IY);
N2 = randn(P.IY);
N3 = randn(P.IY);

S = 10*log10(norm(P.Yt1(:)).^2 + norm(P.Yt2(:)).^2 + norm(P.Yt3(:)).^2);
N = 10*log10(norm(N1(:)).^2 + norm(N2(:)).^2 + norm(N3(:)).^2);
sigmaN = 10^((S-N-SNRi)/20);

P.Y1 = P.Yt1 + sigmaN*randn(P.IY);
P.Y2 = P.Yt2 + sigmaN*randn(P.IY);
P.Y3 = P.Yt3 + sigmaN*randn(P.IY);

MSEi = 20*log10(sigmaN) + N - 10*log10(3*prod(P.IY));
fprintf('MSEi = % -2.2f dB\n',MSEi);
