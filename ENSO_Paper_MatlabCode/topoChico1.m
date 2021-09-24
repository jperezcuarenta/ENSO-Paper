%% Download GODAS files
% Notes: 
% Need to have COBE SST already downloaded.
% Output: Single .nc file containing GODAS data set

pwd
txtNC = pwd;

ftobj = ftp('ftp2.psl.noaa.gov');
cd(ftobj,'Datasets/godas');
jj = 1980;
txtLeft = 'pottmp.';
txtRight = '.nc';
while jj < 2020
    txtTemp = num2str(jj);
    InputTxt = strcat(txtLeft,txtTemp,txtRight);
    mget(ftobj,InputTxt);
    jj=jj+1;
end
close(ftobj)

ncFunc = @(kk) strcat(txtNC,'\pottmp.',num2str(kk),'.nc');
Yr_vec = 1980:1:2020;

% Declare final output file title as string 
my_ncfile = 'godasData.nc';

% We take the 1980 GODAS .nc file to understand how the set is structured. 
godas_ncfile = ncFunc(1980);
% Now for the COBE .nc file. 
cobe_ncfile = strcat(txtNC,'\cobeData.nc');

% Read 'lon', 'lat', 'sst' and 'time' variables from COBE file
% as arrays. 
cobe_lon = ncread(cobe_ncfile,'lon');
cobe_lat = ncread(cobe_ncfile,'lat');
cobe_sst = ncread(cobe_ncfile,'sst');
time_temp = ncread(cobe_ncfile,'time');

% Read 'lon', 'lat', 'time', 'level' variables from GODAS file 
% Read longitude 
lon = ncread(godas_ncfile,'lon');
% Read latitude 
lat = ncread(godas_ncfile,'lat');
% Read level 
% If you want to save all depths
% change depthIndices accordingly
level_temp = ncread(godas_ncfile,'level');
depthIndices = 11:21;
level = level_temp(depthIndices);
% Read time 
% The value of 1201 for time_temp is particular to my task so change accordingly
time = time_temp(1201:end);

% Knowing the length of these arrays will soon be useful 
nx = length(lon);
ny = length(lat);
nt = length(time);
nd = length(depthIndices);

% Time 
nccreate(my_ncfile,'time','Dimensions',{'time',1,Inf});
ncwrite(my_ncfile,'time',time);
ncwriteatt(my_ncfile,'time','standard_name','time');
ncwriteatt(my_ncfile,'time','long_name','Time');
ncwriteatt(my_ncfile,'time','units','days since 1891-1-1 00:00:00');
ncwriteatt(my_ncfile,'time','calendar','standard');
ncwriteatt(my_ncfile,'time','axis','T');

% Longitude
nccreate(my_ncfile,'lon','Dimensions',{'lon',1,nx});
ncwrite(my_ncfile,'lon',lon);
ncwriteatt(my_ncfile,'lon','standard_name','longitude');
ncwriteatt(my_ncfile,'lon','long_name','Longitude');
ncwriteatt(my_ncfile,'lon','units','degrees_east');
ncwriteatt(my_ncfile,'lon','axis','X');

% Latitude 
nccreate(my_ncfile,'lat','Dimensions',{'lat',1,ny});
ncwrite(my_ncfile,'lat',lat);
ncwriteatt(my_ncfile,'lat','standard_name','latitude');
ncwriteatt(my_ncfile,'lat','long_name','Latitude');
ncwriteatt(my_ncfile,'lat','units','degrees_north');
ncwriteatt(my_ncfile,'lat','axis','Y');

% Depth 
nccreate(my_ncfile,'level','Dimensions',{'level',1,nd});
ncwrite(my_ncfile,'level',level);

% 4D array of zeros 
kel_seaTemp = zeros(nx,ny,nd,nt);

% For convenience regarding entries in the time dimension 
tempVec = @(jj) [1:12]+12*(jj-1);

% Loop through all depths 
for jj=1:nd
	% Loop through all years (excluding last two)
    for kk = 1:length(Yr_vec)-2
        yr = Yr_vec(kk);
        % read yearly GODAS data 
        godas_ncfile = ncFunc(yr);
        
        % read yearly GODAS temperature data 
        pottmp_current = ncread(godas_ncfile,'pottmp');
        
        % Store 3D array (Nx,Ny,Nt) corresponding to yr
        seaTemp_current = pottmp_current(:,:,depthIndices(jj),:);
        tempvec = tempVec(kk);
        kel_seaTemp(:,:,jj,tempvec) = squeeze(seaTemp_current);
    end
end

% Change missing values to NaN 
kel_seaTemp(kel_seaTemp == -9.969209968386869e+36) = NaN;

% Adjust temperature from Kelvin to Celsius.
cel_seaTemp = convtemp(kel_seaTemp,'K','C');

nccreate(my_ncfile,'deepTemp','Dimensions',{'lon','lat','level','time'},'Datatype','single') ;
ncwrite(my_ncfile,'deepTemp',cel_seaTemp);
ncwriteatt(my_ncfile,'deepTemp','long_name','Monthly Means of Ocean Temperature');
ncwriteatt(my_ncfile,'deepTemp','units','degC');

ncdisp(my_ncfile)