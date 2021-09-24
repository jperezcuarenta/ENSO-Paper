%% Example That Works 
close all

colormap = jet;
load mristack
figure; volshow(mristack,'Colormap',colormap);
L = imsegkmeans3(mristack,2);
figure; volshow(L,'Colormap',colormap);


%% Example -- doesn't work since this is not reading 
% anomaly data, it is reading monthly temperature 
% Segmentate volume from OGCM
% Need to access all mat files and store as array 

yr_1 = 1950;

months = ["Jan", "Feb", "Mar", "Apr", ...
    "May", "Jun", "Jul", "Aug", "Sep", ...
    "Oct", "Nov", "Dec"];

% Possible meter selection:
% 0, 10, 20, 30, 50, 75, 100, 125, 150, 200
% In indices choose 1:10
depth_selection = 1:10;

% read NC file 
curr_dir = pwd;
dir1 = strcat(pwd,'\OGCM_1x1\');

% cnt can be any discrete value in [122,769];
dir2 = @(cnt) num2str(cnt);

% month_cnt can be any discrete value in [1,12] depending on month
dir3 = @(month_cnt) strcat('_',months(month_cnt),'_');

dir4 = @(year_cnt) strcat(num2str(year_cnt),'_5m-5500m_1x1.mat');

final_dir = @(x,y,z) strcat(dir1,dir2(x),dir3(y),dir4(z));

% x is cnt, y is month_cnt, z is year_cnr
x0 = 122; x_current = x0;
y0 = 1; y_current = y0;
z0 = 1950; z_current = z0;
% total amount of files: 769-122+1 = 648
% 12 iterations each year so: 648/12 = 54

%temperature_matrix = zeros(360,180,

for jj=1:54
    for kk=1:12
        final_dir(x_current,y_current,z_current)
        % update file cnt every iteration
        x_current = x_current+1;
        % update month count every iteration
        y_current = y_current+1;
    end
    % reset month count every 12 iterations
    y_current = 1;
    % update year count every 12 iterations 
    z_current = z_current+1;
end

%% this is the right one 
% but need help with memory issues !!!! 


%https://serc.carleton.edu/NAGTWorkshops/ocean/visualizations/elnino_lanina.html

% lon (nx), lat (ny), time (nt)
nx = 360;
ny = 180;
t_0 = 1950; t_f = 2012;
year_Vec = t_0:t_f;
 
nt = 12*(t_f-t_0+1);
% cant use 200 m depth 
%depth_selection_vec = [10,20,30,50,75,100,125,150,200];
depth_selection_vec = [10,20,30,50,75,100,125,150];
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

% entries at 200 meter depth are missing 

why_am_I_here = 1;
for mm = 1:length(depth_selection_vec)
	depth_selection = depth_selection_vec(mm);
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
    for kk=1:length(year_Vec)
        for jj=1:12
%            if desiredDir(cnt,jj,yr_cnt) == 'C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\OGCM Files\OGCM Monthly Anomalies\Data\2D_Reconstructions_5m-2000m\200m\200m7_Reconstructed_Temp_Anomaly_Jul1950.mat'
%                cnt = cnt+1;
%                why_am_I_here = why_am_I_here + 1;
%                break
%            end
            current_mat_struct = load(desiredDir(cnt,jj,yr_cnt));
            current_mat = current_mat_struct.M;
            current_mat_rotated = rotate_image(current_mat);
            oceanTemp(mm,:,:,why_am_I_here) = current_mat_rotated(lon_slice,lat_slice);
            % if graphing, do
            % imagesc(current_mat_rotated(lon_slice,lat_slice)); 
            % xlabel('lat'); ylabel('lon');
            cnt=cnt+1;
            why_am_I_here = why_am_I_here + 1;
        end
        yr_cnt=yr_cnt+1;    
    end
end

% dimensions of oceanTemp are depth x lon x lat x time
% no need to convert temperature in OGCM since it is in Celsius already 

%% graphing above block 
colormap = jet;
oceanPerm = permute(oceanTemp,[2 3 1 4]);
ocean_func = @(t) oceanPerm(:,:,:,t);

figure; volshow(floor(ocean_func(1)),'Colormap',colormap);
L = imsegkmeans3(floor(ocean_func(1)),2);
figure; volshow(L,'Colormap',colormap);

%figure; volshow('Colormap',colormap);
%L = imsegkmeans3(mristack,2);
%figure; volshow(L,'Colormap',colormap);


%% consider erasing this, look at permute function, save MAT file 
% from above

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
    temp_seaTemp = convtemp(temperature_matrix,'K','C');
    cnt = cnt+1;
end


%% If success is achieved then we can write txt file,
% no need to write NC file