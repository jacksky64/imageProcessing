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

function creaseg_mouseMove(src,evt)
    

    current_object = hittest;
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');

    if ( ~isempty(ud) )   
        fd = get(ud.imageId,'userdata');    
        pos = floor(get(ud.gca,'CurrentPoint'));
        if ( isempty(ud.imageId) )
            if ( strcmp(get(current_object,'Type'), 'image') && ( ...
                    strcmp(get(current_object,'Tag'), 'mainImg') ) && ...
                    (pos(1,1)>0) && pos(1,2)>0 )
                set(ud.txtPositionIntensity,'string',sprintf('x:%02d  y:%02d  i:NaN',pos(1,1),pos(1,2)),'foregroundcolor',[1 1 1]);
            else
                set(ud.txtPositionIntensity,'string','');
            end
        else        
            if ( ~isempty(fd.data) )
                if ( ~strcmp(get(current_object,'Tag'),'pan') && strcmp(get(current_object,'Tag'),'mainImg') && ...
                        (pos(1,1)>0) && (pos(1,2)>0) && (pos(1,1)<=size(fd.data,2)) && ...
                        (pos(1,2)<=size(fd.data,1)) )      
                    %-- check whether the pan button is pressed or not
                    if (get(ud.buttonAction(6),'background')~=[160/255 130/255 95/255])
                        %-- set mouse pointer to pointer if pointer mode is selected
                        if (get(ud.buttonAction(3),'background')==[160/255 130/255 95/255])
                            set(fig,'pointer','arrow');
                        %-- set mouse pointer to crosshair if drawing mode is selected
                        elseif (get(ud.buttonAction(1),'background')==[160/255 130/255 95/255])
                            set(fig,'pointer','crosshair');
                        %-- set mouse pointer to crosshair if drawing mode is selected
                        elseif (get(ud.handleAlgoComparison(17),'background')==[160/255 130/255 95/255])
                            set(fig,'pointer','crosshair');                            
                        else
                            set(fig,'pointer','arrow');
                        end
                        drawnow;
                    end
                    set(ud.txtPositionIntensity,'string',sprintf('x:%02d  y:%02d  i:%03.1f',pos(1,1),pos(1,2),fd.data(pos(1,2),pos(1,1))),'foregroundcolor',[1 1 1]);
                else
                    %-- set mouse pointer to watch                
                    set(fig,'pointer','arrow');
                    drawnow;                
                    set(ud.txtPositionIntensity,'string','');
                end
            else
                if ( strcmp(get(current_object,'Type'), 'image') && ( ...
                        strcmp(get(current_object,'Tag'), 'mainImg') ) && ...
                    (pos(1,1)>0) && pos(1,2)>0 )
                    set(ud.txtPositionIntensity,'string',sprintf('x:%02d  y:%02d  i:NaN',pos(1,1),pos(1,2)),'foregroundcolor',[1 1 1]);
                else
                    set(ud.txtPositionIntensity,'string','');
                end
            end
        end
        
    end
        
        
% % %         %-- Checking if a Reference contour is being drawn and if a point is currently being modified
% % %         if ( strcmp(fd.method, 'Reference') && isfield(fd,'PtsRef') && ~isempty(fd.PtsRef) )
% % % %             axes(get(ud.imageId,'parent'));
% % % 
% % %             ctr = fd.PtsRef;
% % %             % ctr is a 3xn matrix containing the x and y coordinates and a flag to
% % %             % know if the point is selected (position will be modified) or not
% % % 
% % %             m = find(fd.PtsRef(3,:) == 0,1);    %-- Find the index of the first point whose flag is 0 (ie that is modified)
% % % 
% % %             if ~isempty(m)
% % %                 %--
% % %                 pos = floor(get(ud.gca(1),'CurrentPoint'));
% % %                 x = pos(1,1);       y = pos(1,2);
% % % 
% % %                 %-- Updating the point position (+ check bounds)
% % %                 ctr(1,m) = min( max( y, 1), size(fd.data,1) );
% % %                 ctr(2,m) = min( max( x, 1), size(fd.data,2) );
% % % 
% % %                 method = (get(ud.handleAlgoComparison(19),'Value') - 1) * ud.Spline;
% % %                 
% % %                 %-- Deleting all the lines outside the function so that ud has not to be a parameter of the display function
% % %                 delete(findobj(get(ud.imageId(1),'parent'),'type','line'));
% % %                 show_contour(ctr, method, m);
% % %             end
% % %         end
% % %         
% % %     end
% % %     
% % %     
% % % %----- Display Function -----%
% % % function show_contour(ctr, method, m)
% % %     if ~isempty(ctr)
% % %         switch method
% % %             case 0
% % %                 hold on;
% % %                 plot(ctr(2,:),ctr(1,:),'y--','Linewidth',3);                        
% % %                 tmp = ctr(:,1); tmp(:,end+1) = ctr(:,end);
% % %                 plot(tmp(2,:), tmp(1,:), 'y--', 'linewidth', 3);            
% % %                 plot(ctr(2,:), ctr(1,:), 'or', 'linewidth', 2);  
% % %                 hold off;
% % %             case 1
% % %                 spline = cscvn([[ctr(2,:) ctr(2,1)]; [ctr(1,:) ctr(1,1)]]);
% % %                 hold on; fnplt(spline, 3, 'y--');
% % %                 plot(ctr(2,:), ctr(1,:), 'or', 'linewidth', 2);
% % %                 hold off;
% % %         end
% % %         %-- Plot in green the point that is selected
% % %         hold on; plot(ctr(2,m),ctr(1,m),'og','Linewidth',2); hold off;
% % %     end
% % %     

