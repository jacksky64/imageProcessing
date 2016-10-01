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

function sigmaNe = sigmaNest(SIGMANEST)

global P

sigmaNe = zeros(3,3);

H = P.Y1;
H = (H(1:end-1,:,:) - H(2:end,:,:))/sqrt(2);
H = (H(:,1:end-1,:) - H(:,2:end,:))/sqrt(2);
H = (H(:,:,1:end-1) - H(:,:,2:end))/sqrt(2);
sigmaNe(1,1) = mad(H(:),1)/0.6745;

H = P.Y2;
H = (H(1:end-1,:,:) - H(2:end,:,:))/sqrt(2);
H = (H(:,1:end-1,:) - H(:,2:end,:))/sqrt(2);
H = (H(:,:,1:end-1) - H(:,:,2:end))/sqrt(2);
sigmaNe(2,2) = mad(H(:),1)/0.6745;

H = P.Y3;
H = (H(1:end-1,:,:) - H(2:end,:,:))/sqrt(2);
H = (H(:,1:end-1,:) - H(:,2:end,:))/sqrt(2);
H = (H(:,:,1:end-1) - H(:,:,2:end))/sqrt(2);
sigmaNe(3,3) = mad(H(:),1)/0.6745;
