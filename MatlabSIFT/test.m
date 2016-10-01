
%example file for feature detector

%close all

testpat=0; %set to zero to use current contents of img variable

if testpat==1
    
    img=zeros(400,400);
    img(150:200,100:150)=200;
    img(100:110,100:110)=200;
    img(100:118,140:158)=200;
    img(100:120,185:205)=200;
    img(100:125,235:260)=200;
    img(100:130,290:320)=200;
    img(150:185,40:75)=200;
    img(190:290,190:290)=200;
    img(300:302,100:102)=200;
        
    img=filter_gaussian(img,7,sqrt(2));
    img=img+randn(400,400)*5;
    
elseif testpat==2
    
    img=zeros(400,400);
    img(200:400,190:210) = 200;
    img=filter_gaussian(img,7,sqrt(2));
    img=img+randn(400,400)*5;
    
elseif testpat==3
    
    img=zeros(400,400);
    img(1:400,190:210) = 200;
    img=filter_gaussian(img,7,sqrt(2));
    img=img+randn(400,400)*5;
    
elseif testpat==4
    
    img=zeros(400,400);
    img(200:400,190:210) = 200;
    img(200:220,200:400) = 200;
    img=filter_gaussian(img,7,sqrt(2));
    img=img+randn(400,400)*0;
    
elseif testpat==5
    
    img=zeros(400,400);
    img(200:400,200:210) = 200;
    img(200:210,1:400) = 200;
    img=filter_gaussian(img,7,sqrt(2));
    img=img+randn(400,400)*5;
    
elseif testpat==6
    
    img=zeros(400,400);
    img(1:400,200:210) = 200;
    img(200:210,1:400) = 200;
    img=filter_gaussian(img,7,sqrt(2));
    img=img+randn(400,400)*5;
    img=-img;

end    

close all

if size(img,3)>1 
    img = rgb2gray(img);
end

%imagesc(img);

threshold=3;        %Threshold value for rejecting maxima/minima
disp_flag = 0;      %change to a zero for a combined view of all scales
img_flag = 1;       %change to a zero to see features plotted on original image
radius = 4;
radius2 = 4;
radius3 = 4;
min_sep = .04;
edgeratio = 5;
scl = 1.5;

%img = imread(file_name);
%[pyr,imp] = build_pyramid(img,12,scl);

%pts = find_features(pyr,img,scl, threshold,radius,radius2,min_sep,edgeratio,disp_flag,img_flag);

%[features] = getpts(img,pyr,scl,imp,pts,6,radius3,min_sep,edgeratio);

[features,pyr,imp,keys] = detect_features(img,scl,disp_flag,threshold,radius,radius2,radius3, min_sep,edgeratio);

showfeatures(features,img);
axis equal;

%enjoy...