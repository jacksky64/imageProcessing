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

%------------------------------------------------------------------------
% Description: This code implements the paper: "Variational B-Spline 
% Level-Set: A Linear Filtering Approach for Fast Deformable Model 
% Evolution." By Olivier Bernard.
%
% Coded by: Olivier Bernard (www.creatis.insa-lyon.fr/~bernard)
%------------------------------------------------------------------------

%------------------------------------------------------------------            
function creaseg_cleanOverlays(keepLS)
        
    %-- default value for parameter max_its is 100
    if(~exist('keepLS','var')) 
        keepLS = 0; 
    end 

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata'); 

    %-- refresh flag in case
    fd.drawingManualFlag = 0;
    fd.drawingMultiManualFlag = 0;
    fd.drawingReferenceFlag = 0;
    
    %-- clean all
    if ( strcmp(fd.method,'Caselles') || strcmp(fd.method,'Chan & Vese') || ...
         strcmp(fd.method,'Chunming Li') || strcmp(fd.method,'Lankton') || ...
         strcmp(fd.method,'Bernard') || strcmp(fd.method,'Shi') || ...
         strcmp(fd.method,'Personal') || strcmp(fd.method,'Reference') || ...
         strcmp(fd.method,'Comparison') )
        axes(get(ud.imageId,'parent'));
        delete(findobj(get(ud.imageId,'parent'),'type','line'));
        fd.method = [];
    end
    if ( size(fd.handleRect,2) > 0 )
        for k=size(fd.handleRect,2):-1:1
            delete(fd.handleRect{k});
            fd.handleRect(k)=[];
        end
    end 
    if ( size(fd.handleElliRect,2) > 0 )
        for k=size(fd.handleElliRect,2):-1:1
            delete(fd.handleElliRect{k}(2));
            fd.handleElliRect(k)=[];
        end
    end
    if ( size(fd.handleManual,2) > 0 )    
        for k=size(fd.handleManual,2):-1:1
            for l=1:size(fd.handleManual{k},1)
                if ( fd.handleManual{k}(l) ~= 0 )
                    delete(fd.handleManual{k}(l));
                end
            end
            fd.handleManual(k)=[];
            fd.points = [];
        end        
    end
     
    
    if ( keepLS == 0 )
        fd.levelset = zeros(size(fd.data));
    end
    set(ud.imageId,'userdata',fd);    
    %-- end clean all
    

