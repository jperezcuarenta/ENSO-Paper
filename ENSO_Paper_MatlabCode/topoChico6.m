% run simulation with climatology data anomaly 
% instead of computing climatology again on climatology 

nt = 756; 
nx = 360;
ny = 180;

% Read Monthly Anomaly
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
% all_anomalies = zeros(nt/12,12);

% 12 global climatologies
global_climatologies = zeros(nx,ny,12);

% this variable is useful to see how 
% nino3.4 window average temperature changes 
% from January Climatology vs Feb Climatology vs
% March Climatology etc
windowed_climatologies_average = zeros(12,1);

% Useful function for Mod12 indices 
visitMe = @(jj) [1:12:nt]+(jj-1);

%% NEW CODE GOES HERE 
all_anomalies = zeros(1,nt);

for jj=1:nt
    % access monthly data within Niño3.4 Region
    sample_deepTemp = deepTemp(lon_Interval,lat_Interval,jj);
%    sample_deepTemp = deepTemp(lon_Interval,lat_Interval,jj);
    % compute average value 
    current_anomaly = mean(sample_deepTemp,'all');
    % store anomaly in all_anomalies
    all_anomalies(jj) = current_anomaly;
end

all_anomalies = reshape(all_anomalies, [12 63])';

% write data to .txt file 

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
anomalies_txt = [yrs_mat, round(all_anomalies,2)];
M = anomalies_txt; 
writematrix(M,txtTitle,'Delimiter','space')
fprintf('Finished writing .txt file\n');

