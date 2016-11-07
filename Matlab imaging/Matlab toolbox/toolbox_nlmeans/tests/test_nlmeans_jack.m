% test NL means denoising
%
%   Copyright (c) 2007 Gabriel Peyre

path(path,'toolbox/');
path(path, 'images/');

%% load the image
name = 'lenacoul';
name = 'barb';
m = 50; n = 90;     % just to show that it works with rectangular images
n = m;
M = load_image(name);
% crop the image
M = rescale( crop(M, [m n]) );

sigma = 0.03; % variance of additional noise
if sigma>0
    % avoid saturation
    M = clamp( rescale(M,sigma,1-sigma) + sigma * randn(size(M)) );
end

%% load real image

 M = im2double(imread('C:\Documents and Settings\jack\Desktop\Dentale\102.png'));
 
%fid = fopen('D:\SolidDetectorImages\Scopia\Mano20\FrmID341_341', 'r');

%d = fread(fid,[1 256],'int8');
%M = fread(fid,[672 672],'int16');
%fclose(fid);

m = 500; n = 500;     % just to show that it works with rectangular images
n = m;
% crop the image
M = rescale( crop(M, [m n], [335 335] ));

fid = fopen('D:\SolidDetectorImages\DSAExamples\Fimiani\p0\5865.raw', 'r');


M = fread(fid,[1024 1024],'int16');
fclose(fid);

m = 500; n = 500;     % just to show that it works with rectangular images
n = m;
% crop the image
M = rescale( crop(M, [m n], [512 512] ));


%% options of NL means
options.k = 3;          % half size for the windows
options.T = 0.02;       % width of the gaussian, relative to max(M(:))  (=1 here)
options.max_dist = 3;   % search width, the smaller the faster the algorithm will be
options.ndims = 30;     % number of dimension used for distance computation (PCA dim.reduc. to speed up)
options.do_patchwise = 0;
options.do_median = 1;  % use median

%% do denoising
tic;
[M1,Wx,Wy] = perform_nl_means(M, options);
toc;

clf;
figure(1);
imagesc(M1);
title('Denoised with nl means');
colormap gray(256);
return;

%% display results
figure(2);
colormap gray(256);
ax = [];
clf;
ch = max([M(:); M1(:)]);
cl = min([M(:); M1(:)]);
ax(1) = subplot(2,2,1);
imagesc(M, [cl ch]); axis image; axis off;
title('Original image');
ax(2) = subplot(2,2,2);
imagesc(M1, [cl ch]); axis image; axis off;
title('Denoised');
ax(3) = subplot(2,2,3);
%imagesc(rescale(M-M1));
imagesc(M-M1, [cl ch]);
title('Removed noise');
ax(4) = subplot(2,2,4);
imagesc(rescale(M-M1));
title('Removed noise rescaled');

axis image; axis off;
if size(M,3)>1
    colormap gray(256);
end
linkaxes(ax,'xy');
return
%%
% compare median filter
A=M;
median3x3 = medfilt2(A);
max3x3 = ordfilt2(A,9,ones(3,3));
A = (max3x3==A).*median3x3 + (max3x3~=A).*A;

median3x3 = medfilt2(A);
max3x3 = ordfilt2(A,9,ones(3,3));
A = (max3x3==A).*median3x3 + (max3x3~=A).*A;

median3x3 = medfilt2(A);
max3x3 = ordfilt2(A,9,ones(3,3));
A = (max3x3==A).*median3x3 + (max3x3~=A).*A;

M1 = A;
figure(4);
clf;
imagesc(M1);
colormap gray(256);

figure(5);
colormap gray(256);
ax = [];
clf;
ch = max([M(:); M1(:)]);
cl = min([M(:); M1(:)]);
ax(1) = subplot(2,2,1);
imagesc(M, [cl ch]); axis image; axis off;
title('Original image');
ax(2) = subplot(2,2,2);
imagesc(M1, [cl ch]); axis image; axis off;
title('Denoised');
ax(3) = subplot(2,2,3);
%imagesc(rescale(M-M1));
imagesc(M-M1, [cl ch]);
title('Removed noise');
ax(4) = subplot(2,2,4);
imagesc(rescale(M-M1));
title('Removed noise rescaled');

axis image; axis off;
if size(M,3)>1
    colormap gray(256);
end
linkaxes(ax,'xy');
%%
% filter compare
filePath='C:\Documents and Settings\jack\Desktop\Dentale\102.png';
fn = '102';
fileName = (fullfile(filePath,[fn '.png]']));
M = im2double(imread(fileName));

iptsetpref('UseIPPL', true);

% median if max
A=M;
for i=1:3
    median3x3 = medfilt2(A);
    max3x3 = ordfilt2(A,9,ones(3,3));
    A = (max3x3==A).*median3x3 + (max3x3~=A).*A;
end
median3x3IfMax = A;

% median 
A=M;
median3x3 = medfilt2(A);

% mean if max
A=M;
for i=1:1
    H = fspecial('average', 3);
    mean3x3 = imfilter(A,H,'replicate');
    max3x3 = ordfilt2(A,9,ones(3,3));
    A = (max3x3==A).*mean3x3 + (max3x3~=A).*A;
end
mean3x3IfMax = A;

fileName = (fullfile(filePath,[fn 'median3x3IfMax.png]']));
imwrite(median3x3IfMax,fileName);

fileName = (fullfile(filePath,[fn 'median3x3.png]']));
imwrite(median3x3,fileName);

fileName = (fullfile(filePath,[fn 'mean3x3IfMax.png]']));
imwrite(mean3x3IfMax,fileName);

figure(5); colormap gray(256);
ax = [];
clf;
ch = max([M(:)]);
cl = min([M(:)]);
ax(1) = subplot(2,2,1);
imagesc(M, [cl ch]); axis image; axis off;
title('Original image');

ax(2) = subplot(2,2,2);
imagesc(median3x3IfMax, [cl ch]); axis image; axis off;
title('median3x3IfMax');

ax(3) = subplot(2,2,3);
imagesc(median3x3, [cl ch]);
title('median3x3');

ax(4) = subplot(2,2,4);
imagesc(mean3x3IfMax, [cl ch]);
title('mean3x3IfMax');

axis image; axis off;
if size(M,3)>1
    colormap gray(256);
end
linkaxes(ax,'xy');

