%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notes:
% topoChico5 will compute temperature anomalies
% from Shen's data and produce .txt file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

my_ncfile = 'shenData.nc';
deepTemp = ncread(my_ncfile,'deepTemp');

% Overwrite indices
% lat: y-vals
% lon: x-vals
lat_Index = 85; lon_Index = 171;
% Since latitude resolution is high
% we need 33 indices to achieve a difference of 10 degrees North
lat0 = lat_Index; latf = lat_Index+11;
% Since longitude resolution is low
% we only need 50 indices to achieve a difference of 50 degrees East
lon0 = lon_Index; lonf = lon_Index+50;

% Indices
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
    % extract rectangular nino 3.4 region 
%    windowed_deepTemp_mod12 = deepTemp_mod12(lat_Interval,lon_Interval,:);
    windowed_deepTemp_mod12 = deepTemp_mod12(lon_Interval,lat_Interval,:);
    % compute global climatology
    current_global_climatology = mean(deepTemp_mod12,3,'omitnan');
    % for storing anomalies between 
    % data average and climatology average
    current_anomalies = zeros(nt/12,1);
    % Look at Nino Region in averaged climatology
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

txtLeft = 'Shen_deepTemp_anomalies_';
txtRight = 'm.txt';
txtMiddle = num2str(100);

txtTitle = strcat(txtLeft,txtMiddle,txtRight);
% txtTitle = 'deepTemp_anomalies_205m_TEST1.txt'
% anomalies_txt = [yrs_mat, round(anomalies_mat,2)];
anomalies_txt = [yrs_mat, round(all_anomalies,2)];
M = anomalies_txt; 
writematrix(M,txtTitle,'Delimiter','space')
fprintf('Finished writing .txt file\n');
