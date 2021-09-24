% Notes play with OGCM data 

function topoChico7(depth_level_index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Inputs
%   Name         type   description
%   depth_level  int    input depth level index
%                       acceptable inputs are
%                       1 for 0 meter depth
%                       2 for 10 meter depth etc
%
%                       Possible meter selection:
%                       0, 10, 20, 30, 50, 75, 100, 125, 150, 200
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
possible_depths = [0, 10, 20, 30, 50, 75, 100, 125, 150, 200];
% make it start at 15.5 days after? 
% check 21533.5 days after 1891-01-01 to steal time vector from Colab file 
% can use 21563.5 days after 1891-01-01 from Colab file to steal time
% vector 
% Probably better...

% currently using days after 1950-01-01 00:00:00 
t_0 = 1950; t_f = 2003;
nt = 12*(t_f-t_0+1);

t = [];
t_new = t_0;
cnt = 1;
for jj=1:(t_f-t_0+1)
    for kk=1:12
        t = [t, datetime(t_new,kk,1)];
    end
    t_new = t_new+1;
end
time_calendarDate = caldiff(t,'days')';
time_temp = split(time_calendarDate,'days');
time = zeros(nt,1);
time(1) = 0;
sum = 0;
for jj=1:nt-1
    sum = sum + time_temp(jj);
   time(jj+1) = sum;
end
%%%%%%%%%%%%%%%% Writing Temperature %%%%%%%%%%%%%%%%
% lon (nx), lat (ny), time (nt)
nx = 360;
ny = 180;
nt = nt;
% 3D array of zeros 
oceanTemp = zeros(nx,ny,nt);
months = ["Jan", "Feb", "Mar", "Apr", ...
    "May", "Jun", "Jul", "Aug", "Sep", ...
    "Oct", "Nov", "Dec"];
year_Vec = t_0:t_f;
% depth_selection = 100;
% takes me to correct folder 
temp1_dir = 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\OGCM_1x1\';
%(122)_(Jan)_(1950)_5m-5500m_1x1';

desiredDir = @(tot_count,current_month,year_count) strcat(temp1_dir,num2str(tot_count),...
    '_',months(current_month),'_',num2str(year_Vec(year_count)),'_5m-5500m_1x1.mat');

cnt=1;
yr_cnt = 1;
for kk=1:length(year_Vec)
    for jj=1:12
        current_mat = load(desiredDir(cnt+121,jj,yr_cnt));
        data = current_mat.data;
        oceanTemp(:,:,cnt) = data(:,:,depth_level_index);
        cnt=cnt+1;
    end
    yr_cnt=yr_cnt+1;
end

% steal longitude 
% change latitude 
% latitude in colab is North to South
% latitude in OGCM is South to North
% longitude is same 
colab_ncfile = 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\sst.mon.mean.trefadj.anom.1880to2018.nc';
% "steal" lon and lat 
lon = ncread(colab_ncfile,'lon');
% comparing lat between colab and OCGM
lat = -ncread(colab_ncfile,'lat');

temp_text1 = 'OCGM_';
temp_text2 = num2str(possible_depths(depth_level_index));
temp_text3 = 'meters_depth.nc';
temp_text = strcat(temp_text1,temp_text2,temp_text3);
my_ncfile = temp_text;

nccreate(my_ncfile,'time','Dimensions',{'time',1,Inf});
ncwrite(my_ncfile,'time',time);
ncwriteatt(my_ncfile,'time','standard_name','time');
ncwriteatt(my_ncfile,'time','long_name','Time');
ncwriteatt(my_ncfile,'time','units','days since 1950-1-1 00:00:00');
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

nccreate(my_ncfile,'deepTemp','Dimensions',{'lon','lat','time'},'Datatype','single') ;
ncwrite(my_ncfile,'deepTemp',oceanTemp);

fprintf('Finished writing NetCDF file\n');
% End writing NetCDF 


%%%%%%%%%%%%%%%% Begin writing anomalies %%%%%%%%%%%%%%%
lat_Index = 85;  
% lon_Index = 185;
lon_Index = 170;
lat0 = lat_Index; latf = lat_Index+10;
lon0 = lon_Index; lonf = lon_Index+50;

lat_Interval = lat0:latf;
lon_Interval = lon0:lonf;

% this is the equivalent to our final .txt file in .mat format
all_anomalies = zeros(nt/12,12);

% Useful function for Mod12 indices 
visitMe = @(jj) [1:12:nt]+(jj-1);

deepTemp = oceanTemp;

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
jj=1950;
for kk = 1:length(yrs_mat)
    yrs_mat(kk) = jj;
    jj = jj+1;
end

txtLeft = 'deepTemp_anomalies_';
txtRight = 'm.txt';
txtMiddle = num2str(possible_depths(depth_level_index));
txtTitle = strcat(txtLeft,txtMiddle,txtRight);
anomalies_txt = [yrs_mat, round(all_anomalies,2)];
M = anomalies_txt; 
writematrix(M,txtTitle,'Delimiter','space')
fprintf('Finished writing .txt file\n');
%%%%%%%%%%%%%%%% End writing anomalies %%%%%%%%%%%%%%%%%
end

% Notes:
% I have been using monthly temperature with GODAS (input) to predict anomalies 
% Hackathon uses monthly global anomaly seems like as input 
% Then why didn't Shen's data work? 

% To do:
% 1.    Try shen's data with procedure from GODAS
% 2.    Investigate difference between monthly data and anomaly data as input
%       data 
% 3.    Can even compare anomaly .txt files now 
% 4.    Update time vector from colab file to not mess w pandas