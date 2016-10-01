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

fn = sprintf('%s_L%1d_%s',P.name,P.REG_p,demo);
fn = [SAVEPATH fn];

save([fn '.mat']);

%fid0 = fopen([fn '_0.vtk'],'w');
fidi = fopen([fn '_i.vtk'],'w');
fido = fopen([fn '_o.vtk'],'w');
if fidi == -1 || fido == -1,
    error('file i/o error.');
end;

%fprintf(fid0,'# vtk DataFile Version 2.0\n');
fprintf(fidi,'# vtk DataFile Version 2.0\n');
fprintf(fido,'# vtk DataFile Version 2.0\n');

%fprintf(fid0,'original data: phanid=%d, SNRi=%2.3f dB, REG_p=%d, lambdaC=%2.3f, lambdaD=%2.3f, MSEi=%2.3d fB, MSEo=%2.3f\n',phanid,SNRi,P.REG_p,lambda(1),lambda(2),MSEi,MSEo);
fprintf(fidi,'noisy data: phanid=%d, SNRi=%2.3f dB, REG_p=%d, lambdaC=%2.3f, lambdaD=%2.3f, MSEi=%2.3d fB, MSEo=%2.3f dB\n',phanid,SNRi,P.REG_p,lambda(1),lambda(2),MSEi,MSEo);
fprintf(fido,'denoised data: phanid=%d, SNRi=%2.3f dB, REG_p=%d, lambdaC=%2.3f, lambdaD=%2.3f, MSEi=%2.3d fB, MSEo=%2.3f dB\n',phanid,SNRi,P.REG_p,lambda(1),lambda(2),MSEi,MSEo);

%fprintf(fid0,'ASCII\n');
fprintf(fidi,'ASCII\n');
fprintf(fido,'ASCII\n');

%fprintf(fid0,'DATASET STRUCTURED_POINTS\n');
fprintf(fidi,'DATASET STRUCTURED_POINTS\n');
fprintf(fido,'DATASET STRUCTURED_POINTS\n');

%fprintf(fid0,'DIMENSIONS %i %i %i\n',size(P.F1,1),size(P.F1,2),size(P.F1,3));
fprintf(fidi,'DIMENSIONS %i %i %i\n',size(P.F1,1),size(P.F1,2),size(P.F1,3));
fprintf(fido,'DIMENSIONS %i %i %i\n',size(P.F1,1),size(P.F1,2),size(P.F1,3));

%fprintf(fid0,'ORIGIN %f %f %f\n',0,0,0);
fprintf(fidi,'ORIGIN %f %f %f\n',0,0,0);
fprintf(fido,'ORIGIN %f %f %f\n',0,0,0);

%fprintf(fid0,'SPACING %f %f %f\n',1,1,1);
fprintf(fidi,'SPACING %f %f %f\n',1,1,1);
fprintf(fido,'SPACING %f %f %f\n',1,1,1);

%fprintf(fid0,'POINT_DATA %i\n',length(P.F1(:)));
fprintf(fidi,'POINT_DATA %i\n',length(P.F1(:)));
fprintf(fido,'POINT_DATA %i\n',length(P.F1(:)));

%fprintf(fid0,'VECTORS original float\n');
fprintf(fidi,'VECTORS noisy float\n');
fprintf(fido,'VECTORS denoised float\n');

for kk=1:size(P.F1,3)
for jj=1:size(P.F1,2)
for ii=1:size(P.F1,1)
%   fprintf(fid0,'%e %e %e\n',P.Yt2(jj,ii,kk),P.Yt1(jj,ii,kk),P.Yt3(jj,ii,kk));
    fprintf(fidi,'%e %e %e\n',P.Y1(ii,jj,kk),P.Y2(ii,jj,kk),P.Y3(ii,jj,kk));
    fprintf(fido,'%e %e %e\n',P.F1(ii,jj,kk),P.F2(ii,jj,kk),P.F3(ii,jj,kk));
end;
end;
end;

%fclose(fid0);
fclose(fidi);
fclose(fido);
