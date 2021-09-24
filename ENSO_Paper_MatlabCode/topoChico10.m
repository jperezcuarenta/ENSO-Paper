% Modified topoChico4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
% OGCM_1x1 Files -- monthly global temp anomalies in
% .mat format
%
% Outputs:
% Rearranged monthly global temp anomaly in NC file format
% 
% Notes:
% We want to explore if deep ocean temp
% is a useful predictor for SST anomalies
% Eventually, I want to control depth
% 100m, 150m, 200m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read colab data and study time vector 
% to see values after 1880-01-01 (or w/e time is)
t_0 = 1950; t_f = 2012;
nt = 12*(t_f-t_0+1);

% t = [];
% t_new = t_0;
% cnt = 1;
% for jj=1:(t_f-t_0+1)
%     for kk=1:12
%         t = [t, datetime(t_new,kk,1)];
%     end
%     t_new = t_new+1;
% end
% time_calendarDate = caldiff(t,'days')';
% % days after 1950-01-01
% time_temp = split(time_calendarDate,'days');
% time = zeros(nt,1);
% time(1) = 0;
% sum = 0;
% for jj=1:nt-1
%     sum = sum + time_temp(jj);
%    time(jj+1) = sum;
% end

% Writing Temperature
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

%%%%%%%%%%%%%%%%%%%% Can introduce loop here %%%%%%%%%%%%%%%%%%%% 

% missing date for depth of 200: Jul 1950
depth_Options = [100, 150];

for jj=1:length(depth_Options)
    depth_selection = depth_Options(jj);

    % takes me to correct folder 
    temp1_dir = strcat('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\OGCM Files\OGCM Monthly Anomalies\Data\2D_Reconstructions_5m-2000m\',...
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

    % 270 deg rot
    rot_270 = @(x) rot90(rot90(rot90(x)));

    for kk=1:length(year_Vec)
        for jj=1:12
            current_mat = load(desiredDir(cnt,jj,yr_cnt));
            data = current_mat.M;
            data = rot_270(data);
            % rotate to match COBE for whatever reason
            oceanTemp(:,:,cnt) = data;
            cnt=cnt+1;
        end
        yr_cnt=yr_cnt+1;
    end

    %%%%%%%%%%%%%%%%%% Write nc file
    % Check useful colab variables
    colab_ncfile = 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\sst.mon.mean.trefadj.anom.1880to2018.nc';
    colab_sst = ncread(colab_ncfile,'sst');
    colab_time = ncread(colab_ncfile,'time');
    yr_begin_index = 841;
    yr_end_index = 841+12*63-1;
    % BEGIN colab_time(841) days after Jan 1 1891
    % this corresponds to Jan 15 1950 
    time = colab_time(yr_begin_index:yr_end_index);

    % "steal" lon and lat 
    lon = ncread(colab_ncfile,'lon');
    % comparing lat between colab and OCGM
    lat = ncread(colab_ncfile,'lat');
    
    my_ncfile = strcat('OGCM_',num2str(depth_selection),'meters_depth_global_anomalies.nc');

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

    % update string title for NC file 
%    my_ncfile = 'shenData.nc';
    nccreate(my_ncfile,'deepTemp','Dimensions',{'lon','lat','time'},'Datatype','single') ;
    ncwrite(my_ncfile,'deepTemp',oceanTemp);
end