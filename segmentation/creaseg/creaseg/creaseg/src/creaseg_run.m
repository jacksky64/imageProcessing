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


function creaseg_run(src,evt)

    %-- parameters
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');

    if ( isempty(fd.data) )
        return;
    end    

    if ( sum(fd.levelset(:)) == 0 )
        set(ud.txtInfo1,'string',sprintf('Error: No initial contour has been given'),'color',[1 0 0]);
        return;
    end

    %-- deal with initialization mode
    set(ud.gcf,'WindowButtonDownFcn','');
    set(ud.gcf,'WindowButtonUpFcn','');
    for k=3:size(ud.handleInit,1)
        set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
    end    
    
    %--
    fd.seg = [];   
    img = fd.visu;
    levelset = fd.levelset;
    display = 1;
    color = ud.colorSpec(get(ud.handleContourColor,'userdata'));
    ud.LastPlot = 'levelset';

    %-- set mouse pointer to watch
    set(fig,'pointer','watch');
    drawnow;
    
    %-- invoke function that corresponds to the selected method
    numIts = 0;
    numMethod = find(strcmp(get(ud.handleIconAlgo,'State'),'on'));
    if isempty(numMethod)
        creaseg_cleanOverlays();
        set(ud.txtInfo1,'string',sprintf('Error: No algorithm has been selected'),'color',[1 0 0]);
        set(fig,'pointer','arrow');
        return
    else % Displaying the corresponding panel
        for k=1:size(ud.handleAlgoConfig,1)
            set(ud.handleAlgoConfig(k),'Visible','off');
            if k<size(ud.handleAlgoConfig,1)-1
                set(ud.handleIconAlgo(k),'State','off');
            end
        end
        set(ud.handleAlgoConfig(numMethod),'Visible','on');
        set(ud.handleIconAlgo(numMethod),'State','on');
    end

    %-- clean overlays and update fd structure
    creaseg_cleanOverlays();
    fd = get(ud.imageId,'userdata');
    
    switch numMethod(1)
                
        case 1  %-- Caselles
            [seg,levelset,numIts] = run_caselles(ud,img,levelset,color,display);
            fd.method = 'Caselles';

        case 2  %-- Chan & Vese          
            [seg,levelset,numIts] = run_chanvese(ud,img,levelset,color,display);
            fd.method = 'Chan & Vese';

        case 3  %-- Chunming Li
            [seg,levelset,numIts] = run_chunmingli(ud,img,levelset,color,display);
            fd.method = 'Chunming Li';

        case 4  %-- Lankton
            [seg,levelset,numIts] = run_lankton(ud,img,levelset,color,display);
            fd.method = 'Lankton';

        case 5  %-- Bernard
            [seg,levelset,numIts] = run_bernard(ud,img,levelset,color,display);
            fd.method = 'Bernard';

        case 6  %-- Shi
            [seg,levelset,numIts] = run_shi(ud,img,levelset,color,display);
            fd.method = 'Shi';

        case 7  %-- Personal
%             [seg,levelset,numIts] = run_personal(ud,img,levelset,color,display);
%             fd.method = 'Personal';

        case {8, 9}  %-- Comparison
        test = 0;
        for i=1:1:7
            test = test + get(ud.handleAlgoComparison(6+i),'Value');
        end
        if test ~= 0 % Checking if at least one algorithm has been selected
            if max(fd.reference(:)) ~= 0 % Checking if a reference has been given
                % Displaying the Results panel
                for k=1:size(ud.handleAlgoConfig,1)
                    set(ud.handleAlgoConfig(k),'Visible','off');
                    if k<size(ud.handleAlgoConfig,1)-1
                        set(ud.handleIconAlgo(k),'State','off');
                    end
                end
                set(ud.handleAlgoConfig(9),'Visible','on');
                set(ud.handleIconAlgo(8),'State','on');
                
                % Enabling the visual check boxes and reseting them
                set(ud.handleAlgoResults(5),'Value',1);
                for i=1:1:7
                    if get(ud.handleAlgoComparison(6+i),'Value')
                        set(ud.handleAlgoResults(5+i),'Enable','on');
                        set(ud.handleAlgoResults(5+i),'Value',1);
                    else
                        set(ud.handleAlgoResults(5+i),'Enable','off');
                        set(ud.handleAlgoResults(5+i),'Value',0);
                    end
                end

                % Running the comparison
                fd.seg = run_comp(ud,img,levelset,color);
                fd.method = 'Comparison';

                %-- UPDATE FD AND UD STRUCTURES ATTACHED TO IMAGEID AND FIG HANDLES
                set(ud.imageId,'userdata',fd);
                set(fig,'userdata',ud);

                % Showing all contours
                creaseg_plotresults(src,evt)

                set(ud.handleAlgoComparison(24),'Enable','on');
                set(ud.txtInfo1,'string','','color',[1 1 0]);
                ud.LastPlot = 'results';
            else
                axes(get(ud.imageId,'parent'));
                delete(findobj(get(ud.imageId,'parent'),'type','line'));      
                set(ud.txtInfo1,'string',sprintf('Error: No reference has been given'),'color',[1 0 0]);
            end
        else
            axes(get(ud.imageId,'parent'));
            delete(findobj(get(ud.imageId,'parent'),'type','line'));      
            set(ud.txtInfo1,'string',sprintf('Error: No algorithm has been selected'),'color',[1 0 0]);
        end
    end


    %-- UPDATE FD AND UD STRUCTURES ATTACHED TO IMAGEID AND FIG HANDLES
    fd.levelset = levelset;
    set(ud.imageId,'userdata',fd);
    set(fig,'userdata',ud);

    %-- set mouse pointer to arrow
    set(fig,'pointer','arrow');

    %-- put pointer button to select
    set(ud.buttonAction(3),'BackgroundColor',[160/255 130/255 95/255]);    
    
    %--
    if numMethod<8
        set(ud.txtInfo1,'string',sprintf('End of run in %2d its',numIts),'color',[1 1 0]);
    end
    

%---------------------------------------------------------------------
%-- AUXILIARY FUNCTIONS ----------------------------------------------
%---------------------------------------------------------------------
    
function [seg,levelset,numIts] = run_caselles(ud,img,levelset,color,display) %-- Caselles
    max_its = str2double(get(ud.handleAlgoCaselles(4),'string'));
    thresh = str2double(get(ud.handleAlgoCaselles(6),'string'));
    propag = str2double(get(ud.handleAlgoCaselles(10),'string')); 
    %--
    set(ud.txtInfo2,'string',sprintf('Caselles'),'color',[1 1 0]);
    [seg,levelset,numIts] = creaseg_caselles(img,levelset,max_its,propag,thresh,color,display);
    
function [seg,levelset,numIts] = run_chanvese(ud,img,levelset,color,display) %-- Chan & Vese
    max_its = str2double(get(ud.handleAlgoChanVese(4),'string'));
    thresh = str2double(get(ud.handleAlgoChanVese(6),'string'));
    curvature = str2double(get(ud.handleAlgoChanVese(10),'string'));    
    %--
    set(ud.txtInfo2,'string',sprintf('Chan & Vese'),'color',[1 1 0]);
    [seg,levelset,numIts] = creaseg_chanvese(img,levelset,max_its,curvature,thresh,color,display);

function [seg,levelset,numIts] = run_chunmingli(ud,img,levelset,color,display) %-- Chunming Li
    max_its = str2double(get(ud.handleAlgoLi(4),'string'));
    thresh = str2double(get(ud.handleAlgoLi(6),'string'));
    length = str2double(get(ud.handleAlgoLi(10),'string'));
    regularization = str2double(get(ud.handleAlgoLi(12),'string'));
    scale = str2double(get(ud.handleAlgoLi(14),'string'));
    %--
    set(ud.txtInfo2,'string',sprintf('Li'),'color',[1 1 0]);
    [seg,levelset,numIts] = creaseg_chunmingli(img,levelset,max_its,length,regularization,scale,thresh,color,display);

function [seg,levelset,numIts] = run_lankton(ud,img,levelset,color,display) %-- Lankton
    max_its = str2double(get(ud.handleAlgoLankton(4),'string'));
    thresh = str2double(get(ud.handleAlgoLankton(6),'string'));
    method = get(ud.handleAlgoLankton(10),'value');
    neigh = get(ud.handleAlgoLankton(12),'value');
    curvature = str2double(get(ud.handleAlgoLankton(14),'string'));
    radius = str2double(get(ud.handleAlgoLankton(16),'string'));
    %--
    set(ud.txtInfo2,'string',sprintf('Lankton'),'color',[1 1 0]);
    [seg,levelset,numIts] = creaseg_lankton(img,levelset,max_its,radius,curvature,thresh,method,neigh,color,display);

function [seg,levelset,numIts] = run_bernard(ud,img,levelset,color,display) %-- Bernard
    max_its = str2double(get(ud.handleAlgoBernard(4),'string'));
    thresh = str2double(get(ud.handleAlgoBernard(6),'string'));
    scale = str2double(get(ud.handleAlgoBernard(10),'string'));
    %--
    set(ud.txtInfo2,'string',sprintf('Bernard'),'color',[1 1 0]);
    [seg,levelset,numIts] = creaseg_bernard(img,levelset,max_its,scale,thresh,color,display);

function [seg,levelset,numIts] = run_shi(ud,img,levelset,color,display) %-- Shi
    max_its = str2double(get(ud.handleAlgoShi(4),'string'));
    na = str2double(get(ud.handleAlgoShi(8),'string'));
    ns = str2double(get(ud.handleAlgoShi(10),'string'));
    sigma = str2double(get(ud.handleAlgoShi(12),'string'));
    ng = str2double(get(ud.handleAlgoShi(14),'string'));
    %--
    set(ud.txtInfo2,'string',sprintf('Shi'),'color',[1 1 0]);
    [seg,levelset,numIts] = creaseg_shi(img,levelset,max_its,na,ns,sigma,ng,color,display);
    
% function [seg,levelset,numIts] = run_personal(ud,img,levelset,color,display)
%     max_its = str2double(get(ud.handleAlgoPersonal(4),'string'));
%     thresh = str2double(get(ud.handleAlgoPersonal(6),'string'));
%     parameter1 = str2double(get(ud.handleAlgoPersonal(10),'string'));
%     parameter2 = str2double(get(ud.handleAlgoPersonal(12),'string'));
%     %-- Run your personal method here
%     set(ud.txtInfo2,'string',sprintf('Personal Algorithm'),'color',[1 1 0]);
%     set(ud.txtInfo2,'string',sprintf(''),'color',[1 1 0]);

              
function seg = run_comp(ud,img,levelset,color) %-- Comparison  

    fd = get(ud.imageId,'userdata');
    seg = zeros(size(img,1),size(img,2),7);
    
    res = zeros(7,2);
    d = get(ud.handleAlgoComparison(22),'Value');
    
    if ud.Version
        set(ud.handleAlgoResults(2), 'Data', res);
        switch d % switching depending on the selected criteria
            case 1 % displaying its name in the table
                name = get(ud.handleAlgoResults(2), 'ColumnName');
                name(2) = {'Dice'};
                set(ud.handleAlgoResults(2), 'ColumnName', name);
            case 2
                name = get(ud.handleAlgoResults(2), 'ColumnName');
                name(2) = {'PSNR'};
                set(ud.handleAlgoResults(2), 'ColumnName', name);
            case 3
                name = get(ud.handleAlgoResults(2), 'ColumnName');
                name(2) = {'Hausdorff'};
                set(ud.handleAlgoResults(2), 'ColumnName', name);
            case 4
                name = get(ud.handleAlgoResults(2), 'ColumnName');
                name(2) = {'MSSD'};
                set(ud.handleAlgoResults(2), 'ColumnName', name);
        end
    end
    
    display = get(ud.handleAlgoComparison(23),'Value');
    
    if get(ud.handleAlgoComparison(7),'Value')  %-- Caselles
        tic;
        [junk,seg(:,:,1)] = run_caselles(ud,img,levelset,color,display);
        res(1,1) = toc;
        res(1,2) = distance(fd.reference, seg(:,:,1), d);
    end

    if get(ud.handleAlgoComparison(8),'Value')  %-- Chan & Vese
        tic;
        [junk,seg(:,:,2)] = run_chanvese(ud,img,levelset,color,display);
        res(2,1) = toc;
        res(2,2) = distance(fd.reference, seg(:,:,2), d);
    end
    
    if get(ud.handleAlgoComparison(9),'Value')  %-- Chunming Li
        tic;
        [junk,seg(:,:,3)] = run_chunmingli(ud,img,levelset,color,display);
        res(3,1) = toc;
        res(3,2) = distance(fd.reference, seg(:,:,3), d);
    end
    
    if get(ud.handleAlgoComparison(10),'Value')  %-- Lankton
        tic;
        [junk,seg(:,:,4)] = run_lankton(ud,img,levelset,color,display);
        res(4,1) = toc;
        res(4,2) = distance(fd.reference, seg(:,:,4), d);
    end
    
    if get(ud.handleAlgoComparison(11),'Value')  %-- Bernard
        tic;
        [junk,seg(:,:,5)] = run_bernard(ud,img,levelset,color,display);
        res(5,1) = toc;
        res(5,2) = distance(fd.reference, seg(:,:,5), d);
    end
    
    if get(ud.handleAlgoComparison(12),'Value')  %-- Shi
        tic;
        [junk,seg(:,:,6)] = run_shi(ud,img,levelset,color,display);
        res(6,1) = toc;
        res(6,2) = distance(fd.reference, seg(:,:,6), d);
    end
    
%     if get(ud.handleAlgoComparison(13),'Value')  %-- Personal
%         tic;
%         [junk,seg(:,:,7)] = run_personal(ud,img,levelset,color,display);
%         res(7,1) = toc;
%         res(7,2) = distance(fd.reference, seg(:,:,7), d);
%     end

    set(ud.txtInfo2,'string','','color',[1 1 0]);

    if ud.Version
        set(ud.handleAlgoResults(2),'Data',res);
    end
    switch d
        case 1, dstr = 'Dice';
        case 2, dstr = 'PSNR';
        case 3, dstr = 'Hausdorff';
        case 4, dstr = 'MSSD';
    end
    save_results(res,dstr);
    
    
function dist = distance(ref,img,d)
    % Function that call the correct distance function
    img = img <= 0; % Creating a mask from the LS function
        
    switch d
        case 1, dist = dist_Dice(ref,img);
        case 2, dist = dist_PSNR(ref,img);
        case 3, dist = dist_Hausdorff(ref,img);
        case 4, dist = dist_MSSD(ref,img);
    end

function dist = dist_Dice(ref,img)
    % Calculation of the Dice Coefficient

    idx_img = find(img == 1);
    idx_ref = find(ref == 1);
    idx_inter = find((img == 1) & (ref == 1));

    dist = 2*length(idx_inter)/(length(idx_ref)+length(idx_img));

function dist = dist_PSNR(ref,img)
    % Calculation of the PSNR

    [nrow, ncol] = size(ref);

    idx1 = find((ref == 1)&(img == 0));
    idx2 = find((ref == 0)&(img == 1));
    
    dist = (length(idx1)+length(idx2))/(nrow*ncol);
    dist = -10*log10(dist);

function dist = dist_Hausdorff(ref,img)
    % Calculation of the Hausdorff distance
    
    % Create a distance function for the reference and result
    phi_ref = bwdist(ref)+bwdist(1-ref);
    phi_img = bwdist(img)+bwdist(1-img);
    
    % Get the reference and image contour
    se = strel('diamond',1);
    
    contour_ref = ref - imerode(ref,se);
    contour_img = img - imerode(img,se);
    
    dist = max(max(phi_ref(contour_img == 1)), max(phi_img(contour_ref == 1)));

function dist = dist_MSSD(ref,img)
    % Calculation of the Mean Sum of Square Distance

    % Create a distance function for the reference and result
    phi_ref = bwdist(ref)+bwdist(1-ref);
    phi_img = bwdist(img)+bwdist(1-img);
    
    % Get the reference and image contour
    se = strel('diamond',1);
    
    contour_ref = ref - imerode(ref,se);
    contour_img = img - imerode(img,se);
    
    dist1 = sum(phi_ref(contour_img == 1).^2)/(sum(contour_img(:)) + eps);
    dist2 = sum(phi_img(contour_ref == 1).^2)/(sum(contour_ref(:)) + eps);
    
    dist = max(dist1,dist2);


function save_results(res,dstr)
    % Open or create the .txt File
    fid = fopen('results/results.txt','w');

    % Write the results
    fprintf(fid,'%s\t %s\t %s\n','Algorithm','Calculation Time', dstr);
    
    fprintf(fid,'%s\t \t %3.3f\t \t %1.3f\n','Caselles',res(1,1),res(1,2));
    fprintf(fid,'%s\t \t %3.3f\t \t %1.3f\n','Chan & Vese',res(2,1),res(2,2));
    fprintf(fid,'%s\t \t %3.3f\t \t %1.3f\n','Chunming Li',res(3,1),res(3,2));
    fprintf(fid,'%s\t \t \t %3.3f\t \t %1.3f\n','Lankton',res(4,1),res(4,2));
    fprintf(fid,'%s\t \t \t %3.3f\t \t %1.3f\n','Bernard',res(5,1),res(5,2));
    fprintf(fid,'%s\t \t \t %3.3f\t \t %1.3f\n','Shi',res(6,1),res(6,2));
    fprintf(fid,'%s\t \t %3.3\t \t %1.3f\n','Personal',res(7,1),res(7,2));
    
    % Close the file
    fclose(fid);
