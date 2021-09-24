%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s):
% Name                                  | Type
% nino34.long.anom.data                 | txt
%
% Output(s):
% anomaly_history                       | eps
% anomaly_history                       | png
%
% Requirements:
% ExportFig.m added to directory 
%
% Code Description: 
% This program reads yearly Nino3.4 anomalies and plots a time series
% with extraordinary positive values shaded in red (greater than 1.5) and 
% extraordinary negative values shaded in blue (less than 1.5)
%
% Labeled as Figures 1 in ENSO paper.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Begin Code
close all 
clear all

file_name = 'nino34.long.anom.data.txt';
f = fopen(file_name,'r');
formatSpec = '%f';
yr_len = 2018-1870+1;
sizeA = [13 yr_len];
A = fscanf(f,formatSpec,sizeA);
fclose(f);

% Transpose to write as year (rows) by anomaly value (columns)
A_transpose = A';
% Get rid of first column which represents year
% Also, get rid of first 30 years for initial year to be 1900

% (1,1870), (2,1871) -> (a,1900) -> a = 27
% year (rows) by anomaly value (columns)
anomalies = A_transpose(31:end,2:end);
%anomalies_row_vec = reshape(anomalies',[1 12*yr_len]);
anomalies_row_vec = reshape(anomalies',[1 1428]);

% Plot
gc1 = figure('WindowState','maximized');
startDate = datenum('01-01-1900');
endDate = datenum('12-31-2018');
xData = linspace(startDate,endDate,1428);
plot(xData,anomalies_row_vec,'LineWidth',1.5);
datetick('x','yyyy','keeplimits');
xlim([startDate endDate])
xlabel('Time','Interpreter','Latex');
ylabel('Nino 3.4 Anomaly','Interpreter','Latex');
title('Temperature Anomaly Time Series (Nino 3.4 Region)',...
    'Interpreter','Latex','FontSize',24);
grid on
hold on
% Using (+1.5)/(-1.5) since anomalies greater/lower define strong ENSO
fill(xData,max(anomalies_row_vec,1.5), 'r');
fill(xData,min(anomalies_row_vec,-1.5), 'b');
hold off

% save fig commands
set(gc1,'Color','w');
% title of image 
img_title = 'AnomalyHistory';
par_dir = strcat('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\ENSO_Paper_Figures\',img_title);
export_fig(par_dir,'-eps');
export_fig(par_dir,'-png');

% curiosity
% [p,f] = pspectrum(anomalies_row_vec);
% plot(f/pi,abs(p))
% End Code