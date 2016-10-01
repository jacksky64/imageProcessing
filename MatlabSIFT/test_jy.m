imgo1 = imread('f00176.bmp');
img1 = imresize(imgo1,2,'bilinear');
imgo2 = imread('f00177.bmp');
img2 = imresize(imgo2, 2, 'bilinear');

[f1,pyr,imp,k1] = detect_features(img1);
[f1,k1] = eliminate_edges(f1,k1);
figure(1);
showfeatures(f1,img1,0)

[f2,pyr,imp,k2] = detect_features(img2);
[f2,k2] = eliminate_edges(f2,k2);
figure(2);
showfeatures(f2,img2,0)



kill_edges
im1 = rgb2gray(img1);
im2 = rgb2gray(img2);
symmetric_match
m
cavg
size(fk1)