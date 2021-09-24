%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notes:
% topoChico4.m will read through Shen's data set
% and write to 3D array in .nc format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% 
% Do not use this code anymore since it is based on incorrect
% data files
% Use topoChico6

%% Writing Time Vector 
% read colab data and study time vector 
% to see values after 1880-01-01 (or w/e time is)
t_0 = 1950; t_f = 2012;
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
% days after 1950-01-01
time_temp = split(time_calendarDate,'days');
time = zeros(nt,1);
time(1) = 0;
sum = 0;
for jj=1:nt-1
    sum = sum + time_temp(jj);
   time(jj+1) = sum;
end
%% Writing Temperature
% lon (nx), lat (ny), time (nt)
nx = 360;
ny = 180;
nt = nt;
% 3D array of zeros 
oceanTemp = zeros(nx,ny,nt);
months = ["Jan", "Feb", "Mar", "Apr", ...
    "May", "Jun", "Jul", "Aug", "Sept", ...
    "Oct", "Nov", "Dec"];
year_Vec = t_0:t_f;
depth_selection = 100;
% takes me to correct folder 
temp1_dir = strcat('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\Data_SSS_Ocean\Data_SSS_Ocean\Data\2D_Reconstructions_5m-2000m\',...
    num2str(depth_selection),'m\');
% translates selected depth to string
temp2_dir = strcat(num2str(depth_selection),'m');
% need string here 
temp3_dir = '_Reconstructed_Temp_Anomaly_';
% need MonthYr Here 

desiredDir = @(tot_count,current_month,year_count) strcat(temp1_dir,...
    temp2_dir,num2str(tot_count),temp3_dir,months(current_month),...
    num2str(year_Vec(year_count)),'.mat');    
cnt=1;
yr_cnt = 1;
for kk=1:length(year_Vec)
    for jj=1:12
        current_mat = load(desiredDir(cnt,jj,yr_cnt));
        % tranpose so orientation matches GODAS set 
        data = current_mat.M';
        oceanTemp(:,:,cnt) = data;
        cnt=cnt+1;
    end
    yr_cnt=yr_cnt+1;
end
%% Sanity Check
fig = figure;
for jj=1:nt
    imagesc(rot90(oceanTemp(:,:,jj)));
    colorbar;
    caxis([-4,4])
    title_txt = strcat('$t = $','{ }',num2str(jj));
    title(title_txt,'Interpreter','Latex');
    pause(.01)
end
% jj = 720 is odd
figure;
imagesc(rot90(oceanTemp(:,:,720)));
colorbar;
caxis([-4 4])

%% Write nc file
% Check useful colab variables
colab_ncfile = 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\sst.mon.mean.trefadj.anom.1880to2018.nc';
colab_sst = ncread(colab_ncfile,'sst');
colab_time = ncread(colab_ncfile,'time');

% "steal" lon and lat 
lon = ncread(colab_ncfile,'lon');
% comparing lat between colab and OCGM
lat = -ncread(colab_ncfile,'lat');

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

my_ncfile = 'shenData.nc';
nccreate(my_ncfile,'deepTemp','Dimensions',{'lon','lat','time'},'Datatype','single') ;
ncwrite(my_ncfile,'deepTemp',oceanTemp);
