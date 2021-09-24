close all
clear all

%https://serc.carleton.edu/NAGTWorkshops/ocean/visualizations/elnino_lanina.html
%    https://github.com/salvaRC/Graphino
% lon (nx), lat (ny), time (n#t)
nx = 360;
ny = 180;
t_0 = 1950; t_f = 2012;
year_Vec = t_0:t_f;
 
nt = 12*(t_f-t_0+1);
% can use 200 m depth but copied:
% 200m31_Reconstructed_Temp_Anomaly_Jul1952.mat
% 200m43_Reconstructed_Temp_Anomaly_Jul1953.mat
% 200m55_Reconstructed_Temp_Anomaly_Jul1954.mat
% ...

% %%%%% following code replaces Jul with Jun data at 200 m
% %%%%% depth due to lack of files 
% 
% % initialize with 186 and 1965 then add 1 to both in each loop 
% jun_miss_string = @(num,year) strcat('200m',num2str(num),'_Reconstructed_Temp_Anomaly_Jun',num2str(year));
% jul_miss_string = @(num,year) strcat('200m',num2str(num),'_Reconstructed_Temp_Anomaly_Jul',num2str(year));
% 
% jun_cnt = 186;
% year_cnt = 1965;
% 
% while jun_cnt < 756
%     temp1 = load(jun_miss_string(jun_cnt,year_cnt));
%     M = temp1.M;
%     
%     jun_cnt+1
%     save(jul_miss_string(jun_cnt+1,year_cnt),'M');
%     
%     year_cnt = year_cnt+1;
%     jun_cnt = jun_cnt + 12;
% end
% 
% 
% %%%%% end

depth_selection_vec = [10,20,30,50,75,100,125,150,200,250];
%depth_selection_vec = [10,20,30,50,75,100,125,150];
nd = length(depth_selection_vec);

months = ["Jan", "Feb", "Mar", "Apr", ...
    "May", "Jun", "Jul", "Aug", "Sept", ...
    "Oct", "Nov", "Dec"];

rotate_image = @(f) rot90(rot90(rot90(f)));

% store rotated image just to match COBE orientations 
% rotate_image(current_mat) is of size (lon) 360 x  (lat) 180 
% lon is North to South 
% lat is along East direction of Prime Meridian
% so I need to slice (90-20):(90+20) for lat
% and slice 
lat_slice = [(90-20):(90+20)];
lon_slice = [140:(360-100)];

% 4D array of zeros 
% ignoring this 
% oceanTemp = zeros(nd,nx,ny,nt);

% 
oceanTemp = zeros(nd,length(lon_slice),length(lat_slice),nt);

dir = strcat(pwd,'\OGCM Files\OGCM Monthly Anomalies\Data\2D_Reconstructions_5m-2000m\');
dir_depth1 = @(depth_sel) strcat(num2str(depth_sel),'m\');
dir_depth2 = @(depth_sel) strcat(num2str(depth_sel),'m');
dir_counter = @(counter_sel) strcat(num2str(counter_sel),'_Reconstructed_Temp_Anomaly_');
dir_month = @(month_sel) months(month_sel);
dir_year = @(year_sel) strcat(num2str(year_Vec(year_sel)),'.mat');

% a is depth selection: 1 to nd
% b is overall counter: 1 to nt
% c is month selection: 1 to 12 
% d is year selection: 1 to length(year_Vec)

dir_final = @(a,b,c,d) strcat(dir,dir_depth1(a),dir_depth2(a),dir_counter(b),dir_month(c),dir_year(d));

% visit depth
for jj=1:nd
    % select depth
    curr_depth = depth_selection_vec(jj);
    % initialize overall counter
    cnt = 1;

    %visit year, kk is fed into dir_year
    for kk=1:length(year_Vec)
        % for each year, visit all twelve months 
        for mm=1:12
            current_mat_struct = load(dir_final(curr_depth,cnt,mm,kk));
            current_mat = current_mat_struct.M;
            current_mat_rotated = rotate_image(current_mat);
            oceanTemp(jj,:,:,cnt) = current_mat_rotated(lon_slice,lat_slice);
            cnt = cnt+1;
        end
    end
end

%colormap = jet;
oceanPerm = permute(oceanTemp,[2 3 1 4]);
ocean_func = @(d,t) oceanPerm(:,:,d,t);
ocean_lon_func = @(nx,t) oceanPerm(nx,:,:,t);
ocean_lat_func = @(ny,t) oceanPerm(:,ny,:,t);

Z_depth = zeros(length(lon_slice),length(lat_slice),nd,nt);
Z_lon = zeros(10,length(lat_slice),nd,nt);
Z_lat = zeros(length(lon_slice),10,nd,nt);

%% animate with CData PT 1 (depth)

% cut according to other dimensions 
% check imsegkmeans3 -- 3 clusters to obtain correct subsurface region 
% calculate energy capacity, surplus or deficit 


% change ocean_func to accept two variables, depth and time 
% then plot ocean_func(depth,time) with animations
% also have to worry about time 

% report k means results with volume segmentation?

for hh = 1:nt
    for jj=1:nd
        temp = pcolor(ocean_func(jj,hh));
%        h = pcolor(temp(:,:,jj));
    %    h.caxis = [-5 5];
        Z_depth(:,:,jj,hh) = temp.CData;
    end
    
    for kk = 1:10
        temp = pcolor(squeeze(ocean_lon_func(10*kk+1,hh)));
        Z_lon(kk,:,:,hh) = temp.CData;
    end
    
    for mm = 1:8
        temp = pcolor(squeeze(ocean_lat_func(5*mm+1,hh)));
        Z_lat(:,mm,:,hh) = temp.CData;
    end
end


%% adding this to try slicing in subfig 
figure;
H(1) = slice(repmat(squeeze(Z_lon(10,:,:,mm)),[1 1 2]), [], [], 1);
set(H(1),'EdgeColor','none');
for jj=1:10-1
    H(jj+1) = slice(repmat(squeeze(Z_lon(end-jj,:,:,mm)),[1 1 jj+1]),[],[],jj+1);
    set(H(jj+1),'EdgeColor','none');
    hold on
end
hold off
colormap jet
title('longitude slices','Interpreter','Latex');

%%
figure;
H(1) = slice(repmat(squeeze(Z_lat(:,8,:,mm)),[1 1 2]), [], [], 1);
%H(1) = slice(repmat(squeeze(Z_lat(:,8,:,mm)),[1 1 2]), 1, [], []);
set(H(1),'EdgeColor','none');
for jj=1:8-1
    H(jj+1) = slice(repmat(squeeze(Z_lat(:,end-jj,:,mm)),[1 1 jj+1]),[],[],jj+1);
%    H(jj+1) = slice(repmat(squeeze(Z_lat(:,end-jj,:,mm)),[1 1 jj+1]),jj+1,[],[]);
    set(H(jj+1),'EdgeColor','none');
    hold on
end
hold off
title('latitude slices','Interpreter','Latex');
colormap jet

%% animate with CData PT 2
%for hh = 1:nt
%    for jj=1:nd
%        temp = pcolor(ocean_func(jj,hh));
%        Z_depth(:,:,jj,hh) = temp.CData;
%    end
%end

H_fig = figure;
%filename = 'TropicalPacificAnomaliesMoreDepths.gif';

year_counter = 1;
for mm=1:nt
    H(1) = slice(repmat(Z_depth(:,:,nd,mm),[1 1 2]), [], [], 1);
    set(H(1),'EdgeColor','none');
    for jj=1:nd-1
        H(jj+1) = slice(repmat(Z_depth(:,:,end-jj,mm),[1 1 jj+1]),[],[],jj+1);
        set(H(jj+1),'EdgeColor','none');
        hold on
    end
    hold off
    colormap jet
    %axis ij

    % latitude
    xlim([0 41]);
    xlabel('Latitude','Interpreter','Latex');
    xticks([1, floor((1+41)/2), 41])
    xticklabels({'20^{\circ} S','0^{\circ}','20^{\circ} N'})

    % longitude
    ylim([0 121]);
    ylabel('Longitude','Interpreter','Latex');
    yticks([0, floor((1/2)*(121)), 121]);
    yticklabels({'100^{\circ} W','180^{\circ}','140^{\circ} E'});

    % depth
    zlabel('Depth','Interpreter','Latex');
    zticks([1:nd]);
    %[10,20,30,50,75,100,125,150];
    zticklabels({'250 m', '200 m', '150 m','125 m','100 m','75 m','50 m','30 m','20 m','10 m'}); 
%    zticklabels({'300 m','250 m','200 m','150 m','125 m','100 m','75 m','50 m','30 m','20 m','10 m'}); 
    hold off

    title_static_text = 'Tropical Pacific Anomalies';
%    title_text_month = months(1);
    title_text_month = months(mod(mm-1,12)+1);
%    title_text_year = num2str(year_Vec(1));
    title_text_year = num2str(year_Vec(year_counter));
    if mod(mm,13) == 1
        year_counter = year_counter+1;
    end
    title_text = strcat(title_static_text,'{ }', title_text_month,'{ }', ...
        title_text_year);
    title(title_text,'Interpreter','Latex');

    pause(0.1)
    % Capture the plot as an image
    frame = getframe(H_fig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
%    if mm == 1
%        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
%    else
%        imwrite(imind,cm,filename,'gif','WriteMode','append'); 
%    end
end

%% Animate with CData at strong January months 
% https://ggweather.com/enso/oni.png
% threshold vals in Jan: 
% cold: 1955, 1976, 1988, 1999, 2007
% warm: 1957, 1965, 1972, 1982, 1987, 1991, 1997

% t = 1 corresponds to Jan 1950
% t = nt corresponds to Dec 2012
T = @(x) 12*x+1;

% so pick t from 1955-1950, 1976-1950, 1988-1950,
cold_indices = [5, 26, 38, 49, 57];
warm_indices = [7, 15, 22, 32, 37, 41, 47, 65];

anomaly_indices = [5, 7, 15, 22, 26, 32, 37, 38, 41, 47, 49, 57];
cell_names = {};
for jj=1:length(anomaly_indices)
    cell_names{jj} = strcat('Jan ', {' '}, num2str(1950+anomaly_indices(jj)));
end

z_anomalies = zeros(length(lon_slice),length(lat_slice),nd,length(anomaly_indices));

for hh = 1:length(anomaly_indices)
    for jj=1:nd
        anom = anomaly_indices(hh);
        temp = pcolor(ocean_func(jj,T(anom)));
%        h = pcolor(temp(:,:,jj));
    %    h.caxis = [-5 5];
        Z_anomalies(:,:,jj,hh) = temp.CData;
    end
end
close 

caz = -36.0613;
cel = 8.3621;
    
H_fig = figure;
filename = 'TropicalPacificAnomalies_Peaks.gif';

year_counter = 1;
for mm=1:length(anomaly_indices)
    H(1) = slice(repmat(Z_anomalies(:,:,nd,mm),[1 1 2]), [], [], 1);
    set(H(1),'EdgeColor','none');
    for jj=1:nd-1
        H(jj) = slice(repmat(Z_anomalies(:,:,end-jj,mm),[1 1 jj+1]),[],[],jj+1);
        set(H(jj),'EdgeColor','none');
        hold on
    end
    hold off
    colormap jet
    %axis ij

    % latitude
    xlim([0 41]);
    xlabel('Latitude','Interpreter','Latex');
    xticks([1, floor((1+41)/2), 41])
    xticklabels({'20^{\circ} S','0^{\circ}','20^{\circ} N'})

    % longitude
    ylim([0 121]);
    ylabel('Longitude','Interpreter','Latex');
    yticks([0, floor((1/2)*(121)), 121]);
    yticklabels({'100^{\circ} W','180^{\circ}','140^{\circ} E'});

    % depth
    zlabel('Depth','Interpreter','Latex');
    zticks([1:nd]);
    %[10,20,30,50,75,100,125,150];
    zticklabels({'250 m', '200 m','150 m','125 m','100 m','75 m','50 m','30 m','20 m','10 m'}); 
    hold off

    title_static_text = 'Tropical Pacific Anomalies';
%    title_text_month = months(1);
    title_text_month = months(mod(mm-1,12)+1);
%    title_text_year = num2str(year_Vec(1));
    title_text_year = num2str(year_Vec(year_counter));
    if mod(mm,13) == 1
        year_counter = year_counter+1;
    end
    title_text = strcat(title_static_text,'{ }', title_text_month,'{ }', ...
        title_text_year);
%    title(title_text,'Interpreter','Latex');
%    title('Peak Anomalies','Interpreter','Latex');
    title(char(cell_names{mm}),'Interpreter','Latex');
    view(caz,cel);

    
    pause(0.1)
    % Capture the plot as an image
   frame = getframe(H_fig);
   im = frame2im(frame);
   [imind,cm] = rgb2ind(im,256);
    
   if mm == 1
       imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
   else
       imwrite(imind,cm,filename,'gif','WriteMode','append'); 
   end
end

% does anomaly region move at peak months?

%% Animate with volshow
ocean_func_2 = @(t) oceanPerm(:,:,:,t);
for jj=1:nt
%    h = volshow(ocean_func_2(jj));
    L = imsegkmeans3(uint16(ocean_func_2(jj)),3);
    h = volshow(L);
    % update h vals:
    h.Colormap = jet;
    h.Renderer = 'MaximumIntensityProjection';
    h.BackgroundColor = [1 1 1];
%    h.BackgroundColor = [0 0 0];
%    h.CameraPosition = [1.9290 1.9290 1.2056];
    h.CameraPosition = [-1.7672 -1.9871 1.3506];
    pause(0.1)
end

% L = imsegkmeans3(ocean_func_2(1),2);


%h = volumeViewer(ocean_func(1));
% set max intens. projection
% alpha map to linear 
% colormap to jet

%figure; volshow(floor(ocean_func(1)),'Colormap',colormap);
%L = imsegkmeans3(floor(ocean_func(1)),2);
%figure; volshow(L,'Colormap',colormap);

%% repeat all code but for GODAS set to get figure at Dec 2015
% begin changing variables
% easier since accessing values is straightforward

nx = 360;
ny = 418;
t_0 = 1980; t_f = 2017;
year_Vec = t_0:t_f;
 
nt = 12*(t_f-t_0+1);

depth_selection_vec = [5:10:165];
nd = length(depth_selection_vec);

months = ["Jan", "Feb", "Mar", "Apr", ...
    "May", "Jun", "Jul", "Aug", "Sept", ...
    "Oct", "Nov", "Dec"];

% don't think it is needed
rotate_image = @(f) rot90(rot90(rot90(f)));

% replace above indices 
lat = ncread('godasClimatologyData_105m.nc','lat');
lon = ncread('godasClimatologyData_105m.nc','lon');
% -20 N to +20 N of Equator
lat_slice_idx = find(-20 < lat & lat < 20);
% 130 degrees East to 260 degrees East
lon_slice_idx = find(130 < lon & lon < 260);

oceanTemp = zeros(nd,length(lon_slice_idx),length(lat_slice_idx),nt);

%for loop to visit all NC files

% aux fcs:
godas_fcn = @(x) strcat('godasClimatologyData_',num2str(x),'m.nc');
for jj=1:nd
    curr_depth = depth_selection_vec(jj);
    temp_godas_dir = godas_fcn(curr_depth);
    deepTemp_current = ncread(temp_godas_dir,'deepTemp');
    oceanTemp(jj,:,:,:) = deepTemp_current(lon_slice_idx,lat_slice_idx,:);
end

%colormap = jet;
oceanPerm = permute(oceanTemp,[2 3 1 4]);
ocean_func = @(d,t) oceanPerm(:,:,d,t);
ocean_lon_func = @(nx,t) oceanPerm(nx,:,:,t);
ocean_lat_func = @(ny,t) oceanPerm(:,ny,:,t);

Z_depth = zeros(length(lon_slice_idx),length(lat_slice_idx),nd,nt);
Z_lon = zeros(10,length(lat_slice_idx),nd,nt);
Z_lat = zeros(length(lon_slice_idx),10,nd,nt);

%% animate with CData PT 1 (depth)

% cut according to other dimensions 
% check imsegkmeans3 -- 3 clusters to obtain correct subsurface region 
% calculate energy capacity, surplus or deficit 


% change ocean_func to accept two variables, depth and time 
% then plot ocean_func(depth,time) with animations
% also have to worry about time 

% report k means results with volume segmentation?

% for reference
%figure;
%temp_reference = pcolor(deepTemp_current(:,:,1));

figure;
for hh = 1:nt
    for jj=1:nd
        temp = pcolor(ocean_func(jj,hh));
%        h = pcolor(temp(:,:,jj));
    %    h.caxis = [-5 5];
        Z_depth(:,:,jj,hh) = temp.CData;
    end
    
%    for kk = 1:10
%        temp = pcolor(squeeze(ocean_lon_func(10*kk+1,hh)));
%        Z_lon(kk,:,:,hh) = temp.CData;
%    end
    
%    for mm = 1:8
%        temp = pcolor(squeeze(ocean_lat_func(5*mm+1,hh)));
%        Z_lat(:,mm,:,hh) = temp.CData;
%    end
end

%filename = 'TropicalPacificAnomaliesMoreDepths.gif';
%%

H_fig = figure;
%close
graph_counter = 2;
year_counter = 1;

% For december 2015 do:
% mm=432
% title_text ='Tropical Pacific Anomalies Dec 2015';

% For 1998 Jan do:
% mm = 1 @1980
% mm = 1+12*1 @1981
% mm = 1+12*18 @ 1998 
% title_text ='Tropical Pacific Anomalies Jan 1998';
for mm=1:nt
    H(1) = slice(repmat(Z_depth(:,:,nd,mm),[1 1 2]), [], [], 1);
    set(H(1),'EdgeColor','none');
    hold on
    % H(cnt) controls fig?
    % last input controls z level placement
    % jj controls access to jjth depth 
    for jj=1:3:nd-1
%        H(jj+1) = slice(repmat(Z_depth(:,:,end-jj,mm),[1 1 jj+1]),[],[],jj+1);
%        set(H(jj+1),'EdgeColor','none');
%        H(graph_counter) = slice(repmat(Z_depth(:,:,end-jj,mm),[1 1 jj+1]),[],[],jj+1);
        H(graph_counter) = slice(repmat(Z_depth(:,:,end-jj,mm),[1 1 jj+1]),[],[],graph_counter);
        set(H(graph_counter),'EdgeColor','none');
        graph_counter = graph_counter+1;
%        hold on
    end
    graph_counter = 2;
%    hold off
    colormap jet
    %axis ij

    % latitude
     xlim([1 120]);
     xlabel('Latitude','Interpreter','Latex');
     xticks([1, floor((1+120)/2), 120])
     xticklabels({'20^{\circ} S','0^{\circ}','20^{\circ} N'})
% 
%     % longitude
    ylim([1 130]);
    ylabel('Longitude','Interpreter','Latex');
    yticks([1, floor((1/2)*(130)), 130]);
%    yticklabels({'100^{\circ} W','180^{\circ}','140^{\circ} E'});
    yticklabels({'130^{\circ} E','180^{\circ}','100^{\circ} W'});
% 
%     % depth
     zlabel('Depth','Interpreter','Latex');
    zticks([1:8]);
%     zticklabels({'165 m', '145 m', '125 m', '105 m', '85 m', '65 m', '45 m', ...
%         '25 m'});
      zticklabels({'165 m', '155 m', '125 m', '95 m', '65 m', '35 m', '5 m'});
    hold off

    title_static_text = 'Tropical Pacific Anomalies';
%    title_text_month = months(1);
%    title_text_month = months(mod(mm-1,12)+1);
    title_text_month = months(mod(mm-1,12)+1);
%    title_text_year = num2str(year_Vec(1));
    title_text_year = num2str(year_Vec(year_counter));
    if mod(mm,12) == 1
        year_counter = year_counter+1;
    end
    title_text = strcat(title_static_text,'{ }', title_text_month,'{ }', ...
        title_text_year);
    title(title_text,'Interpreter','Latex');

    pause(0.1)

    % Capture the plot as an image
%    frame = getframe(H_fig);
%    im = frame2im(frame);
%    [imind,cm] = rgb2ind(im,256);
    
%    if mm == 1
%        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
%    else
%        imwrite(imind,cm,filename,'gif','WriteMode','append'); 
%    end
end

%% from topoChico13, anomalies are computed at 
nt = 456;
% 175 E to 225 E 
% VS 170W to 120W
% means a 15 degree shift 
% anom_lon_slice_idx = find(175 <lon & lon < 225);
H_fig_34 = figure;
rect_fcn = @(M) rectangle('Position',M, 'EdgeColor','r','LineWidth',3);
data5m = ncread('godasClimatologyData_5m.nc','deepTemp');
data5m_time_fcn = @(t) data5m(:,:,t);
filename_34 = 'Nino34RegionAnom.gif';
for jj=300:nt
    imagesc(data5m_time_fcn(jj));
    % coordinates for rectangle
    % find indices for -5 to 5 in LAT
    x1 = find(-5.5 < lat & lat < -4.5);
    x2 = find(4.5 < lat & lat < 5.5);
    x1 = x1(1); x2 = x2(1);
    lat_shift = x2-x1+1;

    % find indices for 170W-120W in LON
    % begin 190 E
    % end 240 E
    y1 = find(189 < lon & lon < 191); 
    y2 = find(239 < lon & lon < 241);
    y1 = y1(1); y2 = y2(1);
    lon_shift = y2-y1+1;

    M_1 = [x1, y1, lat_shift, lon_shift];

    rect_fcn(M_1);

    colorbar()
    caxis([-4 4])
    camroll(90);
    axis off
    title('GODAS Monthly Anomalies at Surface','Interpreter','Latex');
%    pause(0.01);
    drawnow
    frame = getframe(H_fig_34);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if jj == 300
        imwrite(imind,cm,filename_34,'gif', 'DelayTime', 0.1, 'Loopcount',inf); 
    else
        imwrite(imind,cm,filename_34,'gif', 'DelayTime',0.1, 'WriteMode','append'); 
    end
end

%% animation for deep ocean
data115m = ncread('godasClimatologyData_115m.nc','deepTemp');
data115m_time_fcn = @(t) data115m(:,:,t);
% did -20 to 20 for some reason

rect_fcn = @(M) rectangle('Position',M, 'EdgeColor','r','LineWidth',3);
% coordinates for rectangle
% find indices for -5 to 5 in LAT
x1 = find(-5.5 < lat & lat < -4.5);
x2 = find(4.5 < lat & lat < 5.5);
x1 = x1(1); x2 = x2(1);
lat_shift = x2-x1+1;

% find indices for 170W-120W in LON
% begin 190 E
% end 240 E
y1 = find(174 < lon & lon < 175.5); 
y2 = find(224 < lon & lon < 225.5);
y1 = y1(1); y2 = y2(1);
lon_shift = y2-y1+1;

M_1 = [x1, y1, lat_shift, lon_shift];

filename_115m = '115mDepthRegionAnom.gif';
H_fig_115 = figure;
for kk=1:nt
    imagesc(data115m_time_fcn(kk));
    rect_fcn(M_1);
    colorbar()
    caxis([-4 4])
    axis off
    title('GODAS Monthly Anomalies at 115 m Depth','Interpreter','Latex');
    camroll(90);
    pause(0.01);
%    drawnow
%    frame = getframe(H_fig_115);
%    im = frame2im(frame);
%    [imind,cm] = rgb2ind(im,256);
%    if kk == 300
%        imwrite(imind,cm,filename_115m,'gif', 'DelayTime', 0.1, 'Loopcount',inf); 
%    else
%        imwrite(imind,cm,filename_115m,'gif','DelayTime', 0.1, 'WriteMode','append'); 
%    end
end




