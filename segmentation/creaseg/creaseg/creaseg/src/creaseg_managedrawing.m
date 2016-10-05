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

function creaseg_managedrawing(src,evt,type)


    %-- parameters
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata'); 
    set(ud.buttonAction(2),'BackgroundColor',[240/255 173/255 105/255]);
    set(ud.buttonAction(3),'BackgroundColor',[240/255 173/255 105/255]);
    set(ud.buttonAction(6),'BackgroundColor',[240/255 173/255 105/255]);
    set(ud.buttonAction(7),'BackgroundColor',[240/255 173/255 105/255]);
    set(ud.buttonAction(1),'background',[160/255 130/255 95/255]);
    pan off;
    
    %-- switch case
    if ( type == 1 ) %-- first button: draw rectangle
        
        for k=3:size(ud.handleInit,1)
            set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
        end
        set(ud.handleInit(2+1),'BackgroundColor',[160/255 130/255 95/255]);
        %-- enable run, pointer and pan buttons
        set(ud.buttonAction(2),'enable','on');
        set(ud.buttonAction(3),'enable','on');
        set(ud.buttonAction(6),'enable','on');
        %--
        displayDrawingInfo(ud,isempty(fd.data),1);
        %--
        creaseg_cleanOverlays();        
        %--
        set(ud.gcf,'WindowButtonDownFcn',{@startdragrectangle});
        set(ud.gcf,'WindowButtonUpFcn',{@stopdragrectangle});

    elseif ( type == 2 ) %-- second button draw multi-rectangles
        
        for k=3:size(ud.handleInit,1)
            set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
        end
        set(ud.handleInit(2+2),'BackgroundColor',[160/255 130/255 95/255]);
        %-- enable run, pointer and pan buttons
        set(ud.buttonAction(2),'enable','on');
        set(ud.buttonAction(3),'enable','on');
        set(ud.buttonAction(6),'enable','on');      
        %--
        displayDrawingInfo(ud,isempty(fd.data),4);
        %--
        creaseg_cleanOverlays();        
        %--
        set(ud.gcf,'WindowButtonDownFcn',{@startdragmultirectangle});
        set(ud.gcf,'WindowButtonUpFcn',{@stopdragmultirectangle});         
        
        
    elseif ( type == 3 ) %-- thrid button: draw ellipse
        
        for k=3:size(ud.handleInit,1)
            set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
        end
        set(ud.handleInit(2+3),'BackgroundColor',[160/255 130/255 95/255]);
        %-- enable run, pointer and pan buttons
        set(ud.buttonAction(2),'enable','on');
        set(ud.buttonAction(3),'enable','on');
        set(ud.buttonAction(6),'enable','on');       
        %--
        displayDrawingInfo(ud,isempty(fd.data),2);        
        %--
        creaseg_cleanOverlays();        
        %--
        set(ud.gcf,'WindowButtonDownFcn',{@startdragellipse});
        set(ud.gcf,'WindowButtonUpFcn',{@stopdragellipse});        
     
	elseif ( type == 4 ) %-- forth button: draw multi-ellipse
        
        for k=3:size(ud.handleInit,1)
            set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
        end
        set(ud.handleInit(2+4),'BackgroundColor',[160/255 130/255 95/255]);
        %-- enable run, pointer and pan buttons
        set(ud.buttonAction(2),'enable','on');
        set(ud.buttonAction(3),'enable','on');
        set(ud.buttonAction(6),'enable','on');  
        %--
        displayDrawingInfo(ud,isempty(fd.data),5);
        %--
        creaseg_cleanOverlays();        
        %--
        set(ud.gcf,'WindowButtonDownFcn',{@startdragmultiellipse});
        set(ud.gcf,'WindowButtonUpFcn',{@stopdragmultiellipse});         
        
    elseif ( type == 5 ) %-- fith button: draw manual contour
        
        for k=3:size(ud.handleInit,1)
            set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
        end
        set(ud.handleInit(2+5),'BackgroundColor',[160/255 130/255 95/255]);
        %-- disable run and pointer buttons
        set(ud.buttonAction(2),'enable','off');
        set(ud.buttonAction(3),'enable','off');
        %--
        displayDrawingInfo(ud,isempty(fd.data),3);        
        %--
        creaseg_cleanOverlays();        
        %--
        set(ud.gcf,'WindowButtonDownFcn',{@creaseg_drawManualContour});
        set(ud.gcf,'WindowButtonUpFcn','');        
        
   
    elseif ( type == 6 ) %-- sixth button: draw multi-manuals
        
        for k=3:size(ud.handleInit,1)
            set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
        end
        set(ud.handleInit(2+6),'BackgroundColor',[160/255 130/255 95/255]);
        %-- disable run and pointer buttons
        set(ud.buttonAction(2),'enable','off');
        set(ud.buttonAction(3),'enable','off');
        %--
        displayDrawingInfo(ud,isempty(fd.data),6);
        %--
        creaseg_cleanOverlays();
        %--
        set(ud.gcf,'WindowButtonDownFcn',{@creaseg_drawMultiManualContours});
        set(ud.gcf,'WindowButtonUpFcn','');       
        
    end


%------------------------------------------------------------------    
function startdragrectangle(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');

    pos = floor(get(ud.gca(1),'CurrentPoint'));
    if ~( pos(1,1) < size(fd.data,2) && pos(1,1) > 1 && pos(1,2) < size(fd.data,1) && pos(1,2) >1 ) % Clic outside the image
        return; 
    end
        
    %-- clean rectangle overlay
    if ( size(fd.handleRect,2)>0 )
        delete(fd.handleRect{1});
        fd.handleRect(1)=[];
    end
        
    %-- initialize rectangle display    
    pt = get(ud.gca,'CurrentPoint');
    pt = pt(1,1:2);
    h = rectangle('Position',[pt(1),pt(2),1,1],'Linewidth',1,'EdgeColor','y','LineStyle','--');  
    
    %-- save rectangle position
    fd.handleRect{1} = h;
    set(ud.imageId,'userdata',fd);
    
    %-- initialize the interactive rectangle display
    set(ud.gcf,'WindowButtonMotionFcn',{@dragrectangle,pt,h});    
    

%------------------------------------------------------------------    
function startdragmultirectangle(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');

    pos = floor(get(ud.gca(1),'CurrentPoint'));
    if ~( pos(1,1) < size(fd.data,2) && pos(1,1) > 1 && pos(1,2) < size(fd.data,1) && pos(1,2) >1 ) % Clic outside the image
        return; 
    end
    
    %-- initialize rectangle display    
    pt = get(ud.gca,'CurrentPoint');
    pt = pt(1,1:2);
    h = rectangle('Position',[pt(1),pt(2),1,1],'Linewidth',1,'EdgeColor','y','LineStyle','--');  
    
    %-- save rectangle position
    fd.rect = [pt(1),pt(2),1,1];
    fd.handleRect{end+1} = h;
    set(ud.imageId,'userdata',fd);
    
    %-- initialize the interactive rectangle display
    set(ud.gcf,'WindowButtonMotionFcn',{@dragrectangle,pt,h});    
    
    
%------------------------------------------------------------------    
function dragrectangle(varargin)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');
    
    pt1 = varargin{3}; h = varargin{4};
    pt2 = get(ud.gca,'CurrentPoint');
    pt2 = pt2(1,1:2);    
    
    %-- Check bounds
    pt2(1) = min( max( pt2(1), 1), size(fd.data,2));
    pt2(2) = min( max( pt2(2), 1), size(fd.data,1));
    
    wp = abs(pt1(1)-pt2(1));
    if ( wp == 0 ) 
        wp = eps; 
    end
    hp = abs(pt1(2)-pt2(2));
    if ( hp == 0 ) 
        hp = eps; 
    end
    if ( (pt1(1)>pt2(1)) && (pt1(2)>pt2(2)) )
        xp = pt2(1); yp = pt2(2);
    elseif ( (pt1(1)>=pt2(1)) && (pt1(2)<=pt2(2)) )
        xp = pt2(1); yp = pt1(2);
    elseif ( (pt1(1)<=pt2(1)) && (pt1(2)>=pt2(2)) )
        xp = pt1(1); yp = pt2(2);
    else
        xp = pt1(1); yp = pt1(2);
    end
    set(h,'Position',[xp,yp,wp,hp]);
    
    %-- save rectangle position
    fd.handleRect{end} = h;
    set(ud.imageId,'userdata',fd);
    
    
%------------------------------------------------------------------    
function stopdragrectangle(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');
    
    color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
    if ~isempty(fd.handleRect)
        set(fd.handleRect{1},'Linewidth',2,'EdgeColor',color{1},'LineStyle','-'); 
    end
    
    %-- create rectangle mask
    if ( size(fd.handleRect,2) > 0 )
        rect = get(fd.handleRect{1},'Position');
        fd.levelset = roipoly(fd.data,[rect(1),rect(1),min(rect(1)+rect(3),size(fd.data,1)),min(rect(1)+rect(3),size(fd.data,1))]...
            ,[rect(2),min(rect(2)+rect(4),size(fd.data,2)),min(rect(2)+rect(4),size(fd.data,2)),rect(2)]);                
    end
    
    %-- save initialization info
    ud.LastPlot = 'levelset';
    fd.method = 'Initial region';
    
    %-- save structure
    set(ud.imageId,'userdata',fd);
    set(ud.gcf,'userdata',ud);
    
    %-- switch off the interactive rectangle mode
    set(ud.gcf,'WindowButtonMotionFcn',{@creaseg_mouseMove});
    
   
%------------------------------------------------------------------    
function stopdragmultirectangle(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');
    
    %-- dislpay last final rectangle in "color"
    color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
    if ~isempty(fd.handleRect)
        set(fd.handleRect{end},'Linewidth',2,'EdgeColor',color{1},'LineStyle','-');
    end
        
    %-- create multirectangle mask
    if ( size(fd.handleRect,2) > 0 )
        rect = get(fd.handleRect{end},'Position');
        fd.levelset = xor(roipoly(fd.data,[rect(1),rect(1),rect(1)+rect(3),rect(1)+rect(3)]...
            ,[rect(2),rect(2)+rect(4),rect(2)+rect(4),rect(2)]),fd.levelset);        
    end   
    
    %-- save initialization info
    ud.LastPlot = 'levelset';
    fd.method = 'Initial region';    
    
    %-- save structure
    set(ud.imageId,'userdata',fd);
    set(ud.gcf,'userdata',ud);
    
    %-- switch off the interactive rectangle mode
    set(ud.gcf,'WindowButtonMotionFcn',{@creaseg_mouseMove});    
      
    
%------------------------------------------------------------------    
function startdragellipse(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');

    pos = floor(get(ud.gca(1),'CurrentPoint'));
    if ~( pos(1,1) < size(fd.data,2) && pos(1,1) > 1 && pos(1,2) < size(fd.data,1) && pos(1,2) >1 ) % Clic outside the image
        if ( size(fd.handleElliRect,2)>0 )
            delete(fd.handleElliRect{1}(2));
            fd.handleElliRect(1)=[];
        end        
        set(ud.imageId,'userdata',fd);
        return; 
    end
    
    %-- clean image overlay
    if ( size(fd.handleElliRect,2)>0 )
        delete(fd.handleElliRect{1}(2));
        fd.handleElliRect(1)=[];
    end        
    
    %-- initialize enclosing rectangle display    
    pt = get(ud.gca,'CurrentPoint');
    pt = pt(1,1:2);
    h1 = rectangle('Position',[pt(1),pt(2),1,1],'Linewidth',1,'EdgeColor','y','LineStyle','--');
    color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
    hold on; h2 = plot(pt(1),pt(2),'-','color',color{1},'linewidth',2);
    
    %-- save rectangle position
    fd.handleElliRect{1} = [h1;h2];
    set(ud.imageId,'userdata',fd);
    
    %-- initialize the interactive rectangle display
    set(ud.gcf,'WindowButtonMotionFcn',{@dragellipse,pt});    
    

%------------------------------------------------------------------    
function startdragmultiellipse(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');

    pos = floor(get(ud.gca(1),'CurrentPoint'));
    if ~( pos(1,1) < size(fd.data,2) && pos(1,1) > 1 && pos(1,2) < size(fd.data,1) && pos(1,2) >1 ) % Clic outside the image
        if ( size(fd.handleElliRect,2)>0 )
            delete(fd.handleElliRect{1}(2));
            fd.handleElliRect(1)=[];
        end        
        set(ud.imageId,'userdata',fd);
        return; 
    end
             
    %-- initialize enclosing rectangle display    
    pt = get(ud.gca,'CurrentPoint');
    pt = pt(1,1:2);
    h1 = rectangle('Position',[pt(1),pt(2),1,1],'Linewidth',1,'EdgeColor','y','LineStyle','--');
    color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
    hold on; h2 = plot(pt(1),pt(2),'-','color',color{1},'linewidth',2);
    
    %-- save rectangle position    
    fd.handleElliRect{end+1} = [h1;h2];
    set(ud.imageId,'userdata',fd);
    
    %-- initialize the interactive rectangle display
    set(ud.gcf,'WindowButtonMotionFcn',{@dragellipse,pt});     
    
    
%------------------------------------------------------------------    
function dragellipse(varargin)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');

    %--
    pt1 = varargin{3};
    pt2 = get(ud.gca,'CurrentPoint');
    pt2 = pt2(1,1:2);    
    wp = abs(pt1(1)-pt2(1));
    if ( wp == 0 ) 
        wp = eps; 
    end
    hp = abs(pt1(2)-pt2(2));
    if ( hp == 0 ) 
        hp = eps; 
    end
    if ( (pt1(1)>pt2(1)) && (pt1(2)>pt2(2)) )
        xp = pt2(1); yp = pt2(2);
    elseif ( (pt1(1)>=pt2(1)) && (pt1(2)<=pt2(2)) )
        xp = pt2(1); yp = pt1(2);
    elseif ( (pt1(1)<=pt2(1)) && (pt1(2)>=pt2(2)) )
        xp = pt1(1); yp = pt2(2);
    else
        xp = pt1(1); yp = pt1(2);
    end
    set(fd.handleElliRect{end}(1),'Position',[xp,yp,wp,hp]);
    
    %-- save rectangle position and draw embedded ellipse
    [X,Y] = computeEllipse(xp,yp,wp,hp);
    set(fd.handleElliRect{end}(2),'X',X,'Y',Y);
    set(ud.imageId,'userdata',fd);
    
    
%------------------------------------------------------------------    
function stopdragellipse(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');
    
    %-- delete enclosing rectangle
    if ( size(fd.handleElliRect,2)> 0 )
        delete(fd.handleElliRect{end}(1));
    end
    
    %-- create ellipse mask
    if ( size(fd.handleElliRect,2) > 0 )
        X = get(fd.handleElliRect{1}(2),'X');
        Y = get(fd.handleElliRect{1}(2),'Y');
        fd.levelset = roipoly(fd.data,X,Y);
    end    
    
    %-- save initialization info
    ud.LastPlot = 'levelset';
    fd.method = 'Initial region';    
    
    %-- save structure
    set(ud.imageId,'userdata',fd);
    set(ud.gcf,'userdata',ud);
    
    %-- switch off the interactive rectangle mode
    set(ud.gcf,'WindowButtonMotionFcn',{@creaseg_mouseMove});


%------------------------------------------------------------------    
function stopdragmultiellipse(src,evt)

    %-- get structures
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');
    
    %-- delete enclosing rectangle
    if ( size(fd.handleElliRect,2)> 0 )
        delete(fd.handleElliRect{end}(1));
    end
    
    %-- create multi-ellipse mask
    if ( size(fd.handleElliRect,2) > 0 )
        X = get(fd.handleElliRect{end}(2),'X');
        Y = get(fd.handleElliRect{end}(2),'Y');
        fd.levelset = xor(roipoly(fd.data,X,Y),fd.levelset);        
    end
    
    %-- save initialization info
    ud.LastPlot = 'levelset';
    fd.method = 'Initial region';    
    
    %-- save structure
    set(ud.imageId,'userdata',fd);
    set(ud.gcf,'userdata',ud);
    
    %-- switch off the interactive rectangle mode
    set(ud.gcf,'WindowButtonMotionFcn',{@creaseg_mouseMove});
    
    
%------------------------------------------------------------------
%-- Draw Ellipse from rectangle info
function [X,Y] = computeEllipse(x,y,w,h)
    
    %-- determine major axis
    xa = [x+w/2,x+w/2];
    ya = [y,y+h];
    
    %-- determine minor axis
    xi = [x,x+w];
    yi = [y+h/2,y+h/2];
    
    %-- determine centroid based on major axis selection
    x0 = mean(xa);
    y0 = mean(ya);
    
    %-- determine a and b from user input
    a = sqrt(diff(xa)^2 + diff(ya)^2)/2;
    b = sqrt(diff(xi)^2 + diff(yi)^2)/2;
    
    %-- determine rho based on major axis selection
    rho = atan(diff(xa)/diff(ya));

    %-- prepare display
    theta = [-0.03:0.01:2*pi];

    %-- Parametric equation of the ellipse
    %----------------------------------------
    x = a*cos(theta);
    y = b*sin(theta);

    %-- Coordinate transform 
    %----------------------------------------
    Y = cos(rho)*x - sin(rho)*y;
    X = sin(rho)*x + cos(rho)*y;
    X = X + x0;
    Y = Y + y0;

    
% %------------------------------------------------------------------    
% function drawMultiManualContours(src,evt)
%         
%     %-- get structures
%     fig = findobj(0,'tag','creaseg');
%     ud = get(fig,'userdata');
%     fd = get(ud.imageId,'userdata'); 
%     
%     pos = floor(get(ud.gca(1),'CurrentPoint'));
%     if ~( pos(1,1) < size(fd.data,2) && pos(1,1) > 1 && pos(1,2) < size(fd.data,1) && pos(1,2) >1 )
%         return; %Clic outside the image => do nothing
%     end
%        
%     if ( strcmp(get(ud.gcf,'SelectionType'),'normal') )
%    
%         %-- disable run, pointer and pan button
%         set(ud.buttonAction(2),'enable','off');
%         set(ud.buttonAction(3),'enable','off');
%         set(ud.buttonAction(6),'enable','off');        
%         
%         %-- delete any overlay lines
%         if ( size(fd.handleManual,2)>0 )
%             for k=1:size(fd.handleManual{end},1)
%                 if ( fd.handleManual{end}(k) ~= 0 )
%                     delete(fd.handleManual{end}(k));
%                 end
%             end
%         else
%             fd.handleManual{1} = 0;
%         end         
%         
%         %-- Get point coordinates
%         pt = get(ud.gca,'CurrentPoint');
%         pt = pt(1,1:2);
%         if (isempty(fd.points))
%             fd.points = [pt(1),pt(2)];
%             hold on; h = plot(pt(1), pt(2), 'oy', 'linewidth', 2);
%             fd.handleManual{end} = h;
%         else
%             fd.points(end+1,:) = [pt(1),pt(2)];
%             color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
%             
%             switch ud.Spline
%                 case 0
%                     hold on; h1 = plot(fd.points(:,1),fd.points(:,2),'--','color',color{1},'Linewidth',2);                        
%                     tmp = fd.points(1,:); tmp(end+1,:) = fd.points(end,:);
%                     h2 = plot(tmp(:,1), tmp(:,2), 'y--', 'linewidth', 2);
%                 case 1
%                     if size(fd.points,1) == 2
%                         spline = cscvn([[fd.points(:,2); fd.points(1,2)]'; [fd.points(:,1); fd.points(1,1)]']);
%                         A = fnplt(spline,'.');
%                         hold on; h2 = plot(A(2,:),A(1,:),'y--','Linewidth',2);
%                         h1 = [];
%                     else
%                        spline = cscvn([[fd.points(:,2); fd.points(1,2)]'; [fd.points(:,1); fd.points(1,1)]']);
%                         A = fnplt(spline,'.');
%                         a = find(A(2,:) == fd.points(end,1),1);
%                         hold on; h1 = plot(A(2,1:a),A(1,1:a),'--','color',color{1},'Linewidth',2);
%                         h2 = plot(A(2,a:end),A(1,a:end),'y--','Linewidth',2);
%                     end
%             end
%                         
%             h3 = plot(fd.points(:,1), fd.points(:,2), 'oy', 'linewidth', 2);
%             hold off;
%             fd.handleManual{end} = [h1;h2;h3];
%         end
%         
%         
%     else %-- create final contour
%             
%         %-- enable run, pointer and pan button
%         set(ud.buttonAction(2),'enable','on');
%         set(ud.buttonAction(3),'enable','on');
%         set(ud.buttonAction(6),'enable','on');        
%         
%         %-- display final contour
%         if ( size(fd.points,1)>2 )            
%             %-- delete any overlay lines
%             if ( size(fd.handleManual,2)>0 )
%                 for k=1:size(fd.handleManual{end},1)
%                     delete(fd.handleManual{end}(k));
%                 end
%             end
%             %--
%             tmp = fd.points;
%             tmp(end+1,:) = tmp(1,:);
%             color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
%             
%             switch ud.Spline
%                 case 0
%                     hold on; h = plot(tmp(:,1),tmp(:,2),'color',color{1},'Linewidth',2); hold off;
%                 case 1
%                    spline = cscvn([tmp(:,2)'; tmp(:,1)']);
%                     A = fnplt(spline,'.');
%                     hold on; h = plot(A(2,:),A(1,:),'color',color{1},'Linewidth',2); hold off;
%             end
%             fd.handleManual{end} = h;
%             %-- create manual mask
%             X = get(fd.handleManual{end},'X');
%             Y = get(fd.handleManual{end},'Y');
%             fd.levelset = xor(roipoly(fd.data,X,Y),fd.levelset);
%             %-- save initialization info
%             ud.LastPlot = 'levelset';
%             fd.method = 'Initial region';              
%             %-- prepare next contour            
%             fd.handleManual{end+1} = 0;                        
%         end
%         fd.points = [];
%         
%     end
%     
%     %-- save structure
%     set(ud.imageId,'userdata',fd);
%     set(ud.gcf,'userdata',ud);
       
    
%------------------------------------------------------------------        
function displayDrawingInfo(ud,flag,var)    

    if (~flag)

        switch var
            case 1  %-- draw rectangle
                set(ud.txtInfo1,'string',sprintf('Click and drag \nto draw a rectangle'),'color','y');
                set(ud.txtInfo2,'string','');
                set(ud.txtInfo3,'string','');
                set(ud.txtInfo4,'string','');
                set(ud.txtInfo5,'string','');                

            case 2  %-- draw ellipse
                set(ud.txtInfo1,'string',sprintf('Click and drag \nto draw an ellipse'),'color','y');
                set(ud.txtInfo2,'string','');
                set(ud.txtInfo3,'string','');
                set(ud.txtInfo4,'string','');
                set(ud.txtInfo5,'string','');

            case 3  %-- draw manual points
                set(ud.txtInfo1,'string',sprintf('Left click to add a point\nRight click to end'),'color','y');
                set(ud.txtInfo2,'string','');
                set(ud.txtInfo3,'string','');
                set(ud.txtInfo4,'string','');     
                set(ud.txtInfo5,'string','');

            case 4  %-- draw multi-rectangle
                set(ud.txtInfo1,'string',sprintf('Click and drag \nto draw multi-rectangles'),'color','y');
                set(ud.txtInfo2,'string','');
                set(ud.txtInfo3,'string','');
                set(ud.txtInfo4,'string','');  
                set(ud.txtInfo5,'string','');

            case 5  %-- draw multi-ellipse
                set(ud.txtInfo1,'string',sprintf('Click and drag \nto draw multi-ellipses'),'color','y');
                set(ud.txtInfo2,'string','');
                set(ud.txtInfo3,'string','');
                set(ud.txtInfo4,'string','');  
                set(ud.txtInfo5,'string','');

            case 6  %-- draw multi-manual points
                set(ud.txtInfo1,'string',sprintf('Left click to add a point\nRight click to end'),'color','y');
                set(ud.txtInfo2,'string','');
                set(ud.txtInfo3,'string','');
                set(ud.txtInfo4,'string','');            
                set(ud.txtInfo5,'string','');

        end 

    end    
    
