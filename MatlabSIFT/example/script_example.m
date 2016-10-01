img1 = imread('ima1.jpg');

figure(1);
image(img1);
colormap(gray(256));
title('ima1.jpg');

drawnow;

% Detect the SIFT features:
fprintf(1,'Computing the SIFT features for ima1.jpg...\n')
[features1,pyr1,imp1,keys1] = detect_features(img1);

figure(2);
showfeatures(features1,img1);
title('SIFT features of image ima1.jpg');
drawnow;




img2 = imread('ima2.jpg');

figure(3);
image(img2);
colormap(gray(256));
title('ima2.jpg');

drawnow;

% Detect the SIFT features:
fprintf(1,'Computing the SIFT features for ima2.jpg...\n')
[features2,pyr2,imp2,keys2] = detect_features(img2);

figure(4);
showfeatures(features2,img2);
title('SIFT features of image ima2.jpg');





img3 = imread('ima3.jpg');

figure(5);
image(img3);
colormap(gray(256));
title('ima3.jpg');

drawnow;

% Detect the SIFT features:
fprintf(1,'Computing the SIFT features for ima3.jpg...\n')
[features3,pyr3,imp3,keys3] = detect_features(img3);

figure(6);
showfeatures(features3,img3,1);
title('SIFT features of image ima3.jpg');

