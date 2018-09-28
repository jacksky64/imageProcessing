imtool close all
clear all

% Example 2D greyscale
%obs=double(imread('E:\SolidDetectorImages\Scopia\2018-02-23 Ats collimazione scopia dinamica\Img8_Field15_1024\FrmID009_009.png'));
%obs=double(imread('E:\SolidDetectorImages\grafia\DCM for processingPICTURE (from RF detector)\DCM for processingPICTURE FOR AGFA (from RF detector)\png\Sng001I011.png'));
obs=double(imread('E:\SolidDetectorImages\Scopia\2018-07-12 GUEYE MANSOR\FrmID000_000.png'));
obs=ones(100,100);
obs(50,50)=10;
I=sqrt(obs+1);
Ioffset = min(I(:));
Igain = 1./(max(I(:))-min(I(:)));
I=(I-Ioffset).*Igain;

Options.kernelratio=7;
Options.windowratio=1;
Options.nThreads = 4;
Options.verbose=true;
Options.filterstrength = 50;

estimatedI(:,:,1)=NLMF(I,Options);
imtool(estimatedI(:,:,1));

MethNoise = I-estimatedI(:,:,1);
KMethNoise = MethNoise*1000;
imtool(KMethNoise);

Options.filterstrength = 80;
estResidual=NLMF(MethNoise,Options);
imtool(estResidual*1000)

estimatedI(:,:,2) = estimatedI(:,:,1)+ estResidual;
R0=estimatedI(:,:,1)./Igain + Ioffset;
R0=R0.^2;
R0log = log(R0+1)*1000;

R = estimatedI(:,:,2) ./Igain + Ioffset;
R = R.^2;
Rlog = log(R+1)*1000;
obslog = log(obs+1)*1000;


imtool(R0log);
imtool(Rlog);
imtool(obslog);
imtool(Rlog-R0log);

d0 =R0log-obslog;
d0=max(min(d0,100),-100);
imtool(d0);

d =Rlog-obslog;
d=max(min(d,100),-100);
imtool(d);


