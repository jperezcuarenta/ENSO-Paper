%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s):
% Name                                  | Type
% godasClimatologyData_Xm               | NC
%
% Output(s):
% 3D anomaly view                       | eps
% 3D anomaly view                       | png
%
% Code Description: 
% This program saves a plot of 3D view of temperature anomalies
% using the GODAS set belonging to Figures 2 and 3 in paper. Used
% to visualize Nino and Nina episodes.
%
% Can switch value of 'mm' depending of visual of Niño or Niña
%
% Personal Notes:
% Original code comes from topoChico12.m
% Need to erase comments for cleaning up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all 

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

rotate_image = @(f) rot90(rot90(rot90(f)));

lat = ncread('godasClimatologyData_105m.nc','lat');
lon = ncread('godasClimatologyData_105m.nc','lon');
% -20 N to +20 N of Equator
lat_slice_idx = find(-20 < lat & lat < 20);
% 130 degrees East to 260 degrees East
lon_slice_idx = find(130 < lon & lon < 260);

oceanTemp = zeros(nd,length(lon_slice_idx),length(lat_slice_idx),nt);

%for loop to visit all NC files

% auxilary function:
godas_fcn = @(x) strcat('godasClimatologyData_',num2str(x),'m.nc');

for jj=1:nd
    curr_depth = depth_selection_vec(jj);
    temp_godas_dir = godas_fcn(curr_depth);
    deepTemp_current = ncread(temp_godas_dir,'deepTemp');
    oceanTemp(jj,:,:,:) = deepTemp_current(lon_slice_idx,lat_slice_idx,:);
end

oceanPerm = permute(oceanTemp,[2 3 1 4]);
ocean_func = @(d,t) oceanPerm(:,:,d,t);
ocean_lon_func = @(nx,t) oceanPerm(nx,:,:,t);
ocean_lat_func = @(ny,t) oceanPerm(:,ny,:,t);

Z_depth = zeros(length(lon_slice_idx),length(lat_slice_idx),nd,nt);
Z_lon = zeros(10,length(lat_slice_idx),nd,nt);
Z_lat = zeros(length(lon_slice_idx),10,nd,nt);
%%
%gc1 = figure;
for hh = 1:nt
    for jj=1:nd
        temp = pcolor(ocean_func(jj,hh));
        Z_depth(:,:,jj,hh) = temp.CData;
    end
end
%%
H_fig = figure('WindowState','maximized');

% For december 2015 do:
% mm=432;
% title_text ='Tropical Pacific Anomalies Dec 2015';

graph_counter = 2;

% For 1998 Jan do:
% mm = 1+12*0 @1980
% mm = 1+12*1 @1981
% mm = 1+12*18 @ 1998 

% Jan 1998 (Niño)
% mm=1+12*18;

% Jan 2000 (Niña)
mm = 1+12*20;

H(1) = slice(repmat(Z_depth(:,:,nd,mm),[1 1 2]), [], [], 1);
set(H(1),'EdgeColor','none');
hold on
for jj=1:3:nd-1
    H(graph_counter) = slice(repmat(Z_depth(:,:,end-jj,mm),[1 1 jj+1]),[],[],graph_counter);
    set(H(graph_counter),'EdgeColor','none');
    graph_counter = graph_counter+1;
end
colormap jet

% latitude
 xlim([1 120]);
 xlabel('Latitude','Interpreter','Latex');
 xticks([1, floor((1+120)/2), 120])
 xticklabels({'20^{\circ} S','0^{\circ}','20^{\circ} N'})
% longitude
ylim([1 130]);
ylabel('Longitude','Interpreter','Latex');
yticks([1, floor((1/2)*(130)), 130]);
yticklabels({'130^{\circ} E','180^{\circ}','100^{\circ} W'});
% depth
 zlabel('Depth','Interpreter','Latex');
zticks([1:8]);
  zticklabels({'165 m', '155 m', '125 m', '95 m', '65 m', '35 m', '5 m'});
hold off
%title('Tropical Pacific Anomalies, January 1998','Interpreter','Latex','FontSize',24);
title('Tropical Pacific Anomalies, January 2000','Interpreter','Latex','FontSize',24);
caz = 53.062499999999986;
cel = 10.310091743119280;
view(caz,cel)
%%

% save fig commands
set(H_fig,'Color','w');
% title of image 
% Niño year
% img_title = '3DAnomaliesJan1998';
% Niña year
img_title = '3DAnomaliesJan2000';
par_dir = strcat('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\ENSO_Paper_Figures\',img_title);
export_fig(par_dir,'-eps');
export_fig(par_dir,'-png');