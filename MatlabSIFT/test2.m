imgo1 = imread('f:\robot\loop3data\f00176.bmp');
img1 = imresize(imgo1,2,'bilinear');
imgo2 = imread('f:\robot\loop3data\f00177.bmp');
img2 = imresize(imgo2, 2, 'bilinear');
[features,pyr,imp,keys] = detect_features(img1,1.5,0,3,4,4,4,.04,5);
[features2,pyr2,imp2,keys2] = detect_features(img2,1.5,0,3,4,4,4,.04,5);
kill_edges
im1 = rgb2gray(img1);
im2 = rgb2gray(img2);
symmetric_match
m
cavg
size(fk1)