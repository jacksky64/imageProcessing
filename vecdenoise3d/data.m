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

phanid = -1;

SNRi = nan;
MSEi = nan;

disp('the input .mat file must contain the following variables:');
disp('name       :   name of the dataset');
disp('Y1, Y2, Y3 :   measurements');
while true;
fn = input('what is the name of the data file (with extension)? ','s');
if exist(fn,'file')
    break;
else
    fprintf('file not found.\n');
end
end

dataset = load(fn);

DOWNSAMPLE = input('downsample [factor or enter to use all data]? ');
if isempty(DOWNSAMPLE),
    DOWNSAMPLE = 1;
end;

P.Y1 = dataset.Y1(1:DOWNSAMPLE:end,1:DOWNSAMPLE:end,1:DOWNSAMPLE:end);
P.Y2 = dataset.Y2(1:DOWNSAMPLE:end,1:DOWNSAMPLE:end,1:DOWNSAMPLE:end);
P.Y3 = dataset.Y3(1:DOWNSAMPLE:end,1:DOWNSAMPLE:end,1:DOWNSAMPLE:end);

P.IY = size(P.Y1);
P.name = sprintf('%s_D%01d',dataset.name,DOWNSAMPLE);

clear dataset

while true
fn = input('if you have the ground truth enter name of the data file (with extension) now.  otherwise press enter: ','s');
if isempty(fn) || exist(fn,'file')
    break;
else
    fprintf('file not found.\n');
end
end

if ~isempty(fn),
    dataset = load(fn);

    P.Yt1 = dataset.Y1(1:DOWNSAMPLE:end,1:DOWNSAMPLE:end,1:DOWNSAMPLE:end);
    P.Yt2 = dataset.Y2(1:DOWNSAMPLE:end,1:DOWNSAMPLE:end,1:DOWNSAMPLE:end);
    P.Yt3 = dataset.Y3(1:DOWNSAMPLE:end,1:DOWNSAMPLE:end,1:DOWNSAMPLE:end);
    
    MSEi = 10*log10(norm(P.Y1(:)-P.Yt1(:)).^2+norm(P.Y2(:)-P.Yt2(:)).^2+norm(P.Y3(:)-P.Yt3(:)).^2) - 10*log10(3*prod(P.IY));
    fprintf('MSEi = % -2.2f dB\n',MSEi);
end;

clear dataset
