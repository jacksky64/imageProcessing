% Copyright or © or Copr. CREATIS laboratory, Lyon, France.
% 
% Contributor: Olivier Bernard, Associate Professor at the french 
% engineering university INSA (Institut National des Sciences Appliquees) 
% and a member of the CREATIS-LRMN laboratory (CNRS 5220, INSERM U630, 
% INSA, Claude Bernard Lyon 1 University) in France (Lyon).
% 
% Date of creation: 8th of October 2009
% 
% E-mail of the author: olivier.bernard@creatis.insa-lyon.fr
% 
% This software is a computer program whose purpose is to evaluate the 
% performance of different level-set based segmentation algorithms in the 
% context of image processing (and more particularly on biomedical 
% images).
% 
% The software has been designed for two main purposes. 
% - firstly, CREASEG allows you to use six different level-set methods. 
% These methods have been chosen in order to work with a wide range of 
% level-sets. You can select for instance classical methods such as 
% Caselles or Chan & Vese level-set, or more recent approaches such as the 
% one developped by Lankton or Bernard.
% - finally, the software allows you to compare the performance of the six 
% level-set methods on different images. The performance can be evaluated 
% either visually, or from measurements (either using the Dice coefficient 
% or the PSNR value) between a reference and the results of the 
% segmentation.
%  
% The level-set segmentation platform is citationware. If you are 
% publishing any work, where this program has been used, or which used one 
% of the proposed level-set algorithms, please remember that it was 
% obtained free of charge. You must reference the papers shown below and 
% the name of the CREASEG software must be mentioned in the publication.
% 
% CREASEG software
% "T. Dietenbeck, M. Alessandrini, D. Friboulet, O. Bernard. CREASEG: a
% free software for the evaluation of image segmentation algorithms based 
% on level-set. In IEEE International Conference On Image Processing. 
% Hong Kong, China, 2010."
%
% Bernard method
% "O. Bernard, D. Friboulet, P. Thevenaz, M. Unser. Variational B-Spline 
% Level-Set: A Linear Filtering Approach for Fast Deformable Model 
% Evolution. In IEEE Transactions on Image Processing. volume 18, no. 06, 
% pp. 1179-1191, 2009."
% 
% Caselles method
% "V. Caselles, R. Kimmel, and G. Sapiro. Geodesic active contours. 
% International Journal of Computer Vision, volume 22, pp. 61-79, 1997."
% 
% Chan & Vese method
% "T. Chan and L. Vese. Active contours without edges. IEEE Transactions on
% Image Processing. volume10, pp. 266-277, February 2001."
% 
% Lankton method
% "S. Lankton, A. Tannenbaum. Localizing Region-Based Active Contours. In 
% IEEE Transactions on Image Processing. volume 17, no. 11, pp. 2029-2039, 
% 2008."
% 
% Li method
% "C. Li, C.Y. Kao, J.C. Gore, Z. Ding. Minimization of Region-Scalable 
% Fitting Energy for Image Segmentation. In IEEE Transactions on Image 
% Processing. volume 17, no. 10, pp. 1940-1949, 2008."
% 
% Shi method
% "Yonggang Shi, William Clem Karl. A Real-Time Algorithm for the 
% Approximation of Level-Set-Based Curve Evolution. In IEEE Transactions 
% on Image Processing. volume 17, no. 05, pp. 645-656, 2008."
% 
% This software is governed by the BSD license and
% abiding by the rules of distribution of free software.
% 
% As a counterpart to the access to the source code and rights to copy,
% modify and redistribute granted by the license, users are provided only
% with a limited warranty and the software's author, the holder of the
% economic rights, and the successive licensors have only limited
% liability. 
% 
% In this respect, the user's attention is drawn to the risks associated
% with loading, using, modifying and/or developing or reproducing the
% software by the user in light of its specific status of free software,
% that may mean that it is complicated to manipulate, and that also
% therefore means that it is reserved for developers and experienced
% professionals having in-depth computer knowledge. Users are therefore
% encouraged to load and test the software's suitability as regards their
% requirements in conditions enabling the security of their systems and/or 
% data to be ensured and, more generally, to use and operate it in the 
% same conditions as regards security.
% 
%------------------------------------------------------------------------


function creaseg_loadimage(varargin)

    if nargin == 1
        fig = varargin{1};
    else
        fig = gcbf;
    end
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');    
    
    %--
    [fname,pname] = uigetfile('*.png;*.jpg;*.pgm;*.bmp;*.gif;*.tif;*.dcm;','Pick a file','multiselect','off','data/Image');
    input_file = fullfile(pname,fname);
   
    if ~exist(input_file,'file')
        warning(['File: ' input_file ' does not exist']);
        return;
    else
        [pathstr, name, ext] = fileparts(input_file);
    end
    try
        if (ext=='.dcm')
            img = dicomread(input_file);
            info = dicominfo(input_file);
        else
            img = imread(input_file);
            info = imfinfo(input_file);
        end
    catch
        warning(['Could not load: ' input_file]);
        return;
    end
    img = im2graydouble(img);       
    fd.data = img;
    fd.visu = img;
    fd.tagImage = 1;
    fd.dimX = size(img,2);
    fd.dimY = size(img,1);
    fd.info = info;
    
    if ( isfield(fd.info,'Width') )
        set(ud.txtInfo1,'string',sprintf('width:%d pixels',fd.info.Width), 'color', [1 1 0]);
    end
    if ( isfield(fd.info,'Height') )
        set(ud.txtInfo2,'string',sprintf('height:%d pixels',fd.info.Height));
    end
    if ( isfield(fd.info,'BitDepth') )
        set(ud.txtInfo3,'string',sprintf('bit depth:%d',fd.info.BitDepth));
    end
    if ( isfield(fd.info,'XResolution') && (~isempty(fd.info.XResolution)) )
        if ( isfield(fd.info,'ResolutionUnit') )
            if ( strcmp(fd.info.ResolutionUnit,'meter') )
                set(ud.txtInfo4,'string',sprintf('XResolution:%0.3f mm',fd.info.XResolution/1000));
            elseif ( strcmp(fd.info.ResolutionUnit,'millimeter') )
                set(ud.txtInfo4,'string',sprintf('XResolution:%0.3f mm',fd.info.XResolution));
            else
                set(ud.txtInfo4,'string',sprintf('XResolution:%0.3f',fd.info.XResolution));
            end
        else
            set(ud.txtInfo4,'string',sprintf('XResolution:%f',fd.info.XResolution));
        end
    else
        set(ud.txtInfo4,'string','');
    end
    if ( isfield(fd.info,'YResolution') && (~isempty(fd.info.YResolution)) )
        if ( isfield(fd.info,'ResolutionUnit') )
            if ( strcmp(fd.info.ResolutionUnit,'meter') )
               set(ud.txtInfo5,'string',sprintf('YResolution:%0.3f mm',fd.info.YResolution/1000)); 
            elseif ( strcmp(fd.info.ResolutionUnit,'millimeter') )
                set(ud.txtInfo5,'string',sprintf('YResolution:%0.3f mm',fd.info.YResolution));
            else
                set(ud.txtInfo5,'string',sprintf('YResolution:%0.3f',fd.info.YResolution));
            end
        else
            set(ud.txtInfo5,'string',sprintf('YResolution:%f',fd.info.XResolution));
        end
    else
        set(ud.txtInfo5,'string','');
    end      
    
    %-- reset drawing buttons selection
    for k=3:size(ud.handleInit,1)
        set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
    end    
    
    %--  clean overlays before udating fd structure
    creaseg_cleanOverlays();
    
    %--
    fd.levelset = zeros(size(fd.data));
    fd.reference = zeros(size(fd.data));
    fd.method = '';
    
    set(ud.buttonAction,'background',[240/255 173/255 105/255]);
    set(ud.buttonAction(7),'background',[160/255 130/255 95/255]);
    for k=1:size(ud.handleAlgoConfig,1)
        set(ud.handleAlgoConfig(k),'Visible','off');
    end
    set(ud.handleAlgoConfig(end),'Visible','on');
    set(ud.buttonAction(1),'background',[160/255 130/255 95/255]);
    
    set(ud.handleAlgoComparison(16),'Enable','on');
    set(ud.handleAlgoComparison(17),'Enable','on');
    set(ud.handleAlgoComparison(24),'Enable','off');
        
    
    %-- ATTACH FD AND UD STRUCTURE TO IMAGEID AND FIG HANDLES
    set(ud.imageId,'userdata',fd);       
    
    %--
    creaseg_show();
    
    


%------------------------------------------------------    
%------------------------------------------------------    
%-- Converts image to one channel (grayscale) double
function img = im2graydouble(img)

    [dimy, dimx, c] = size(img);
    if(isfloat(img)) % image is a double
        if(c==3) 
            img = rgb2gray(uint8(img)); 
        end
    else           % image is a int
        if(c==3) 
            img = rgb2gray(img); 
        end
        img = double(img);
    end    


