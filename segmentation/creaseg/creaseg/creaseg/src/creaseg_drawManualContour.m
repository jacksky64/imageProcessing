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

function creaseg_drawManualContour(src,evt)
        
    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata'); 
    
    pos = floor(get(ud.gca(1),'CurrentPoint'));
    %-- Clic outside the image => do nothing
    if ~( pos(1,1) < size(fd.data,2) && pos(1,1) > 1 && pos(1,2) < size(fd.data,1) && pos(1,2) >1 )
        return; 
    end
       
    if ( strcmp(get(ud.gcf,'SelectionType'),'normal') )
   
        %-- Set drawingManualFlag flag to 1
        fd.drawingManualFlag = 1;
        
        %-- delete any overlay lines
        if ( size(fd.handleManual,2)>0 )
            for k=1:size(fd.handleManual{1},1)
                delete(fd.handleManual{1}(k));
            end
            fd.handleManual(1)=[];
        end         
        
        %-- Get point coordinates
        pt = get(ud.gca,'CurrentPoint');
        pt = pt(1,1:2);
        if (isempty(fd.points))
            fd.points = [pt(1),pt(2)];
            hold on; h = plot(pt(1), pt(2), 'oy', 'linewidth', 2);
            fd.handleManual{1} = h;
        else
            fd.points(end+1,:) = [pt(1),pt(2)];
            color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
            
            if length(fd.points(:,1)) < 3       % If there's only 2 points, display a line instead of spline
                hold on; h1 = plot(fd.points(:,1),fd.points(:,2),'--','color',color{1},'Linewidth',2);
                tmp = fd.points(1,:); tmp(end+1,:) = fd.points(end,:);
                h2 = plot(tmp(:,1), tmp(:,2), 'y--', 'linewidth', 2);
            else
                [xs, ys] = creaseg_spline(fd.points(:,1)',fd.points(:,2)');

                % Find the position of the last (fin) and first (deb) points of fd.points in xs and ys
                fin = find((xs == fd.points(end,1)) & (ys == fd.points(end,2)) );
                deb = find((xs == fd.points(1,1)) & (ys == fd.points(1,2)) );

                % Change the point order to have deb->fin->deb
                xs = xs([deb:end, 1:deb]);          ys = ys([deb:end, 1:deb]);
                if deb > fin            % And compute the new position of the last point
                    idx = length(xs) + fin - deb;   
                else
                    idx = fin - deb;
                end
                clear deb fin;

                hold on; h1 = plot(xs(1:idx),ys(1:idx),'--','color',color{1},'Linewidth',2);
                hold on; h2 = plot(xs(idx:end),ys(idx:end),'y--','Linewidth',2);
            end
            
            h3 = plot(fd.points(:,1), fd.points(:,2), 'oy', 'linewidth', 2);
            hold off;
            fd.handleManual{1} = [h1;h2;h3];
        end
        
        
    else %-- create final contour
              
        %-- Set drawingManualFlag flag to 0
        fd.drawingManualFlag = 0;
        
        %-- display final contour
        if ( size(fd.points,1)>2 )            
            %-- delete any overlay lines
            if ( size(fd.handleManual,2)>0 )
                for k=1:size(fd.handleManual{1},1)
                    delete(fd.handleManual{1}(k));
                end
                fd.handleManual(1)=[];
            end                          
            %--
            color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
                  
            if length(fd.points(:,1)) < 3
                tmp = fd.points;
                tmp(end+1,:) = tmp(1,:);
                hold on; h = plot(tmp(:,1),tmp(:,2),'--','color',color{1},'Linewidth',2);
            else
                [xs, ys] = creaseg_spline(fd.points(:,1)',fd.points(:,2)');
                hold on; h = plot(xs,ys,'--','color',color{1},'Linewidth',2);
            end
            
            fd.handleManual{1} = h;
            %-- create manual mask
            X = get(fd.handleManual{1},'X');
            Y = get(fd.handleManual{1},'Y');
            fd.levelset = roipoly(fd.data,X,Y); 
            %-- save initialization info
            ud.LastPlot = 'levelset';
            fd.method = 'Initial region';
            %-- enable run and pointer buttons
            set(ud.buttonAction(2),'enable','on');
            set(ud.buttonAction(3),'enable','on');
        end
        fd.points = [];
                
    end
    
    %-- save structure
    set(ud.imageId,'userdata',fd);  
    set(ud.gcf,'userdata',ud);
    
