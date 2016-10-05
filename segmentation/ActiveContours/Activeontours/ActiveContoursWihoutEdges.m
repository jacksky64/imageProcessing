function ActiveContoursWihoutEdges(hObject,mask)
%This function implements the paper "Active Contours without Edges" by 
%Tony Chan and Luminita Vese. It also present results accourding to user
%wish (from  ActiveCountorsGUI). Coding- Nikolay S. & Alex B.
%Input argument- a Handle to an object of ActiveCountorsGUI

handles=guidata(hObject);
%% get Alg parametrs from GUI
N=get(handles.NAlgEdit,'Value'); % number of iterations
Lambda_1=get(handles.Lambda1AlgEdit,'Value');
Lambda_2=get(handles.Lambda2AlgEdit,'Value');
miu=get(handles.MiuAlgEdit,'Value'); % varies from 255*1e-1 to 255*1e-4
v=get(handles.NuAlgEdit,'Value');
delta_t=get(handles.DeltaTAlgEdit,'Value');
HTflag=get(handles.HTBasedAlg,'Value');

%% Get visual/plotting parameters
FigRefresRate=get(handles.RefreshRateEdit,'Value');
SaveRefresRate=get(handles.SaveRateEdit,'Value');
SegDispaly=get(handles.SegmentOn,'Value');
EnergyDispaly=get(handles.EnergyOn,'Value');
EnergyImageType=get(handles.EnergyPlotTypeMenu,'Value');
no_of_plots=SegDispaly+EnergyDispaly;
uipael_handle=handles.Axis_uipanel;

if no_of_plots==1
    %set(handles.GUIfig,'CurrentAxes',handles.Axes)
    subplot(no_of_plots,1,1,'Units','Normalized','Parent',uipael_handle)
end

%% get I/O parameters
out_dir=handles.OutDirPath;
% get file name from path
file_str=handles.ImageFileAddr;
% [pathstr, name, ext, versn] = fileparts(filename)
[~, in_file_name, ~] = fileparts(file_str);

text_line_length=60;     

%% divide name too long to cell array to allow  compact presentation in text command
length_file_str=length(file_str);
cell_array_length=ceil(length_file_str/text_line_length);
file_str4text=cell(1,cell_array_length);
for ind=1:cell_array_length-1 
    file_str4text{ind}=[file_str((1+(ind-1)*text_line_length):...
        ind*text_line_length),'...'];
end
file_str4text{ind+1}=file_str((1+ind*text_line_length):end);

%% load image
img=handles.ImageData;
[img_x,img_y]=size(img);

%% Init Phi
phi=bwdist(1-mask)-bwdist(mask);
% phi=phi.^3;
phi=phi/(max(max(phi))-min(min(phi))); %normilize to amplitude=1
% K=zeros(img_x,img_y); %init K matrix
if ~strcmpi(class(phi),'double')
    phi=double(phi);
end

%define HT
if (HTflag)
    % x=-i*sign(linspace(0,1,150)-.5);
    N_U=10;N_V=10;
    [U,V]=meshgrid(linspace(-fix(N_U/2),fix(N_U/2),N_U),linspace(-fix(N_V/2),fix(N_V/2),N_U));
    H_UV_HT=sign(U).*sign(V);
    h_ht=fftshift(ifft(H_UV_HT));
end


for n=1:N % main loop
    %% Active contours iterations
    c_1=sum(img(phi>=0))/max(1,length(img(phi>0)));   % prevent division by zero
    c_2=sum(img(phi<0))/max(1,length(img(phi<0)));    % prevent division by zero

    if (HTflag)
        dx=filter2(h_ht,phi,'same');
        dy=dx.';
    else
        [dx,dy]=gradient(phi);
    end
    
    grad_norm=max(eps,sqrt(dx.^2+dy.^2));%we want to prevent division by zero
    %     [dxx,dxy]=gradient(dx);
    %     [dyx,dyy]=gradient(dy);
    %    K=(dxx.*dy.^2-2*dx.*dy.*dxy+dyy.*dx.^2)./(grad_norm).^3; % another way   to define div(grad/|grad|)
    K=divergence(dx./grad_norm,dy./grad_norm); %this one is a bit faster
   
    speed = Delta_eps(phi).*(miu*K-v-Lambda_1*(img-c_1).^2+Lambda_2*(img-c_2).^2);
    speed =speed/ sqrt(sum(sum(speed.^2)));%norm by square root of sum of square elements
    
    phi=phi+delta_t*speed;
    
    %% Presenting relevant graphs 
    if (~mod(n,FigRefresRate))   % it's time to draw current image
        
        pause(0.001);

        if (SegDispaly)
            if (EnergyDispaly) % two axis on display
                subplot(no_of_plots,1,1,'Units','Normalized',...
                    'Parent',uipael_handle);
            end
%             imshow(uint8(repmat(img,[1,1,3])));hold on;
            strechedImg=img-min(img(:)); % now values are between 0:Max
            strechedImg=255*strechedImg/max(strechedImg(:)); % now values between 0:255
            imshow(repmat(uint8(strechedImg),[1,1,3]),[]); hold on;
            contour(sign(phi),[0 0],'g','LineWidth',2);
            iterNum=['Segmentation with: Active Contours wihtout Edges, ',num2str(n),' iterations'];        
            title(iterNum,'FontSize',14);
            axis off;axis equal;hold off;
        end
        
        if (EnergyDispaly) 
            if (SegDispaly) % two axis on display
                subplot(no_of_plots,1,2,'Units','Normalized',...
                    'Parent',uipael_handle)
            end
            
            switch(EnergyImageType)
                case(1) %surf(phi)
                    surf(phi);
                case(2) %mesh(phi)
                    mesh(phi);
                case(3) %imagesc(phi)
                    imagesc(phi);
                    axis equal;
                    axis off;
                case(4) %surf(sign|phi|)
                    surf(sign(phi));
                case(5) %mesh(sign|phi|)
                    mesh(sign(phi));
                case(6) %imagesc(sign|phi|);
                    imagesc(sign(phi));
                    axis equal;axis off;
            end
            
            colormap('Jet');
            title(['\phi_{',num2str(n),'}'],'FontSize',18);
        end  
        
        if (SegDispaly)&&(EnergyDispaly) 
            text_pos=[0.5,1.35];
        else
            text_pos=[0.5,-0.02];
        end
        text(text_pos(1),text_pos(2),{'Applied to file:',file_str4text{:}},...
            'HorizontalAlignment','center','Units','Normalized',...
            'FontUnits','Normalized');
        drawnow; 
        
        %% it's time to save current image
        if (~mod(n,SaveRefresRate))        
            tmp=zeros(size(img,1),size(img,2));
            tmp(phi>0)=255;
            temp_img=repmat(img(:,:,1),[1 1 3]);
            temp_img(:,:,2)=temp_img(:,:,2)+tmp;
            imwrite(uint8(temp_img),[out_dir,filesep,in_file_name,'Segment_n_',num2str(n),'.jpg'],'jpg');
            max_phi=max(max(phi));min_phi=min(min(phi));
            tmp=phi; tmp=255*(tmp-min_phi)/(max_phi-min_phi);
            imwrite(uint8(tmp),[out_dir,filesep,in_file_name,'Phi_n_',num2str(n),'.jpg'],'jpg');
%             saveas(gca,[out_dir,filesep,num2str(n)],'fig') ;%save figure
        end         %         if (~mod(n,SaveRefresRate))        
    end         %    if (~mod(n,FigRefresRate))   
end % for n=1:N % main loop


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Servise sub function             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=Delta_eps(z,epsilon)
if nargin==1
    epsilon=1;
end
out=epsilon/pi./(epsilon^2+z.^2);
% out=(1/(2*epsilon))*(1+cos(pi*z/epsilon)).*(abs(z)<=epsilon);