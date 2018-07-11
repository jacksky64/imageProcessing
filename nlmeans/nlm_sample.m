% Example 2D greyscale
 obs=double(imread('E:\SolidDetectorImages\Scopia\2018-02-23 Ats collimazione scopia dinamica\Img8_Field15_1024\FrmID009_009.png'));
 %I=sqrt(obs);
 I=obs;
 
 Options.kernelratio=4;
 Options.windowratio=4;
 Options.nThreads = 8;
 Options.verbose=true;
 Options.filterstrength = 50;
 
 J=NLMF(I,Options);
imtool(J)
