% Improving on topoChico2

function topoChico13(depth_level)
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
%Yr_vec = 1980:1:2020;
Yr_vec = 1980:1:2019;
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
%time = time_temp(1201:end);
time = time_temp(1201:1201+456-1);

nx = length(lon);
ny = length(lat);   
nt = length(time);

txtLeft = 'godasClimatologyData_';
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
%ncwriteatt(my_ncfile,'lon','units','degrees_east');
ncwriteatt(my_ncfile,'lon','axis','X');

nccreate(my_ncfile,'lat','Dimensions',{'lat',1,ny});
ncwrite(my_ncfile,'lat',lat);
ncwriteatt(my_ncfile,'lat','standard_name','latitude');
ncwriteatt(my_ncfile,'lat','long_name','Latitude');
%ncwriteatt(my_ncfile,'lat','units','degrees_north');
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

% auxilary functions 
month_idx_fcn = @(h,j) h+j*12;
temp_fcn = @(t) cel_seaTemp(:,:,t);

% to compute anomalies
graphino_mat = zeros(nx,ny,12,nt/12);
graphino_mat_centered = 0.*graphino_mat;

% to store climatology (lon,lat,month)
clim_mat = zeros(nx,ny,12); 

% to obtain indices 
% rows: month, cols: year
month_idx_mat = zeros(12,nt/12);

% compute climatologies and anom
for mm=1:12
    for nn=0:(nt/12)-1
        month_idx_mat(mm,nn+1) = month_idx_fcn(mm,nn);
    end
    month_idx_vec = month_idx_mat(mm,:);
    graphino_mat(:,:,mm,:) = temp_fcn(month_idx_vec);
    clim_mat(:,:,mm) = mean(temp_fcn(month_idx_vec),3,'omitnan');
end

% allocate memory for centered data
centered_monthly_temperature = 0.*cel_seaTemp;

for mm=1:12
    month_idx_vec = month_idx_mat(mm,:);
    centered_monthly_temperature(:,:,month_idx_vec) = temp_fcn(month_idx_vec)-clim_mat(:,:,mm);
end

nccreate(my_ncfile,'deepTemp','Dimensions',{'lon','lat','time'},'Datatype','single') ;

% change cel_seaTemp to climatology value
ncwrite(my_ncfile,'deepTemp',centered_monthly_temperature);

ncwriteatt(my_ncfile,'deepTemp','long_name','Monthly Climatology');
ncwriteatt(my_ncfile,'deepTemp','units','degC');

fprintf('Finished writing NetCDF file\n');
%%%%%%%%%%%%%%%% End writing NetCDF %%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% Begin writing anomalies %%%%%%%%%%%%%%%
shifted_anomalies = zeros(12,nt/12);

lon_slice_idx = find(175 <lon & lon < 225);
lat_slice_idx = find(-5.5 < lat & lat < 5.5);

for jj = 1:12
    for kk=1:nt/12
        graphino_mat_centered(:,:,jj,kk) = graphino_mat(:,:,jj,kk) - clim_mat(:,:,jj);
        current_region = graphino_mat_centered(lon_slice_idx,lat_slice_idx,jj,kk);
        shifted_anomalies(jj,kk) = mean(current_region,[1 2],'omitnan');
    end
end

% reshape as 1D array 
reshaped_anom = reshape(shifted_anomalies,[1 12*nt/12]);
%reshaped_anom = reshape(shifted_anomalies_1982_2017,[1 12*36]);

% calculate moving average
averaged_anom = 0.*reshaped_anom;
% averaged_anom = zeros(12,36);
averaged_anom(3:end) = movmean(reshaped_anom,[2 0],'EndPoints','discard');
% just filler values, won't be considered anyway 
averaged_anom(1) = shifted_anomalies(1,1);
averaged_anom(2) = (1/2)*(shifted_anomalies(1,1)+shifted_anomalies(2,1));

% reshape back to 12 by yr_sz array 
graphino_anom = reshape(averaged_anom,[12 nt/12]);

% remove first, second, and last years to obtain 1982 to 2017
% graphino_anom_for_NC = graphino_anom(:,3:end-1);

% this is 1980 to 2017
graphino_anom_for_NC = graphino_anom(:,1:end);

all_anomalies = graphino_anom_for_NC';

yrs_mat = zeros(nt/12,1);
jj=1980;
for kk = 1:length(yrs_mat)
    yrs_mat(kk) = jj;
    jj = jj+1;
end

txtTitle_fcn = @(depth) strcat('movingAverageAnomalies',num2str(depth),'m.txt');
txtTitle = txtTitle_fcn(depth_level)
anomalies_txt = [yrs_mat, round(all_anomalies,2)];
M = anomalies_txt; 
writematrix(M,txtTitle,'Delimiter','space')
fprintf('Finished writing .txt file\n');
%%%%%%%%%%%%%%%% End writing anomalies %%%%%%%%%%%%%%%%%
end


