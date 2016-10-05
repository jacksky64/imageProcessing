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


function creaseg_gui(ud)
    
    %-- Checking the Matlab version and if the Spline Toolbox is available
    a = ver;
    ud.Spline = 0;
    i = 1;
    
    while ( (i <= size(a,2)) && (~strcmp(a(i).Name,'MATLAB')) )
        i = i+ 1;
    end
    idx = find(a(i).Version == '.');
    v1 = str2double(a(i).Version(1:idx-1));        v2 = str2double(a(i).Version(idx+1:end));
    if ( (v1 >= 7) && (v2 >= 6) )
        ud.Version = 1;
    else
        ud.Version = 0;
    end
    
    ud.LastPlot = '';

    %-- create main figure
    ss = get(0,'ScreenSize');
    ud.gcf = figure('position',[300 200 ss(3)*2/3 ss(4)*2/3],'menubar','none','tag','creaseg','color',[87/255 86/255 84/255],'name','CREASEG','NumberTitle','off');

    
    %-- create main menu
    h1 = uimenu('parent',ud.gcf,'label','File');
    uimenu('parent',h1,'label','Open','callback','creaseg_loadimage');
    uimenu('parent',h1,'label','Close','callback',{@closeInterface});
    uimenu('parent',h1,'label','Save screen','callback',{@saveResult,1});
    uimenu('parent',h1,'label','Save result','callback',{@saveResult,3},'separator','on');
    
    
    
    %-- create Algorithm item submenu
    h1 = uimenu('parent',ud.gcf,'label','Algorithms');
    h2 = uimenu('parent',h1,'label','1-Caselles','callback',{@manageAlgoItem,1},'ForegroundColor',[255/255, 0/255, 0/255],'Checked','on');
    h3 = uimenu('parent',h1,'label','2-Chan & Vese','callback',{@manageAlgoItem,2});
    h4 = uimenu('parent',h1,'label','3-Chunming Li','callback',{@manageAlgoItem,3});
    h5 = uimenu('parent',h1,'label','4-Lankton','callback',{@manageAlgoItem,4});
    h6 = uimenu('parent',h1,'label','5-Bernard','callback',{@manageAlgoItem,5});
    h7 = uimenu('parent',h1,'label','6-Shi','callback',{@manageAlgoItem,6});
    h8 = uimenu('parent',h1,'label','7-Personal Algorithm','callback',{@manageAlgoItem,7});
    h9 = uimenu('parent',h1,'label','C-Comparison Mode','callback',{@manageCompItem,1},'separator','on');
    ud.handleMenuAlgorithms = [h2;h3;h4;h5;h6;h7;h8;h9];
    S = ['1-Caselles   ';'2-Chan & Vese';'3-Chunming Li'; ...
         '4-Lankton    ';'5-Bernard    ';'6-Shi        '; ...
         '7-Personal   ';'C-Comparison '];
    ud.handleMenuAlgorithmsName = cellstr(S);
    
    
    %-- create Tool item submenu
    h1 = uimenu('parent',ud.gcf,'label','Tool');
    uimenu('parent',h1,'label','Draw Initial Region','callback',{@manageAction,1});
    uimenu('parent',h1,'label','Run','callback','creaseg_run');
    
    %-- create Help item submenu
    h1 = uimenu('parent',ud.gcf,'label','Help');
    uimenu('parent',h1,'label','About Creaseg','callback',{@open_help});
    uimenu('parent',h1,'label','About the author','callback',{@open_author},'separator','on');
        
    
    %-- create Image Area
    ud.imagePanel = uipanel('units','normalized','position',[0.35 0.05 0.62 0.80],'BorderType','line','Backgroundcolor',[37/255 37/255 37/255],'HighlightColor',[0/255 0/255 0/255],'tag','imgPanel');
    ud.gca = axes('parent',ud.imagePanel,'Tag','mainAxes','DataAspectRatio',[1 1 1],'units','normalized','position',[0.05 0.05 0.9 0.9],'visible','off','tag','mainAxes');
    ud.img = image([1 256],[1 256],repmat(37/255,[256,256,3]),'parent',ud.gca,'Tag','mainImg');
    axis(ud.gca,'equal');
    set(ud.gca,'visible','off');
    pos = get(ud.gca,'position');
    colormap(gray(256));
    ud.imageId = ud.img;
    ud.imageMask(1,:) = pos;    
    ud.panelIcons = uipanel('parent',ud.gcf,'units','normalized','position',[0.35 0.87 0.42 0.08],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255],'tag','panelIcons','userdata',0);
    ud.panelText = uipanel('parent',ud.gcf,'units','normalized','position',[0.80 0.87 0.17 0.08],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    
    %--
    load('misc/icons/drawInitialization.mat');
    ha1 = uicontrol('parent',ud.panelIcons,'units','normalized','position',[0.10 0.25 0.08 0.5],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[160/255 130/255 95/255],'tooltip','draw initial region','Callback',{@manageAction,1});
    load('misc/icons/run2.mat');
    ha2 = uicontrol('parent',ud.panelIcons,'units','normalized','position',[0.22 0.25 0.08 0.5],'Style','pushbutton','CData',cdata,'Enable','On','Backgroundcolor',[240/255 173/255 105/255],'tooltip','Run','Callback',{@manageAction,2});
    load('misc/icons/arrow.mat');
    ha3 = uicontrol('parent',ud.panelIcons,'units','normalized','position',[0.34 0.25 0.08 0.5],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'tooltip','Pointer','Callback',{@manageAction,3});
    load('misc/icons/zoomIn.mat');
    ha4 = uicontrol('parent',ud.panelIcons,'units','normalized','position',[0.46 0.25 0.08 0.5],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'tooltip','Zoom In','Callback',{@manageAction,4});
    load('misc/icons/zoomOut.mat');
    ha5 = uicontrol('parent',ud.panelIcons,'units','normalized','position',[0.58 0.25 0.08 0.5],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'tooltip','Zoom Out','Callback',{@manageAction,5});
    load('misc/icons/pan.mat');
    ha6 = uicontrol('parent',ud.panelIcons,'units','normalized','position',[0.70 0.25 0.08 0.5],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'tooltip','Pan','Callback',{@manageAction,6});
    load('misc/icons/info.mat');
    ha7 = uicontrol('parent',ud.panelIcons,'units','normalized','position',[0.82 0.25 0.08 0.5],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'tooltip','Image Info','Callback',{@manageAction,7});
    ud.buttonAction = [ha1;ha2;ha3;ha4;ha5;ha6;ha7];
    
    
	%-- 
    ud.txtPositionIntensity = uicontrol('parent',ud.panelText,'style','text','enable','inactive','fontsize',8,...
        'backgroundcolor',[113/255 113/255 113/255],'foregroundcolor',[.9 .9 .9],'horizontalalignment','left');
    SetTextIntensityPosition(ud);
    
    ud.txtInfo1 = text('Parent',ud.gca,'units','normalized','position',[0.05,0.95], ...
        'string','','color',[255/255 255/255 0/255],'FontSize',8);
    ud.txtInfo2 = text('Parent',ud.gca,'units','normalized','position',[0.05,0.90], ...
        'string','','color',[255/255 255/255 0/255],'FontSize',8);
    ud.txtInfo3 = text('Parent',ud.gca,'units','normalized','position',[0.05,0.85], ...
        'string','','color',[255/255 255/255 0/255],'FontSize',8);      
    ud.txtInfo4 = text('Parent',ud.gca,'units','normalized','position',[0.05,0.80], ...
        'string','','color',[255/255 255/255 0/255],'FontSize',8);
    ud.txtInfo5 = text('Parent',ud.gca,'units','normalized','position',[0.05,0.75], ...
        'string','','color',[255/255 255/255 0/255],'FontSize',8); 
    
    %-- create Toolbar
    hToolbar = uitoolbar('Parent',ud.gcf,'HandleVisibility','callback');
    load('misc/icons/open.mat');
    uipushtool('Parent',hToolbar,'TooltipString','Open File','CData',cdata,'HandleVisibility','callback','ClickedCallback','creaseg_loadimage');
    load('misc/icons/screenshot.mat');
    uipushtool('Parent',hToolbar,'TooltipString','Save Screen','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@saveResult,1});
    load('misc/icons/save.mat'); 
    uipushtool('Parent',hToolbar,'TooltipString','Save data','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@saveResult,3});
    load('misc/icons/one.mat');
    ud.AlgoIcon(:,:,:,1) = cdata;
    hp1 = uitoggletool('Parent',hToolbar,'Separator','on','TooltipString','Caselles','State','On','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageAlgoItem,1});
    load('misc/icons/two.mat');
    ud.AlgoIcon(:,:,:,2) = cdata;
    hp2 = uitoggletool('Parent',hToolbar,'TooltipString','ChanVese','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageAlgoItem,2});
    load('misc/icons/three.mat'); 
    ud.AlgoIcon(:,:,:,3) = cdata;
    hp3 = uitoggletool('Parent',hToolbar,'TooltipString','Chunming Li','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageAlgoItem,3});
    load('misc/icons/four.mat'); 
    ud.AlgoIcon(:,:,:,4) = cdata;
    hp4 = uitoggletool('Parent',hToolbar,'TooltipString','Lankton','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageAlgoItem,4});
    load('misc/icons/five.mat'); 
    ud.AlgoIcon(:,:,:,5) = cdata;
    hp5 = uitoggletool('Parent',hToolbar,'TooltipString','Bernard','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageAlgoItem,5});
    load('misc/icons/six.mat'); 
    ud.AlgoIcon(:,:,:,6) = cdata;
    hp6 = uitoggletool('Parent',hToolbar,'TooltipString','Shi','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageAlgoItem,6});   
    load('misc/icons/seven.mat');
    ud.AlgoIcon(:,:,:,7) = cdata;
    hp7 = uitoggletool('Parent',hToolbar,'TooltipString','Personal Algorithm','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageAlgoItem,7});
    load('misc/icons/comp.mat'); 
    ud.AlgoIcon(:,:,:,8) = cdata;
    hp8 = uitoggletool('Parent',hToolbar,'Separator','on','TooltipString','Comparison Mode','CData',cdata,'HandleVisibility','callback','ClickedCallback',{@manageCompItem,1});
    load('misc/icons/brushR.mat');
    hp9 = uipushtool('Parent',hToolbar,'Separator','on','TooltipString','Change contour color','CData',cdata,'HandleVisibility','callback','userdata',1,'ClickedCallback',{@changeContourColor});        
    ud.handleContourColor = hp9;
    load('misc/icons/help.mat');
    uipushtool('Parent',hToolbar,'Separator','on','TooltipString','Help','CData',cdata,'HandleVisibility','callback','userdata',1,'ClickedCallback',{@open_help});            
    
    ud.handleIconAlgo = [hp1;hp2;hp3;hp4;hp5;hp6;hp7;hp8];
    ud.colorSpec = {'r','g','b','y','w','k'};
 
    %-- Create Icon for selected algorithm (in Comparison Mode) 
    load('misc/icons/oneSel.mat'); 
    ud.AlgoIconSel(:,:,:,1) = cdata;
    load('misc/icons/twoSel.mat'); 
    ud.AlgoIconSel(:,:,:,2) = cdata;
    load('misc/icons/threeSel.mat'); 
    ud.AlgoIconSel(:,:,:,3) = cdata;
    load('misc/icons/fourSel.mat'); 
    ud.AlgoIconSel(:,:,:,4) = cdata;
    load('misc/icons/fiveSel.mat'); 
    ud.AlgoIconSel(:,:,:,5) = cdata;
    load('misc/icons/sixSel.mat'); 
    ud.AlgoIconSel(:,:,:,6) = cdata;
    load('misc/icons/sevenSel.mat'); 
    ud.AlgoIconSel(:,:,:,7) = cdata;
    
    
    %-- INTERFACE -> SEGMENTATION CONTROL
    h1 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h2 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h3 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h4 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h5 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h6 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h7 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h8 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    h9 = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'Visible','off','BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    hi = uipanel('parent',ud.gcf,'position',[0.03 0.05 0.30 0.9],'BorderType','line','Backgroundcolor',[87/255 86/255 84/255],'HighlightColor',[0/255 0/255 0/255]);
    ud.handleAlgoConfig = [h1;h2;h3;h4;h5;h6;h7;h8;h9;hi];
    
    
    %-- INTERFACE -> INITIALIZATION CONTROL
    hi1 = uicontrol('parent',hi,'units','normalized','position',[0 0.92 1 0.05],'Style','text','String','Initialization','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    hi2 = uipanel('parent',hi,'units','normalized','position',[0.07 0.05 0.85 0.85],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    load('misc/icons/rectangle.mat');
    hi3 = uicontrol('parent',hi2,'units','normalized','position',[0.35 0.80 0.30 0.05],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'Callback',{@creaseg_managedrawing,1});
    load('misc/icons/multirectangles.mat');
    hi4 = uicontrol('parent',hi2,'units','normalized','position',[0.35 0.70 0.30 0.05],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'Callback',{@creaseg_managedrawing,2});
    load('misc/icons/ellipse.mat');
    hi5 = uicontrol('parent',hi2,'units','normalized','position',[0.35 0.60 0.30 0.05],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'Callback',{@creaseg_managedrawing,3});
    load('misc/icons/multiellipses.mat');
    hi6 = uicontrol('parent',hi2,'units','normalized','position',[0.35 0.50 0.30 0.05],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'Callback',{@creaseg_managedrawing,4});
    load('misc/icons/manual.mat');
    hi7 = uicontrol('parent',hi2,'units','normalized','position',[0.35 0.40 0.30 0.05],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'Callback',{@creaseg_managedrawing,5});
    load('misc/icons/multimanuals.mat');
    hi8 = uicontrol('parent',hi2,'units','normalized','position',[0.35 0.30 0.30 0.05],'Style','pushbutton','CData',cdata,'Enable','On','BackgroundColor',[240/255 173/255 105/255],'Callback',{@creaseg_managedrawing,6});    
    ud.handleInit = [hi1;hi2;hi3;hi4;hi5;hi6;hi7;hi8];
    
    
    %-- INTERFACE -> CASELLES CONTROL
    h11 = uicontrol('parent',h1,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Caselles','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h12 = uipanel('parent',h1,'units','normalized','position',[0.07 0.75 0.85 0.15],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h13 = uicontrol('parent',h12,'units','normalized','position',[0.07 0.58 0.5 0.23],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h14 = uicontrol('parent',h12,'units','normalized','position',[0.60 0.61 0.3 0.23],'Style','edit','String','200','BackgroundColor',[240/255 173/255 105/255]);
    h15 = uicontrol('parent',h12,'units','normalized','position',[0.07 0.13 0.5 0.23],'Style','text','String','Convergence thres.','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h16 = uicontrol('parent',h12,'units','normalized','position',[0.60 0.16 0.3 0.23],'Style','edit','String','2','BackgroundColor',[240/255 173/255 105/255]);
    h17 = uicontrol('parent',h1,'units','normalized','position',[0.1 0.66 0.85 0.04],'Style','text','String','Specific parameters','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h18 = uipanel('parent',h1,'units','normalized','position',[0.07 0.05 0.85 0.61],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h181 = uicontrol('parent',h18,'units','normalized','position',[0.07 0.88 0.5 0.05],'Style','text','String','Propagation term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h182 = uicontrol('parent',h18,'units','normalized','position',[0.55 0.88 0.3 0.055],'Style','edit','String','1','BackgroundColor',[240/255 173/255 105/255]);
    ud.handleAlgoCaselles = [h11;h12;h13;h14;h15;h16;h17;h18;h181;h182];
    

    %-- INTERFACE -> CHAN VESE CONTROL
    h21 = uicontrol('parent',h2,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Chan & Vese','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h22 = uipanel('parent',h2,'units','normalized','position',[0.07 0.75 0.85 0.15],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h23 = uicontrol('parent',h22,'units','normalized','position',[0.07 0.58 0.5 0.23],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h24 = uicontrol('parent',h22,'units','normalized','position',[0.60 0.61 0.3 0.23],'Style','edit','String','200','BackgroundColor',[240/255 173/255 105/255]);
    h25 = uicontrol('parent',h22,'units','normalized','position',[0.07 0.13 0.5 0.23],'Style','text','String','Convergence thres.','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h26 = uicontrol('parent',h22,'units','normalized','position',[0.60 0.16 0.3 0.23],'Style','edit','String','2','units','normalized','BackgroundColor',[240/255 173/255 105/255]);
    h27 = uicontrol('parent',h2,'units','normalized','position',[0.1 0.66 0.85 0.04],'Style','text','String','Specific parameters','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h28 = uipanel('parent',h2,'units','normalized','position',[0.07 0.05 0.85 0.61],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h281 = uicontrol('parent',h28,'units','normalized','position',[0.07 0.88 0.5 0.05],'Style','text','String','Curvature term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h282 = uicontrol('parent',h28,'units','normalized','position',[0.55 0.88 0.3 0.055],'Style','edit','String','0.2','BackgroundColor',[240/255 173/255 105/255]);
    ud.handleAlgoChanVese = [h21;h22;h23;h24;h25;h26;h27;h28;h281;h282];
    
    
    %-- INTERFACE -> LI CONTROL
    h31 = uicontrol('parent',h3,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Chunming Li','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h32 = uipanel('parent',h3,'units','normalized','position',[0.07 0.75 0.85 0.15],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h33 = uicontrol('parent',h32,'units','normalized','position',[0.07 0.58 0.5 0.23],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h34 = uicontrol('parent',h32,'units','normalized','position',[0.60 0.61 0.3 0.23],'Style','edit','String','200','BackgroundColor',[240/255 173/255 105/255]);
    h35 = uicontrol('parent',h32,'units','normalized','position',[0.07 0.13 0.5 0.23],'Style','text','String','Convergence thres.','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h36 = uicontrol('parent',h32,'units','normalized','position',[0.60 0.16 0.3 0.23],'Style','edit','String','2','units','normalized','BackgroundColor',[240/255 173/255 105/255]);
    h37 = uicontrol('parent',h3,'units','normalized','position',[0.1 0.66 0.85 0.04],'Style','text','String','Specific parameters','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h38 = uipanel('parent',h3,'units','normalized','position',[0.07 0.05 0.85 0.61],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h39 = uicontrol('parent',h38,'units','normalized','position',[0.07 0.88 0.5 0.05],'Style','text','String','Length term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h391 = uicontrol('parent',h38,'units','normalized','position',[0.55 0.88 0.3 0.055],'Style','edit','String','0.003','BackgroundColor',[240/255 173/255 105/255]);
    h392 = uicontrol('parent',h38,'units','normalized','position',[0.07 0.78 0.5 0.05],'Style','text','String','Regularization term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h393 = uicontrol('parent',h38,'units','normalized','position',[0.55 0.78 0.3 0.055],'Style','edit','String','1','BackgroundColor',[240/255 173/255 105/255]);
    h394 = uicontrol('parent',h38,'units','normalized','position',[0.07 0.68 0.5 0.05],'Style','text','String','Scale term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h395 = uicontrol('parent',h38,'units','normalized','position',[0.55 0.68 0.3 0.055],'Style','edit','String','7','BackgroundColor',[240/255 173/255 105/255]);
    ud.handleAlgoLi = [h31;h32;h33;h34;h35;h36;h37;h38;h39;h391;h392;h393;h394;h395];
    
    %-- INTERFACE -> LANKTON CONTROL
    h41 = uicontrol('parent',h4,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Lankton','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h42 = uipanel('parent',h4,'units','normalized','position',[0.07 0.75 0.85 0.15],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h43 = uicontrol('parent',h42,'units','normalized','position',[0.07 0.58 0.5 0.23],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h44 = uicontrol('parent',h42,'units','normalized','position',[0.60 0.61 0.3 0.23],'Style','edit','String','200','BackgroundColor',[240/255 173/255 105/255]);
    h45 = uicontrol('parent',h42,'units','normalized','position',[0.07 0.13 0.5 0.23],'Style','text','String','Convergence thres.','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h46 = uicontrol('parent',h42,'units','normalized','position',[0.60 0.16 0.3 0.23],'Style','edit','String','2','units','normalized','BackgroundColor',[240/255 173/255 105/255]);
    h47 = uicontrol('parent',h4,'units','normalized','position',[0.1 0.66 0.85 0.04],'Style','text','String','Specific parameters','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h48 = uipanel('parent',h4,'units','normalized','position',[0.07 0.05 0.85 0.61],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h49 = uicontrol('parent',h48,'units','normalized','position',[0.07 0.88 0.5 0.05],'Style','text','String','Feature type','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h491 = uicontrol('parent',h48,'units','normalized','position',[0.55 0.90 0.39 0.04],'Style','popupmenu','String',{'Yezzi','Chan Vese'},'FontSize',9,'BackgroundColor',[240/255, 173/255, 105/255]);
    h492 = uicontrol('parent',h48,'units','normalized','position',[0.07 0.78 0.5 0.05],'Style','text','String','Neighborhood','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h493 = uicontrol('parent',h48,'units','normalized','position',[0.55 0.80 0.39 0.04],'Style','popupmenu','String',{'Circle','Square'},'FontSize',9,'BackgroundColor',[240/255, 173/255, 105/255]);
    h494 = uicontrol('parent',h48,'units','normalized','position',[0.07 0.68 0.5 0.05],'Style','text','String','Curvature term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h495 = uicontrol('parent',h48,'units','normalized','position',[0.55 0.68 0.3 0.06],'Style','edit','String','0.2','BackgroundColor',[240/255 173/255 105/255]);
    h496 = uicontrol('parent',h48,'units','normalized','position',[0.07 0.58 0.5 0.05],'Style','text','String','Radius term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h497 = uicontrol('parent',h48,'units','normalized','position',[0.55 0.58 0.3 0.06],'Style','edit','String','9','BackgroundColor',[240/255 173/255 105/255]);    
    ud.handleAlgoLankton = [h41;h42;h43;h44;h45;h46;h47;h48;h49;h491;h492;h493;h494;h495;h496;h497];    
    
    
    %-- INTERFACE -> BERNARD CONTROL
    h51 = uicontrol('parent',h5,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Bernard','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h52 = uipanel('parent',h5,'units','normalized','position',[0.07 0.75 0.85 0.15],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h53 = uicontrol('parent',h52,'units','normalized','position',[0.07 0.58 0.5 0.23],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h54 = uicontrol('parent',h52,'units','normalized','position',[0.60 0.61 0.3 0.23],'Style','edit','String','200','BackgroundColor',[240/255 173/255 105/255]);
    h55 = uicontrol('parent',h52,'units','normalized','position',[0.07 0.13 0.5 0.23],'Style','text','String','Convergence thres.','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h56 = uicontrol('parent',h52,'units','normalized','position',[0.60 0.16 0.3 0.23],'Style','edit','String','2','units','normalized','BackgroundColor',[240/255 173/255 105/255]);
    h57 = uicontrol('parent',h5,'units','normalized','position',[0.1 0.66 0.85 0.04],'Style','text','String','Specific parameters','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h58 = uipanel('parent',h5,'units','normalized','position',[0.07 0.05 0.85 0.61],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h59 = uicontrol('parent',h58,'units','normalized','position',[0.07 0.88 0.5 0.05],'Style','text','String','Scale term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h591 = uicontrol('parent',h58,'units','normalized','position',[0.55 0.88 0.3 0.055],'Style','edit','String','1','BackgroundColor',[240/255 173/255 105/255]);
    ud.handleAlgoBernard = [h51;h52;h53;h54;h55;h56;h57;h58;h59;h591];
    
    
    %-- INTERFACE -> SHI CONTROL
    h61 = uicontrol('parent',h6,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Shi','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h62 = uipanel('parent',h6,'units','normalized','position',[0.07 0.83 0.85 0.07],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h621 = uicontrol('parent',h62,'units','normalized','position',[0.07 0.2 0.5 0.5],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h622 = uicontrol('parent',h62,'units','normalized','position',[0.60 0.25 0.3 0.5],'Style','edit','String','200','BackgroundColor',[240/255 173/255 105/255]);
    h63 = uicontrol('parent',h6,'units','normalized','position',[0.1 0.76 0.85 0.04],'Style','text','String','Specific parameters','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h64 = uipanel('parent',h6,'units','normalized','position',[0.07 0.05 0.85 0.71],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h641 = uicontrol('parent',h64,'units','normalized','position',[0.07 0.89 0.5 0.05],'Style','text','String','Na term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h642 = uicontrol('parent',h64,'units','normalized','position',[0.55 0.90 0.3 0.047],'Style','edit','String','30','BackgroundColor',[240/255 173/255 105/255]);
    h643 = uicontrol('parent',h64,'units','normalized','position',[0.07 0.81 0.5 0.05],'Style','text','String','Ns term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h644 = uicontrol('parent',h64,'units','normalized','position',[0.55 0.82 0.3 0.047],'Style','edit','String','3','BackgroundColor',[240/255 173/255 105/255]);
    h645 = uicontrol('parent',h64,'units','normalized','position',[0.07 0.73 0.5 0.05],'Style','text','String','Sigma term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h646 = uicontrol('parent',h64,'units','normalized','position',[0.55 0.74 0.3 0.047],'Style','edit','String','3','BackgroundColor',[240/255 173/255 105/255]);
    h647 = uicontrol('parent',h64,'units','normalized','position',[0.07 0.65 0.5 0.05],'Style','text','String','Ng term','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h648 = uicontrol('parent',h64,'units','normalized','position',[0.55 0.66 0.3 0.047],'Style','edit','String','1','BackgroundColor',[240/255 173/255 105/255]);
    ud.handleAlgoShi = [h61;h62;h621;h622;h63;h64;h641;h642;h643;h644;h645;h646;h647;h648];
    
        
    %-- INTERFACE -> PERSONAL ALGO CONTROL
    h71 = uicontrol('parent',h7,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Personal Algorithm','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h72 = uipanel('parent',h7,'units','normalized','position',[0.07 0.75 0.85 0.15],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h73 = uicontrol('parent',h72,'units','normalized','position',[0.07 0.58 0.5 0.23],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h74 = uicontrol('parent',h72,'units','normalized','position',[0.60 0.61 0.3 0.23],'Style','edit','String','200','BackgroundColor',[240/255 173/255 105/255]);
    h75 = uicontrol('parent',h72,'units','normalized','position',[0.07 0.13 0.5 0.23],'Style','text','String','Convergence thres.','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h76 = uicontrol('parent',h72,'units','normalized','position',[0.60 0.16 0.3 0.23],'Style','edit','String','2','BackgroundColor',[240/255 173/255 105/255]);
    h77 = uicontrol('parent',h7,'units','normalized','position',[0.1 0.66 0.85 0.04],'Style','text','String','Specific parameters','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h78 = uipanel('parent',h7,'units','normalized','position',[0.07 0.05 0.85 0.61],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h781 = uicontrol('parent',h78,'units','normalized','position',[0.07 0.89 0.5 0.05],'Style','text','String','Parameter 1','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h782 = uicontrol('parent',h78,'units','normalized','position',[0.55 0.90 0.3 0.047],'Style','edit','String','1','BackgroundColor',[240/255 173/255 105/255]);
    h783 = uicontrol('parent',h78,'units','normalized','position',[0.07 0.81 0.5 0.05],'Style','text','String','Parameter 2','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h784 = uicontrol('parent',h78,'units','normalized','position',[0.55 0.82 0.3 0.047],'Style','edit','String','1','BackgroundColor',[240/255 173/255 105/255]);
    ud.handleAlgoPersonal = [h71;h72;h73;h74;h75;h76;h77;h78;h781;h782;h783;h784]; 
    

    %-- INTERFACE -> COMPARISON CONTROL
    h81 = uicontrol('parent',h8,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Comparison Mode','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h82 = uipanel('parent',h8,'units','normalized','position',[0.07 0.83 0.85 0.07],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h821 = uicontrol('parent',h82,'units','normalized','position',[0.07 0.2 0.5 0.5],'Style','text','String','Number of iterations','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h822 = uicontrol('parent',h82,'units','normalized','position',[0.60 0.25 0.3 0.5],'Style','edit','String','200','callback',{@setAllNbIt},'BackgroundColor',[240/255 173/255 105/255]);
    h83 = uicontrol('parent',h8,'units','normalized','position',[0.1 0.77 0.85 0.03],'Style','text','String','Algorithms','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h84 = uipanel('parent',h8,'units','normalized','position',[0.07 0.52 0.85 0.25],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h841 = uicontrol('parent',h84,'units','normalized','position',[0.07 0.83 0.85 0.12],'Style','checkbox','String','1- Caselles','FontSize',9,'callback',{@SetIconSelected,1},'BackgroundColor',[113/255 113/255 113/255]);
    h842 = uicontrol('parent',h84,'units','normalized','position',[0.07 0.70 0.85 0.12],'Style','checkbox','String','2- Chan & Vese','FontSize',9,'callback',{@SetIconSelected,2},'BackgroundColor',[113/255 113/255 113/255]);
    h843 = uicontrol('parent',h84,'units','normalized','position',[0.07 0.57 0.85 0.12],'Style','checkbox','String','3- Chunming Li','FontSize',9,'callback',{@SetIconSelected,3},'BackgroundColor',[113/255 113/255 113/255]);
    h844 = uicontrol('parent',h84,'units','normalized','position',[0.07 0.44 0.85 0.12],'Style','checkbox','String','4- Lankton','FontSize',9,'callback',{@SetIconSelected,4},'BackgroundColor',[113/255 113/255 113/255]);
    h845 = uicontrol('parent',h84,'units','normalized','position',[0.07 0.31 0.85 0.12],'Style','checkbox','String','5- Bernard','FontSize',9,'callback',{@SetIconSelected,5},'BackgroundColor',[113/255 113/255 113/255]);
    h846 = uicontrol('parent',h84,'units','normalized','position',[0.07 0.18 0.85 0.12],'Style','checkbox','String','6- Shi','FontSize',9,'callback',{@SetIconSelected,6},'BackgroundColor',[113/255 113/255 113/255]);
    h847 = uicontrol('parent',h84,'units','normalized','position',[0.07 0.05 0.85 0.12],'Style','checkbox','String','7- Personal Algorithm','FontSize',9,'callback',{@SetIconSelected,7},'BackgroundColor',[113/255 113/255 113/255]);
    h85 = uicontrol('parent',h8,'units','normalized','position',[0.1  0.46 0.85 0.03],'Style','text','String','Reference','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h86 = uipanel('parent',h8,'units','normalized','position',[0.07 0.34 0.85 0.12],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h861 = uicontrol('parent',h86,'units','normalized','position',[0.15 0.58 0.30 0.31],'Style','pushbutton','String','Load','Backgroundcolor',[240/255 173/255 105/255],'callback','creaseg_loadreference','Enable','off');
    h862 = uicontrol('parent',h86,'units','normalized','position',[0.53 0.58 0.30 0.31],'Style','pushbutton','String','Create','Backgroundcolor',[240/255 173/255 105/255],'callback','creaseg_createreference','Enable','off');
    h863 = uicontrol('parent',h86,'units','normalized','position',[0.07 0.18 0.50 0.25],'Style','text','String','Interpolation Type','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h864 = uicontrol('parent',h86,'units','normalized','position',[0.63 0.20 0.30 0.25],'Style','popupmenu','String',{'Polygon','Spline'},'FontSize',9,'BackgroundColor',[240/255, 173/255, 105/255]);
    h87 = uipanel('parent',h8,'units','normalized','position',[0.07 0.16 0.85 0.12],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h871 = uicontrol('parent',h87,'units','normalized','position',[0.07 0.55 0.40 0.29],'Style','text','String','Similarity Criteria','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[113/255 113/255 113/255]);
    h872 = uicontrol('parent',h87,'units','normalized','position',[0.53 0.58 0.40 0.32],'Style','popupmenu','String',{'Dice','PSNR','Hausdorff','MSSD'},'FontSize',9,'BackgroundColor',[240/255, 173/255, 105/255]);
    h873 = uicontrol('parent',h87,'units','normalized','position',[0.07 0.18 0.85 0.32],'Style','checkbox','String','Intermediate Output','BackgroundColor',[113/255 113/255 113/255],'Value',1);
    h88 = uicontrol('parent',h8,'units','normalized','position',[0.3 0.086 0.40 0.035],'Style','pushbutton','String','See Results','callback',{@manageCompItem,2},'Enable','off','Backgroundcolor',[240/255 173/255 105/255]);
    ud.handleAlgoComparison = [h81;h82;h821;h822;h83;h84;h841;h842;h843;h844;h845;h846;h847;h85;h86;h861;h862;h863;h864;h87;h871;h872;h873;h88]; 
    
    
    %-- INTERFACE -> RESULTS CONTROL
    h91 = uicontrol('parent',h9,'units','normalized','position',[0.0 0.92 1.0 0.05],'Style','text','String','Results','FontSize',10,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    if ud.Version
        h92 = uitable('parent',h9,'units','normalized','position',[0.07 0.62 0.85 0.3],'ColumnName',{'Calculation Time', 'Dice'},'ColumnFormat',{'Bank', 'Bank'},'RowName',{'1','2','3','4','5','6','7'});
    else
        h92 = uicontrol('parent',h9,'units','normalized','position',[0.07 0.62 0.85 0.3],'Style','text','String','Results cannot be displayed here because your Matlab version do not support uitable. Therefore the results are saved in the file results.txt',...
            'FontSize',12,'HorizontalAlignment','center','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 0 0]);
    end
    h93 = uicontrol('parent',h9,'units','normalized','position',[0.1 0.55 0.85 0.03],'Style','text','String','Visual Criteria','FontSize',9,'HorizontalAlignment','left','Backgroundcolor',[87/255 86/255 84/255],'Foregroundcolor',[255/255 255/255 255/255]);
    h94 = uipanel('parent',h9,'units','normalized','position',[0.07 0.25 0.85 0.3],'BorderType','line','Backgroundcolor',[113/255 113/255 113/255],'HighlightColor',[0/255 0/255 0/255]);
    h941 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.87 0.85 0.11],'Style','checkbox','String','Reference (White)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h942 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.75 0.85 0.11],'Style','checkbox','String','1- Caselles (Yellow)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h943 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.63 0.85 0.11],'Style','checkbox','String','2- Chan & Vese (Blue)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h944 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.51 0.85 0.11],'Style','checkbox','String','3- Chunming Li (Cyan)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h945 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.39 0.85 0.11],'Style','checkbox','String','4- Lankton (Red)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h946 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.27 0.85 0.11],'Style','checkbox','String','5- Bernard (Green)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h947 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.15 0.85 0.11],'Style','checkbox','String','6- Shi (Magenta)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h948 = uicontrol('parent',h94,'units','normalized','position',[0.07 0.03 0.85 0.11],'Style','checkbox','String','7- Personal Algorithm (Black)','FontSize',9,'callback',{@creaseg_plotresults},'BackgroundColor',[113/255 113/255 113/255]);
    h95 = uicontrol('parent',h9,'units','normalized','position',[0.3 0.086 0.4 0.035],'Style','pushbutton','String','See Parameters','callback',{@manageCompItem,1},'Backgroundcolor',[240/255 173/255 105/255]);
    ud.handleAlgoResults = [h91;h92;h93;h94;h941;h942;h943;h944;h945;h946;h947;h948;h95]; 
    if ud.Version
        SetTableColumnWidth(ud);
    end
    
    %-- create structure to image handle
    fd = [];
    fd.data = [];
    fd.visu = [];
    fd.tagImage = 0;
    fd.levelset = [];
    fd.visuTmp = [];
    fd.levelsetTmp = [];
    fd.translation = [0 0];
    fd.info = [];
    fd.reference = [];
    fd.points = [];
    fd.pointsRef = [];
    fd.handleRect = {};
    fd.handleElliRect = {};
    fd.handleManual = {};
    fd.handleReference = {};
    fd.method = '';
    fd.drawingManualFlag = 0;
    fd.drawingMultiManualFlag = 0;
    
    %-- Set function to special events
    set(ud.imageId,'userdata',fd);
    set(ud.gcf,'WindowButtonMotionFcn',{@creaseg_mouseMove},'visible','on','HandleVisibility','callback','interruptible','off');
    set(ud.gcf,'CloseRequestFcn',{@closeInterface});   
    
    %-- ATTACH UD STRUCTURE TO FIG HANDLE
    set(ud.gcf,'userdata',ud);
    set(ud.gcf,'ResizeFcn',@figResize);



%---------------------------------------------------------------------
%-- AUXILIARY FUNCTIONS ----------------------------------------------
%---------------------------------------------------------------------
    

%------------------------------------------------------------------    
function manageAlgoItem(src,evt,num)

    fig = gcbf;
    ud = get(fig,'userdata');     
    
    %-- cancel drawing mode
    set(ud.buttonAction(1),'background',[240/255 173/255 105/255]);    
    for k=3:size(ud.handleInit,1)
        set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
    end
    
    %-- check whether the create button of comparison mode is unselect
    if ( get(ud.handleAlgoComparison(17),'BackgroundColor')~=[160/255 130/255 95/255] )    
        set(ud.gcf,'WindowButtonDownFcn','');
        set(ud.gcf,'WindowButtonUpFcn','');
        %-- put pointer button to select
        set(ud.buttonAction(3),'BackgroundColor',[160/255 130/255 95/255]);
    end    
    %-- put run button to unselect    
    set(ud.buttonAction(2),'BackgroundColor',[240/255 173/255 105/255]);
    
    %--
    if strcmp(get(ud.handleIconAlgo(8),'State'),'off')||(get(ud.handleAlgoComparison(6+num),'Value')==0)
        
        if strcmp(get(ud.handleIconAlgo(8),'State'),'on')
           EnableDisableNbit(ud,'on');
        end
        
        for k=1:size(ud.handleAlgoConfig,1)
            set(ud.handleAlgoConfig(k),'Visible','off');
            if k<size(ud.handleAlgoConfig,1)-1
                set(ud.handleIconAlgo(k),'State','off');
            end
        end
        set(ud.handleAlgoConfig(num),'Visible','on');
        set(ud.handleIconAlgo(num),'State','on');
        %--
        setAllIcon(ud);
        %--
        for k=1:size(ud.handleMenuAlgorithms,1)
            set(ud.handleMenuAlgorithms(k),'label',ud.handleMenuAlgorithmsName{k},'ForegroundColor',[0/255, 0/255, 0/255],'Checked','off');
        end
        set(ud.handleMenuAlgorithms(num),'label',ud.handleMenuAlgorithmsName{num},'ForegroundColor',[255/255, 0/255, 0/255],'Checked','on');
        
    else
        
        for k=1:size(ud.handleAlgoConfig,1)
            set(ud.handleAlgoConfig(k),'Visible','off');
            if k<size(ud.handleAlgoConfig,1)-1
                set(ud.handleIconAlgo(k),'State','off');
            end
        end
        set(ud.handleAlgoConfig(num),'Visible','on');
        set(ud.handleIconAlgo(8),'State','on');
        
    end
    
    
%--    
function manageCompItem(src, evt, num)
    
    fig = gcbf;
    ud = get(fig,'userdata');    
    EnableDisableNbit(ud,'off');
    
    %-- cancel drawing mode
    set(ud.buttonAction(1),'background',[240/255 173/255 105/255]);    
    for k=3:size(ud.handleInit,1)
        set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
    end
    
    %-- check whether the create button of comparison mode is unselect
    if ( get(ud.handleAlgoComparison(17),'BackgroundColor')~=[160/255 130/255 95/255] )    
        set(ud.gcf,'WindowButtonDownFcn','');
        set(ud.gcf,'WindowButtonUpFcn','');
        %-- put pointer button to select
        set(ud.buttonAction(3),'BackgroundColor',[160/255 130/255 95/255]);
    end    
    %-- put run button to unselect    
    set(ud.buttonAction(2),'BackgroundColor',[240/255 173/255 105/255]); 
    
    %--
    for k=1:size(ud.handleAlgoConfig,1)
        set(ud.handleAlgoConfig(k),'Visible','off');
        if k<size(ud.handleAlgoConfig,1)-1
            set(ud.handleIconAlgo(k),'State','off');
        end
    end
    if num == 1
        set(ud.handleAlgoConfig(8),'Visible','on');
        set(ud.handleIconAlgo(8),'State','on');
    else
        set(ud.handleAlgoConfig(9),'Visible','on');
        set(ud.handleIconAlgo(8),'State','on')
        creaseg_plotresults(src,evt);
    end
    
    for k=1:size(ud.handleMenuAlgorithms,1)-1
        set(ud.handleMenuAlgorithms(k),'label',ud.handleMenuAlgorithmsName{k},'ForegroundColor',[0/255, 0/255, 0/255],'Checked','off');
    end
    set(ud.handleMenuAlgorithms(8),'label',ud.handleMenuAlgorithmsName{8},'ForegroundColor',[255/255, 0/255, 0/255],'Checked','on');

    setAllIcon(ud);
    setAllNbIt(src,evt);

    
%--
function manageInit(src,evt)
    
    fig = gcbf;
    ud = get(fig,'userdata');

    for k=1:size(ud.handleAlgoConfig,1)
        set(ud.handleAlgoConfig(k),'Visible','off');
    end
    set(ud.handleAlgoConfig(end),'Visible','on');
     
    
%--    
function closeInterface(src,evt)    
    
    delete(gcbf);
        
%--
function figResize(src,evt)

    fig = gcbf;
    ud = get(fig,'userdata');
    SetTextIntensityPosition(ud);
    if ud.Version
        SetTableColumnWidth(ud);
    end    
   
    
%--
function SetTableColumnWidth(ud)
 
    ss = get(ud.gcf,'position');
    posPanel = get(ud.handleAlgoConfig(9),'position');
    posTable = get(ud.handleAlgoResults(2),'position');
    w = ss(3)*posPanel(3)*posTable(3)-35;
    set(ud.handleAlgoResults(2),'ColumnWidth',{w/2,w/2});
       
    
%--    
function SetTextIntensityPosition(ud)
    
    ss = get(ud.gcf,'position');
    pos = get(ud.panelText,'position');
    w = ss(3)*pos(3);
    h = ss(4)*pos(4);    
    a = w/5;
    c = w-2*a;
    b = 3*h/8;
    d = h-2*b;
    set(ud.txtPositionIntensity,'units','pixels','position',[a b c d]);

    
%-- save images
function saveResult(src,evt,num)    

    fig = gcbf;
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');
        
    img = fd.visu;
    method = fd.method;
    cl = ud.colorSpec(get(ud.handleContourColor,'userdata'));
    S = method;
            
    switch method
        case 'Reference'
            levelset = fd.reference;
        case 'Comparison'
            if num == 1
                num = 2;
            end
            levelset = zeros(size(img,1),size(img,2),8);
            levelset(:,:,1) = fd.reference;
            levelset(:,:,2:end) = fd.seg;
            cl = {'w','y','b','c','r','g','m','k'};
            S = ['Reference  ';'Caselles   ';'Chan & Vese';'Chunming Li'; ...
                 'Lankton    ';'Bernard    ';'Shi        ';'Personal   '];
        otherwise
            levelset = fd.levelset;
    end
    method = S;
    
    switch num
        
        case 1  %-- save screen (one contour)
            
            if ( ~isempty(img) )
                img = img - min(img(:));
                img = uint8(255*img/max(img(:)));
                imgrgb = repmat(img,[1 1 3]);
                if ( (~isempty(levelset)) && (size(img,1)==size(levelset,1)) && (size(img,2)==size(levelset,2)))
                    axes(get(ud.imageId,'parent'));
                    delete(findobj(get(ud.imageId,'parent'),'type','line'));                    
                    hold on; [c,h] = contour(levelset,[0 0],cl{1},'Linewidth',3); hold off;
                    delete(h);
                    tt = round(c);
                    %--
                    test = isequal(size(c,2),0);
                    while (test==false)
                        s = c(2,1);
                        if ( s == (size(c,2)-1) )
                            t = c;
                            hold on; plot(t(1,2:end)',t(2,2:end)',cl{1},'Linewidth',3);
                            test = true;
                        else
                            t = c(:,2:s+1);
                            hold on; plot(t(1,1:end)',t(2,1:end)',cl{1},'Linewidth',3);
                            c = c(:,s+2:end);
                        end
                    end
                    %--
                    tt = tt(:, (tt(1,:)~=0) & (tt(1,:)>=1) & (tt(1,:)<=size(img,2)) ...
                         & (tt(2,:)>=1) & (tt(2,:)<=size(img,1)));
                    imgContour = repmat(0,size(img));
                    for k=1:size(tt,2)
                        imgContour(tt(2,k),tt(1,k),1) = 1;                        
                    end
                    if ( min(size(img)) <= 225 )
                        se = strel('arbitrary',[1 1; 1 1]);
                    elseif ( min(size(img)) <= 450 )
                        se = strel('disk',1);
                    elseif ( min(size(img)) <= 775 )
                        se = strel('disk',2);
                    else
                        se = strel('disk',3);
                    end
                    imgContour = imdilate(imgContour,se);
                    [y,x] = find(imgContour~=0);                    
                    switch cl{1}
                        case 'r'
                            val = [255,0,0];
                        case 'g'
                            val = [0,255,0];
                        case 'b'
                            val = [0,0,255];
                        case 'y'
                            val = [255,255,0];
                        case 'w'
                            val = [255,255,255];
                        case 'k'
                            val = [0,0,0];
                    end
                    for k=1:size(x,1)
                        imgrgb(y(k),x(k),1) = val(1);
                        imgrgb(y(k),x(k),2) = val(2);
                        imgrgb(y(k),x(k),3) = val(3);
                    end
                    set(ud.imageId,'userdata',fd);
                    set(fig,'userdata',ud);
                end
                [filename, pathname] = uiputfile({'*.png','Png (*.png)';...
                    '*.bmp','Bmp (*.bmp)';'*.tif','Tif (*.tif)';...
                    '*.gif','Gif (*.gif)';'*.jpg','Jpg (*.jpg)'},'Save as');
                if ( ~isempty(pathname) && ~isempty(filename) )
                    imwrite(imgrgb,[pathname filename]);
                end
            end

        case 2  %-- save screen (Multiple contours)
            
            if ( ~isempty(img) )
                img = img - min(img(:));
                img = uint8(255*img/max(img(:)));
                imgrgb = repmat(img,[1 1 3]);
                if ( (~isempty(levelset)) && (size(img,1)==size(levelset,1)) && (size(img,2)==size(levelset,2)))
                    for i = 1:1:size(levelset,3)
                        if (max(max(levelset(:,:,i)))~=0) && (get(ud.handleAlgoResults(4+i),'Value'))
                            axes(get(ud.imageId,'parent'));
                            hold on; [c,h] = contour(levelset(:,:,i),[0 0],cl{i},'Linewidth',3); hold off;
                            delete(h);
                            tt = round(c);
                            %--
                            test = isequal(size(c,2),0);
                            while (test==false)
                                s = c(2,1);
                                if ( s == (size(c,2)-1) )
                                    t = c;
                                    hold on; plot(t(1,2:end)',t(2,2:end)',cl{i},'Linewidth',3);
                                    test = true;
                                else
                                    t = c(:,2:s+1);
                                    hold on; plot(t(1,1:end)',t(2,1:end)',cl{i},'Linewidth',3);
                                    c = c(:,s+2:end);
                                end
                            end
                            %--
                            tt = tt(:, (tt(1,:)~=0) & (tt(1,:)>=1) & (tt(1,:)<=size(img,2)) ...
                                 & (tt(2,:)>=1) & (tt(2,:)<=size(img,1)));
                            imgContour = repmat(0,size(img));
                            for k=1:size(tt,2)
                                imgContour(tt(2,k),tt(1,k),1) = 1;                        
                            end
                            if ( min(size(img)) <= 225 )
                                se = strel('arbitrary',[1 1; 1 1]);
                            elseif ( min(size(img)) <= 450 )
                                se = strel('disk',1);
                            elseif ( min(size(img)) <= 775 )
                                se = strel('disk',2);
                            else
                                se = strel('disk',3);
                            end
                            imgContour = imdilate(imgContour,se);
                            [y,x] = find(imgContour~=0);                    
                            switch cl{i}
                                case 'r'
                                    val = [255,0,0];
                                case 'g'
                                    val = [0,255,0];
                                case 'b'
                                    val = [0,0,255];
                                case 'y'
                                    val = [255,255,0];
                                case 'w'
                                    val = [255,255,255];
                                case 'k'
                                    val = [0,0,0];
                                case 'm'
                                    val = [255,0,255];
                                case 'c'
                                    val = [0,255,255];
                            end
                            for k=1:size(x,1)
                                imgrgb(y(k),x(k),1) = val(1);
                                imgrgb(y(k),x(k),2) = val(2);
                                imgrgb(y(k),x(k),3) = val(3);
                            end
                            set(ud.imageId,'userdata',fd);
                            set(fig,'userdata',ud);
                        end
                    end
                end
                [filename, pathname] = uiputfile({'*.png','Png (*.png)';...
                    '*.bmp','Bmp (*.bmp)';'*.tif','Tif (*.tif)';...
                    '*.gif','Gif (*.gif)';'*.jpg','Jpg (*.jpg)'},'Save as');
                if ( ~isempty(pathname) && ~isempty(filename) )
                    imwrite(imgrgb,[pathname filename]);
                end
            end
        
        case 3  %-- save data
            
            if ( ~isempty(img) )
                if ( (~isempty(levelset)) )
                    result = struct('img',img,'levelset',levelset, 'Method', method);
                else
                    result = img;
                end                
                [filename, pathname] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save as'); 
                if ( ~isempty(pathname) && ~isempty(filename) )
                    save([pathname filename],'result');
                end
            end
            
    end
    
 
%-- change color of contour display on the image
function changeContourColor(src,evt)
    
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata');

    pos = get(src,'userdata');
    if (pos==6)
        pos = 1;
    else
        pos = pos+1;
    end
    filename = {'brushR' 'brushG' 'brushB' 'brushY' 'brushW' 'brushK'};
    load(['misc/icons/' filename{pos} '.mat']);
    set(src,'cdata',cdata,'userdata',pos);
    
    %--
    if ( ~isempty(fd.data) )
        switch ud.LastPlot
            case 'levelset'
                if ( (~isempty(fd.levelset)) && (size(fd.data,1)==size(fd.levelset,1)) ...
                        && (size(fd.data,2)==size(fd.levelset,2)))

                    cl = ud.colorSpec(pos);                    
                    if ( size(fd.handleRect,2) > 0 )
                        for k=size(fd.handleRect,2):-1:1
                            set(fd.handleRect{k},'EdgeColor',cl{1});
                        end
                    elseif ( size(fd.handleElliRect,2) > 0 )
                        for k=size(fd.handleElliRect,2):-1:1
                            set(fd.handleElliRect{k}(2),'color',cl{1});
                        end
                    elseif ( size(fd.handleManual,2) > 0 )    
                        for k=size(fd.handleManual,2):-1:1
                            if ( (size(fd.handleManual{k},1)==1) && (fd.handleManual{k}>0) )
                                set(fd.handleManual{k},'color',cl{1});                              
                            end
                        end        
                    else
                        axes(get(ud.imageId,'parent'));
                        delete(findobj(get(ud.imageId,'parent'),'type','line'));
                        hold on; [c,h] = contour(fd.levelset,[0 0],cl{1},'Linewidth',3); hold off;
                        delete(h);
                        test = isequal(size(c,2),0);
                        while (test==false)
                            s = c(2,1);
                            if ( s == (size(c,2)-1) )
                                t = c;
                                hold on; plot(t(1,2:end)',t(2,2:end)',cl{1},'Linewidth',3);
                                test = true;
                            else
                                t = c(:,2:s+1);
                                hold on; plot(t(1,1:end)',t(2,1:end)',cl{1},'Linewidth',3);
                                c = c(:,s+2:end);
                            end
                        end                        
                    end
                end    
                
            case 'reference'
                if ( (~isempty(fd.reference)) && (size(fd.data,1)==size(fd.reference,1)) ...
                        && (size(fd.data,2)==size(fd.reference,2)))

                    cl = ud.colorSpec(pos);    
                    axes(get(ud.imageId,'parent'));
                    delete(findobj(get(ud.imageId,'parent'),'type','line'));
                    hold on; [c,h] = contour(fd.reference,[0 0],cl{1},'Linewidth',3); hold off;
                    delete(h);
                    test = isequal(size(c,2),0);
                    while (test==false)
                        s = c(2,1);
                        if ( s == (size(c,2)-1) )
                            t = c;
                            hold on; plot(t(1,2:end)',t(2,2:end)',cl{1},'Linewidth',3);
                            test = true;
                        else
                            t = c(:,2:s+1);
                            hold on; plot(t(1,1:end)',t(2,1:end)',cl{1},'Linewidth',3);
                            c = c(:,s+2:end);
                        end
                    end    
                end 
        end
                
    end
    
   
%--
function SetIconSelected(src,evt,num)

    fig = gcbf;
    ud = get(fig,'userdata');

    if get(ud.handleAlgoComparison(6+num),'Value')
        set(ud.handleIconAlgo(num),'cdata',ud.AlgoIconSel(:,:,:,num))        
        set(ud.handleMenuAlgorithms(num),'label',ud.handleMenuAlgorithmsName{num},'ForegroundColor',[0/255, 153/255, 51/255],'Checked','on');
    else
        set(ud.handleIconAlgo(num),'cdata',ud.AlgoIcon(:,:,:,num)) 
        set(ud.handleMenuAlgorithms(num),'label',ud.handleMenuAlgorithmsName{num},'ForegroundColor',[0/255, 0/255, 0/255],'Checked','off');
    end
   
    
%--    
function setAllIcon(ud)
  
    for i=1:1:7
        if (get(ud.handleAlgoComparison(6+i),'Value')) && strcmp(get(ud.handleIconAlgo(8),'State'),'on')
            set(ud.handleIconAlgo(i),'cdata',ud.AlgoIconSel(:,:,:,i));
            set(ud.handleMenuAlgorithms(i),'label',ud.handleMenuAlgorithmsName{i},'ForegroundColor',[0/255, 153/255, 51/255],'Checked','on');
        else
            set(ud.handleIconAlgo(i),'cdata',ud.AlgoIcon(:,:,:,i));
            set(ud.handleMenuAlgorithms(i),'label',ud.handleMenuAlgorithmsName{i},'ForegroundColor',[0/255, 0/255, 0/255],'Checked','off');
        end
    end
              
    
%--    
function EnableDisableNbit(ud,s)

	set(ud.handleAlgoCaselles(4),'Enable',s);
	set(ud.handleAlgoChanVese(4),'Enable',s);
	set(ud.handleAlgoLi(4),'Enable',s);
	set(ud.handleAlgoLankton(4),'Enable',s);
	set(ud.handleAlgoBernard(4),'Enable',s);
	set(ud.handleAlgoShi(4),'Enable',s);
	set(ud.handleAlgoPersonal(4),'Enable',s);
   
    
%--    
function setAllNbIt(src,evt)

    fig = gcbf;
    ud = get(fig,'userdata');

    NbIt = get(ud.handleAlgoComparison(4),'String');
    
    set(ud.handleAlgoCaselles(4),'String',NbIt);    
    set(ud.handleAlgoChanVese(4),'String',NbIt);    
    set(ud.handleAlgoLi(4),'String',NbIt);    
    set(ud.handleAlgoLankton(4),'String',NbIt);    
    set(ud.handleAlgoBernard(4),'String',NbIt);    
    set(ud.handleAlgoShi(4),'String',NbIt);    
    set(ud.handleAlgoPersonal(4),'String',NbIt);
    
    
%--    
function creaseg_inittype(src, evt)

    fig = gcbf;
    ud = get(fig,'userdata');
    
    switch get(ud.handleInit(4),'Value')
        case {1,2}
            InitText_OnOff(ud,0);
        
        case 3
            InitText_OnOff(ud,1);
            set(ud.handleInit(5),'String','Center');
            set(ud.handleInit(7),'String','Xc');
            set(ud.handleInit(9),'String','Yc');

            set(ud.handleInit(13),'String','X Axis');
            set(ud.handleInit(15),'String','Y Axis');
            
            init_param(ud,get(ud.handleInit(4),'Value'));
            
        case 4
            InitText_OnOff(ud,1);
            set(ud.handleInit(5),'String','Center');
            set(ud.handleInit(7),'String','Xc');
            set(ud.handleInit(9),'String','Yc');

            set(ud.handleInit(13),'String','Length');
            set(ud.handleInit(15),'String','Width');
        
            init_param(ud,get(ud.handleInit(4),'Value'));
            
        case 5
            InitText_OnOff(ud,1);
            set(ud.handleInit(5),'String','Space');
            set(ud.handleInit(7),'String','X');
            set(ud.handleInit(9),'String','Y');

            set(ud.handleInit(13),'String','Radius');
            set(ud.handleInit(15),'Enable','Off');
            set(ud.handleInit(16),'Enable','Off');
        
            init_param(ud,get(ud.handleInit(4),'Value'));
            
        case 6
            InitText_OnOff(ud,1);
            set(ud.handleInit(5),'String','Space');
            set(ud.handleInit(7),'String','X');
            set(ud.handleInit(9),'String','Y');

            set(ud.handleInit(13),'String','Length');
            set(ud.handleInit(15),'String','Width');
            
            init_param(ud,get(ud.handleInit(4),'Value'));
    end
    
    
%--
function InitText_OnOff(ud,type)
    if type
        set(ud.handleInit(7),'Enable','On');
        set(ud.handleInit(8),'Enable','On');
        set(ud.handleInit(9),'Enable','On');
        set(ud.handleInit(10),'Enable','On');

        set(ud.handleInit(13),'Enable','On');
        set(ud.handleInit(14),'Enable','On');
        set(ud.handleInit(15),'Enable','On');
        set(ud.handleInit(16),'Enable','On');
    else
        set(ud.handleInit(7),'Enable','Off');
        set(ud.handleInit(8),'Enable','Off');
        set(ud.handleInit(9),'Enable','Off');
        set(ud.handleInit(10),'Enable','Off');

        set(ud.handleInit(13),'Enable','Off');
        set(ud.handleInit(14),'Enable','Off');
        set(ud.handleInit(15),'Enable','Off');
        set(ud.handleInit(16),'Enable','Off');
    end

    
%--    
function init_param(ud, method)
    fd = get(ud.imageId,'userdata');

    if ( isempty(fd.data) )
        return;
    end
    
    switch method
        case {3, 4}
            set(ud.handleInit(8),'string',num2str(size(fd.data,2)/2));
            set(ud.handleInit(10),'string',num2str(size(fd.data,1)/2));
            set(ud.handleInit(14),'string',num2str(size(fd.data,2)/4));
            set(ud.handleInit(16),'string',num2str(size(fd.data,1)/4));
        case {5, 6}
            set(ud.handleInit(8),'string',num2str(size(fd.data,2)/40));
            set(ud.handleInit(10),'string',num2str(size(fd.data,1)/40));
            set(ud.handleInit(14),'string',num2str(size(fd.data,2)/20));
            set(ud.handleInit(16),'string',num2str(size(fd.data,1)/20));
    end

    
%--            
function open_author(src,evt)
	web('http://www.creatis.insa-lyon.fr/~bernard');
    
    
%--    
function open_help(src,evt)
	web('http://www.creatis.insa-lyon.fr/~bernard/creaseg');

        
%--
function manageAction(src,evt,nbBut)

    %-- parameters
    fig = findobj(0,'tag','creaseg');
    ud = get(fig,'userdata');
    fd = get(ud.imageId,'userdata'); 

    %-- deal with pan option
    if ( (nbBut==2) || (nbBut==3) )
        pan off;
    end
    
    %-- clean up all messages
    if ( nbBut<7)
        set(ud.txtInfo1,'string','');
        set(ud.txtInfo2,'string','');
        set(ud.txtInfo3,'string','');
        set(ud.txtInfo4,'string','');
        set(ud.txtInfo5,'string','');        
    end
    
    if (nbBut==6)
        if (get(ud.buttonAction(6),'background')==[160/255 130/255 95/255])
            set(ud.buttonAction(6),'background',[240/255 173/255 105/255]);
        else
            set(ud.buttonAction(6),'background',[160/255 130/255 95/255]);
        end
    end       
    
    if (nbBut==7)
        if (get(ud.buttonAction(7),'background')==[160/255 130/255 95/255])
            set(ud.buttonAction(7),'background',[240/255 173/255 105/255]);
            set(ud.txtInfo1,'string','');
            set(ud.txtInfo2,'string','');
            set(ud.txtInfo3,'string','');
            set(ud.txtInfo4,'string','');
            set(ud.txtInfo5,'string','');
        else
            set(ud.buttonAction(7),'background',[160/255 130/255 95/255]);
        end
    end    


    %-- ACTION
    if ( (fd.tagImage == 1 ) || (nbBut == 1) )
        switch nbBut
            case 1 %-- Draw initial region
                set(ud.buttonAction(2),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(3),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(7),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(1),'BackgroundColor',[160/255 130/255 95/255]);  
                %-- switch off create button of comparison mode
                set(ud.handleAlgoComparison(17),'BackgroundColor',[240/255 173/255 105/255]); 
                %-- do corresponding action
                manageInit(src,evt);
            case 2  %-- Run method
                set(ud.buttonAction(1),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(2),'BackgroundColor',[160/255 130/255 95/255]);     
                set(ud.buttonAction(6),'BackgroundColor',[240/255 173/255 105/255]);                    
                set(ud.buttonAction(7),'BackgroundColor',[240/255 173/255 105/255]);                
                %-- switch off create button of comparison mode
                set(ud.handleAlgoComparison(17),'BackgroundColor',[240/255 173/255 105/255]);     
                %-- do corresponding action
                creaseg_run(src,evt); 
            case 3  %-- Set mouse pointer to own (disable current figure option icon properties)
                set(ud.buttonAction(2),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(6),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(7),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(3),'BackgroundColor',[160/255 130/255 95/255]);
                %-- put drawing to unclick
                for k=3:size(ud.handleInit,1)
                    set(ud.handleInit(k),'BackgroundColor',[240/255 173/255 105/255]);
                end
                %-- do corresponding action
                set(ud.gcf,'WindowButtonDownFcn','');
                set(ud.gcf,'WindowButtonUpFcn','');                 
            case 4  %-- Zoom in by a factor of 2
                set(ud.buttonAction(2),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(5),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(7),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(4),'BackgroundColor',[160/255 130/255 95/255]);
                %-- do corresponding action
                axes(get(ud.imageId,'parent'));
                zoom(ud.gca,2);
            case 5  %-- Zoom out by a factor of 2
                set(ud.buttonAction(2),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(4),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(7),'BackgroundColor',[240/255 173/255 105/255]);
                set(ud.buttonAction(5),'BackgroundColor',[160/255 130/255 95/255]); 
                %-- do corresponding action
                axes(get(ud.imageId,'parent'));
                zoom(ud.gca,0.5);
            case 6  %-- Pan into main figure
                %--
                set(ud.buttonAction(7),'BackgroundColor',[240/255 173/255 105/255]);
                %-- 
                if (get(ud.buttonAction(6),'background')==[240/255 173/255 105/255])
                    %-- first pan off
                    pan off;
                    if ( get(ud.buttonAction(1),'background')==[240/255 173/255 105/255] )
                        if ( get(ud.handleAlgoComparison(17),'background')==[240/255 173/255 105/255] )
                            %-- then put pointer button to selected
                            set(ud.buttonAction(3),'BackgroundColor',[160/255 130/255 95/255]);
                        end
                    end
                    %-- then go back to manual drawing mode if any
                    if ( fd.drawingManualFlag == 1 )
                        set(ud.gcf,'WindowButtonDownFcn',{@creaseg_drawManualContour});
                        set(ud.gcf,'WindowButtonUpFcn','');
                    end
                    %-- then go back to multi manual drawing mode if any
                    if ( fd.drawingMultiManualFlag == 1 )
                        set(ud.gcf,'WindowButtonDownFcn',{@creaseg_drawMultiManualContours});
                        set(ud.gcf,'WindowButtonUpFcn','');
                    end
                    %-- then go back to reference manual drawing mode if any
                    if ( fd.drawingReferenceFlag == 1 )
                        set(ud.gcf,'WindowButtonDownFcn',{@creaseg_drawMultiReferenceContours});
                        set(ud.gcf,'WindowButtonUpFcn','');
                    end                    
                    
                else
                    %-- put pointer button to unselected
                    set(ud.buttonAction(3),'BackgroundColor',[240/255 173/255 105/255]);                    
                    %-- do corresponding action
                    set(ud.gcf,'WindowButtonDownFcn','');
                    set(ud.gcf,'WindowButtonUpFcn','');                
                    axes(get(ud.imageId,'parent'));
                    pan(ud.gca);
                end
            case 7  %-- Display or not current image properties
                if (get(ud.buttonAction(7),'background')==[160/255 130/255 95/255])
                    fd = get(ud.imageId,'userdata');
                    if (  ~isempty(fd.info) )
                        if ( isfield(fd.info,'Width') )
                            set(ud.txtInfo1,'string',sprintf('width:%d pixels',fd.info.Width),'color',[1 1 0]);
                        end
                        if ( isfield(fd.info,'Height') )
                            set(ud.txtInfo2,'string',sprintf('height:%d pixels',fd.info.Height),'color',[1 1 0]);
                        end
                        if ( isfield(fd.info,'BitDepth') )
                            set(ud.txtInfo3,'string',sprintf('bit depth:%d',fd.info.BitDepth),'color',[1 1 0]);
                        end
                        if ( isfield(fd.info,'XResolution') && (~isempty(fd.info.XResolution)) )
                            if ( isfield(fd.info,'ResolutionUnit') )
                                if ( strcmp(fd.info.ResolutionUnit,'meter') )
                                    set(ud.txtInfo4,'string',sprintf('XResolution:%0.3f mm',fd.info.XResolution/1000),'color',[1 1 0]);
                                elseif ( strcmp(fd.info.ResolutionUnit,'millimeter') )
                                    set(ud.txtInfo4,'string',sprintf('XResolution:%0.3f mm',fd.info.XResolution),'color',[1 1 0]);
                                else
                                    set(ud.txtInfo4,'string',sprintf('XResolution:%0.3f',fd.info.XResolution),'color',[1 1 0]);
                                end
                            else
                                set(ud.txtInfo4,'string',sprintf('XResolution:%f',fd.info.XResolution),'color',[1 1 0]);
                            end
                        end
                        if ( isfield(fd.info,'YResolution') && (~isempty(fd.info.YResolution)) )
                            if ( isfield(fd.info,'ResolutionUnit') )
                                if ( strcmp(fd.info.ResolutionUnit,'meter') )
                                   set(ud.txtInfo5,'string',sprintf('YResolution:%0.3f mm',fd.info.YResolution/1000),'color',[1 1 0]); 
                                elseif ( strcmp(fd.info.ResolutionUnit,'millimeter') )
                                    set(ud.txtInfo5,'string',sprintf('YResolution:%0.3f mm',fd.info.YResolution),'color',[1 1 0]);
                                else
                                    set(ud.txtInfo5,'string',sprintf('YResolution:%0.3f',fd.info.YResolution),'color',[1 1 0]);
                                end
                            else
                                set(ud.txtInfo5,'string',sprintf('YResolution:%f',fd.info.XResolution),'color',[1 1 0]);
                            end
                        end                
                    end
                end
        end                
    end 

    

    
    

        
