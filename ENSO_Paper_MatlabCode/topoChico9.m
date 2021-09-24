% Need to compare COBE, GODAS, OGCM NC files
% I will compare surface temperatures for Jan 1980
% This script helps visualize 
% 1) COBE data set
% 2) OGCM reconstructed temp anomalies

% 3) GODAS data set
% 4) OGCM reconstructed temp

close all

% Main directory
dir = pwd;

% 270 deg rot
rot_im = @(x) rot90(rot90(rot90(x)));

%%%%%%%%%%%%%% Global Anomalies
% Read COBE and graph
dir_cobe = strcat(pwd,'\sst.mon.mean.trefadj.anom.1880to2018.nc'); 
SST_cobe = ncread(dir_cobe,'sst');
% 360 x 180 (nx by ny)
jan_temperature_cobe = SST_cobe(:,:,1201);
figure;
imagesc(jan_temperature_cobe); colorbar()
title('Jan 1980 (COBE Set)');
figure;
surf(jan_temperature_cobe); colorbar()
shading interp
title('Jan 1980 (COBE Set)');

% Read OGCM anomalies and graph
mat_dir = strcat(pwd,'\OGCM Files\OGCM Monthly Anomalies\Data\2D_Reconstructions_5m-2000m\5m\Top Layer361_Reconstructed_Temp_Anomaly_Jan1980.mat');
mat_file = load(mat_dir);
% 180 x 360 
ogcm_anom = mat_file.M;
jan_temperature_ogcm_anom = ogcm_anom;
figure;
imagesc(rot_im(jan_temperature_ogcm_anom)); colorbar()
title('Jan 1980 (OGCM Anomalies) rotated');
figure; 
imagesc(jan_temperature_ogcm_anom); colorbar()
title('Jan 1980 (OGCM Anomalies) non-rotated');

%figure;
%surf(rot_im(jan_temperature_ogcm_anom)); colorbar()
%title('Jan 1980 (OGCM Anomalies)');
%shading interp
% Notes:

% Use rot_im 3 times, store NC files that match COBE, and run Notebook
% May be better alternative since more years are available 



%%%%%%%%%%%%%% Global Temperature
% Read GODAS and graph
dir_godas = strcat(pwd,'\GODAS Files\godasData_5m.nc');
SST_godas = ncread(dir_godas,'deepTemp');
% 360 x 418 (nx by ny)
jan_temperature_godas = SST_godas(:,:,1);
figure;
imagesc(jan_temperature_godas); colorbar()
title('Jan 1980 (GODAS Set)');

% Read OGCM and graph
% think it is is 361th entry for Jan 1980
dir_OGCM = strcat(pwd,'\OGCM Files\OGCM NC Files and Temp Anomalies\OCGM_0meters_depth.nc');
SST_ogcm_fromNC = ncread(dir_OGCM,'deepTemp');
jan_temperature_ogcm_fromNC = SST_ogcm_fromNC(:,:,361);
figure;
imagesc(jan_temperature_ogcm_fromNC); colorbar()
title('Jan 1980 (OGCM Set)');

% check to see if valid time index 
mat_file = load(strcat(pwd,'\OGCM_1x1\122_Jan_1950_5m-5500m_1x1.mat'));
SST_ogcm_fromSource = mat_file.data;
jan_temperature_ogcm_fromSource = SST_ogcm_fromSource(:,:,1);
figure; 
imagesc(jan_temperature_ogcm_fromSource); colorbar()
title('Jan 1980 (OGCM Set - Source)');

% Notes:
% GODAS can train model due to high resolution in latitude 
% Else, monthly anomalies are better predictors
% Maybe because high resolution can deal with larger spread of data ( < 30
% degrees)
% and low resolution has to deal with lower spread of data ( < 10 degrees)

% what if we "tag" Niño events as +1, Niña as -1, and 
% none as 0

% 1. So experiment with OGCM anomalies provied by Shen 
% with SST anomalies in Hackathon document 

% 2. What if we train using Shen climatologies with SST anomalies,
% or even try a larger matrix with all data in 1 time step  

% Thermocline begins at 200 m depth: separation between cold/warm 

% During Niño, thermocline slope is zero 

% So far GODAS has been a good 'predictor' for SST anomalies which define
% ENSO
% I am gonna try deep ocean anomalies as predictor and report 


% NC files for COBE and OGCM Temp anomalies have EAST orientation
% NC files for GODAS and OGCM have WEST orientation

%%%%
% Notes
% Jun 03, 2021  
% identify cold anomalies in deep ocean 
% these should match warm peaks in sea surface 
% present a figure tomorrow :-)

%%%% 
% Notes 
% Jun 04, 2021
% have a google drive for all five of us NERTO 
% obtain benchmark
%%
% missing vals 
% -9.969209968386869e+36 
% 227 lat is index of equator 

% read NC file 
dir1 = 'pottmp.';
dir2 = @(yr) num2str(yr);
dir3 = '.nc';
nc_name_func = @(yr) strcat(dir1,dir2(yr),dir3);

temperature_matrix = zeros(360,30,40,12*(2020-1980+1));
cnt = 1;
for mm=1980:2020
    temp_pottmp = ncread(nc_name_func(mm),'pottmp');
    temp_pottmp( temp_pottmp == -9.969209968386869e+36 ) = NaN; 
%    temperature_matrix(:,:,cnt*[1:12]) = temp_pottmp(:,227,:,:);
    temperature_matrix(:,:,:,cnt*[1:12]) = temp_pottmp(:,210:239,:,:);
%    seaTemp = convtemp(temperature_matrix,'K','C');
    cnt = cnt+1;
end
seaTemp = convtemp(temperature_matrix,'K','C');
B = permute(seaTemp,[3 1 2 4]);

B_cast = cast(B(:,:,:,1),'uint8');

B = permute(temperature_matrix,[3 1 2 4]);

plot_func = @(t) imagesc(temperature_matrix(:,:,t)');
%pottmp( pottmp == -9.969209968386869e+36 ) = NaN;
%plot_func = @(t) imagesc(squeeze(pottmp(:,227,:,t))');
%%
figure;
for jj=1:492
    plot_func(jj);
    title(strcat('jj=',num2str(jj)));
    colorbar()
    xlabel('longitude');
    ylabel('depth');
    pause(0.1)
end


%%
close all
surface_anomalies_mat = readmatrix('nino34.long.anom.data.trimmedForOGCM.txt');
temporary_anomalies = surface_anomalies_mat(1:end-1,2:end);

% size of array we are working with 
[M_anomalies,N_anomalies] = size(temporary_anomalies);
% read time series from 1950 to 2018
surface_anomalies = reshape(temporary_anomalies',[1, M_anomalies*N_anomalies]);

godas_100m_mat = readmatrix('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\OGCM Files\OGCM NC Files and Temp Anomalies\deepTemp_anomalies_100m.txt');
temporary_anomalies = godas_100m_mat(1:end-1,2:end);
[M_godas,N_godas] = size(temporary_anomalies);
godas_anomalies = reshape(temporary_anomalies',[1,M_godas*N_godas]);

% x axis label construction
x_ax = [];
x_ax_str = cell(1,14);
% initial OGCM year 
OGCM_start_yr = 1950;
cnt = 20*12*0+1;
for jj=1:14
    x_ax = [x_ax, cnt];
    x_ax_str(jj) = cellstr(num2str(OGCM_start_yr));
    cnt = 5*12*jj+1;
    OGCM_start_yr = OGCM_start_yr+5;
end

%% Plot for now 
figure;
time_vals = 1:M_anomalies*N_anomalies;
plot(time_vals,surface_anomalies);

% correlation between SST and deep ocean 
% spatial optimization 
% use kmeans to locate area 
% mention tom smith 
% mention figure in bulletin 
% 
%% to plot with shaded region 
y_pos_thresh = 0.4;
y_neg_thresh = -y_pos_thresh;
anomaly_instances = find(surface_anomalies > y_pos_thresh);
% idea: find where 1 begins and 1 ends, 
% plug these into anomaly_instances to find 
% indeces which correspond to begin and end 
% for positive temp anomalies 

% for tomorrow, just graph deep ocean anomalies
% and compare pos spikes w negative spikes...

%% garbage prob
counter = 0;
for jj = 1:M_anomalies*N_anomalies
    if anomaly_instances(jj) == 1
        counter = counter+1;
        if counter > 5
            jj
        end
    else
        counter = 0;
    end
end

% x-axis parameters
xlim([1, M_anomalies*N_anomalies]);
xticks(x_ax);
xticklabels(x_ax_str);
xlabel('Time','Interpreter','Latex');

% y-axis parameters
ylabel('Anomalies (Celsius)','Interpreter','Latex');


thresholdShade(x,y,[0.1 0.6],[0.3 0.7],[0.2 0.5],[0.4 0.8],100,0.2,-0.3,1);