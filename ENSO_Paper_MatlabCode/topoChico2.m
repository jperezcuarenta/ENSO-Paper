function topoChico2(depth_level)
% Use visualize3.m 
% Use visualiz4.m
% Combine these...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Inputs
%   Name         type   description
%   depth_level  int    input depth level
%                       acceptable inputs are
%                       5, 15, ..., 105, 115, ..., 205
%   Outputs
%   Name:        type -- description  
%   N/A
%
%   
%   Observations
%   topoChico2.m prints two items
%   (i)     .nc file with GODAS data at a
%           selected depth
%   (ii)    .txt file with temperature 
%           anomalies corresponding to
%           selected depth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% Begin writing NetCDF %%%%%%%%%%%%%%%%%
txtNC = 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\GODAS Files\pottmp.';
ncFunc = @(kk) strcat(txtNC,num2str(kk),'.nc');
Yr_vec = 1980:1:2020;
tempVec = @(jj) [1:12]+12*(jj-1);

godas_ncfile = ncFunc(1980);
%colab_ncfile = 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\Copy_of_colabData.nc';
colab_ncfile = 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\sst.mon.mean.trefadj.anom.1880to2018.nc';
time_temp = ncread(colab_ncfile,'time');

lon = ncread(godas_ncfile,'lon');
lat = ncread(godas_ncfile,'lat');
% Print level for acceptable depth values 
level = ncread(godas_ncfile,'level');
depthIndex = find(level == depth_level);
time = time_temp(1201:end);

nx = length(lon);
ny = length(lat);   
nt = length(time);

txtLeft = 'godasData_';
txtRight = 'm.nc';
txtMiddle = num2str(depth_level);
my_ncfile = strcat(txtLeft,txtMiddle,txtRight);

nccreate(my_ncfile,'time','Dimensions',{'time',1,Inf});
ncwrite(my_ncfile,'time',time);
ncwriteatt(my_ncfile,'time','standard_name','time');
ncwriteatt(my_ncfile,'time','long_name','Time');
ncwriteatt(my_ncfile,'time','units','days since 1891-1-1 00:00:00');
ncwriteatt(my_ncfile,'time','calendar','standard');
ncwriteatt(my_ncfile,'time','axis','T');

nccreate(my_ncfile,'lon','Dimensions',{'lon',1,nx});
ncwrite(my_ncfile,'lon',lon);
ncwriteatt(my_ncfile,'lon','standard_name','longitude');
ncwriteatt(my_ncfile,'lon','long_name','Longitude');
ncwriteatt(my_ncfile,'lon','units','degrees_east');
ncwriteatt(my_ncfile,'lon','axis','X');

nccreate(my_ncfile,'lat','Dimensions',{'lat',1,ny});
ncwrite(my_ncfile,'lat',lat);
ncwriteatt(my_ncfile,'lat','standard_name','latitude');
ncwriteatt(my_ncfile,'lat','long_name','Latitude');
ncwriteatt(my_ncfile,'lat','units','degrees_north');
ncwriteatt(my_ncfile,'lat','axis','Y');

kel_seaTemp = zeros(nx,ny,nt);

for kk = 1:length(Yr_vec)-2
    yr = Yr_vec(kk);
    godas_ncfile = ncFunc(yr);
    pottmp_current = ncread(godas_ncfile,'pottmp');
    % Store 3D (Nx,Ny,Nt) corresponding to yr
    seaTemp_current = pottmp_current(:,:,depthIndex,:);
    tempvec = tempVec(kk);
    kel_seaTemp(:,:,tempvec) = seaTemp_current;
end
kel_seaTemp(kel_seaTemp == -9.969209968386869e+36) = NaN;
cel_seaTemp = convtemp(kel_seaTemp,'K','C');
nccreate(my_ncfile,'deepTemp','Dimensions',{'lon','lat','time'},'Datatype','single') ;
ncwrite(my_ncfile,'deepTemp',cel_seaTemp);
ncwriteatt(my_ncfile,'deepTemp','long_name','Monthly Means of Sea Temperature');
ncwriteatt(my_ncfile,'deepTemp','units','degC');

fprintf('Finished writing NetCDF file\n');
%%%%%%%%%%%%%%%% End writing NetCDF %%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% Begin writing anomalies %%%%%%%%%%%%%%%
deepTemp = ncread(my_ncfile,'deepTemp');
deepTemp(deepTemp ==-9.969209968386869e+36) = NaN;

% Overwrite indices
lat_Index = 207; lon_Index = 170;
% Since latitude resolution is high
% we need 33 indices to achieve a difference of 10 degrees North
lat0 = lat_Index; latf = lat_Index+33;
% Since longitude resolution is low
% we only need 50 indices to achieve a difference of 50 degrees East
lon0 = lon_Index; lonf = lon_Index+50;

lat_Interval = lat0:latf;
lon_Interval = lon0:lonf;

% this is the equivalent to our final .txt file in .mat format
all_anomalies = zeros(nt/12,12);

% 12 global climatologies
global_climatologies = zeros(nx,ny,12);

% this variable is useful to see how 
% nino3.4 window average temperature changes 
% from January Climatology vs Feb Climatology vs
% March Climatology etc
windowed_climatologies_average = zeros(12,1);

% Useful function for Mod12 indices 
visitMe = @(jj) [1:12:nt]+(jj-1);

for nn=1:12
    % extract all data corresponding to current month
    deepTemp_mod12 = deepTemp(:,:,visitMe(nn));    
    % compute global climatology
    current_global_climatology = mean(deepTemp_mod12,3,'omitnan');
    % extract rectangular nino 3.4 region 
    % 05/06/2021 Think intervals are incorrect
%    windowed_deepTemp_mod12 = deepTemp_mod12(lat_Interval,lon_Interval,:);
    % should be lon,lat,time 
    windowed_deepTemp_mod12 = deepTemp_mod12(lon_Interval,lat_Interval,:);
    % for storing anomalies between 
    % data average and climatology average
    current_anomalies = zeros(nt/12,1);
    % Look at Nino Region in averaged climatology
    % 05/06/2021 Think intervals are incorrect
%    current_windowed_climatology = current_global_climatology(lat_Interval,lon_Interval);
    current_windowed_climatology = current_global_climatology(lon_Interval,lat_Interval);
    % Compute average value of climatology Nino3.4 region
    current_windowed_climatology_average = mean(current_windowed_climatology,'all','omitnan');
    % Compute anomalies by comparing Jan_i vs Jan Climatology,
    % Feb_i vs Feb Climatology, etc  
    for jj = 1:nt/12
        current_monthly_average = mean(windowed_deepTemp_mod12(:,:,jj),'all','omitnan');
        current_anomalies(jj) = current_monthly_average - current_windowed_climatology_average;
    end
    windowed_climatologies_average(nn) = current_windowed_climatology_average;
    global_climatologies(:,:,nn) = current_global_climatology;
    all_anomalies(:,nn) = current_anomalies;
end

yrs_mat = zeros(nt/12,1);
jj=1980;
for kk = 1:length(yrs_mat)
    yrs_mat(kk) = jj;
    jj = jj+1;
end

txtLeft = 'deepTemp_anomalies_';
txtRight = 'm.txt';
txtTitle = strcat(txtLeft,txtMiddle,txtRight);
% txtTitle = 'deepTemp_anomalies_205m_TEST1.txt'
% anomalies_txt = [yrs_mat, round(anomalies_mat,2)];
anomalies_txt = [yrs_mat, round(all_anomalies,2)];
M = anomalies_txt; 
writematrix(M,txtTitle,'Delimiter','space')
fprintf('Finished writing .txt file\n');
%%%%%%%%%%%%%%%% End writing anomalies %%%%%%%%%%%%%%%%%
end