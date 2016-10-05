I=(imread('d:\temp\nlb\testc.png'));
I=rgb2gray(I);
Ir=imresize(I,0.125);
[Iout,intensity,fitness,time] = segmentation(Ir,8);
imtool(Iout)