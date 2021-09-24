close all 
% begin global variables
mrk_sz = 30;
l_width = 1;
figure_title_Vec = {'Nino34_Corr', ...
    'Nino34_RMSE',...
    '115m_Corr',...
    '115m_RMSE'};

caz = -85.9724;
cel = 9.4974;
% end global variables

% Niño 3.4 Region Anomalies
corr_name = strcat(pwd,'\Enso_Paper_Data\','corr_SSTA.csv');
rmse_name = strcat(pwd,'\Enso_Paper_Data\','rmse_SSTA.csv');

depth_vec = 5:10:195;
%month_vec = [1, 3, 6, 9, 12, 15, 18];
month_vec = 1:12;

len_d = length(depth_vec);
len_m = length(month_vec);

[DD,MM] = meshgrid(depth_vec,month_vec);

% months by depth
corr_mat = csvread(corr_name);
rmse_mat = csvread(rmse_name);

%gc1 = figure('WindowState','maximized');
gc1 = figure;
gc1.Position = [27.4, 34.18, 1451.2, 420];
scatter3(DD(:),MM(:),corr_mat(:),mrk_sz,corr_mat(:), 'filled');
colorbar;
grid on
xlabel('Depth Level (meters)','Interpreter','Latex');
ylabel('Month Lead (months)','Interpreter','Latex');
zlabel('Correlation','Interpreter','Latex');
title('Correlation for Nino 3.4 Region','Interpreter','Latex','FontSize',14);
hold on
for mm = 1:len_m
    plot3(depth_vec,[0*depth_vec]+month_vec(mm),corr_mat(mm,:),'-k','LineWidth',1);
end
hold off
view(caz,cel)
set(gc1,'Color','w');
current_text = figure_title_Vec(1);
export_fig(string(current_text),'-eps');
export_fig(string(current_text),'-png');

%gc2 = figure('WindowState','maximized');
gc2 = figure;
gc2.Position = [27.4, 34.18, 1451.2, 420];
scatter3(DD(:),MM(:),rmse_mat(:),mrk_sz,rmse_mat(:), 'filled');
colorbar;
grid on
xlabel('Depth Level (meters)','Interpreter','Latex');
ylabel('Month Lead (months)','Interpreter','Latex');
zlabel('RMSE','Interpreter','Latex');
title('RMSE for Nino 3.4 Region','Interpreter','Latex','FontSize',14);
hold on
for mm = 1:len_m
    plot3(depth_vec,[0*depth_vec]+month_vec(mm),rmse_mat(mm,:),'-k','LineWidth',1);
end
hold off
view(caz,cel)
set(gc2,'Color','w');
current_text = figure_title_Vec(2);
export_fig(string(current_text),'-eps');
export_fig(string(current_text),'-png');


% Niño 3.4 Region Anomalies
corr_name = strcat(pwd,'\Enso_Paper_Data\','corr_SSTA.csv');
rmse_name = strcat(pwd,'\Enso_Paper_Data\','rmse_SSTA.csv');

% 115m Anomalies
%corr_name1 = 'corr_115m Anomalies.csv';
corr_name1 = strcat(pwd,'\Enso_Paper_Data\','corr_115m Anomalies.csv');
%rmse_name1 = 'rmse_115m Anomalies.csv';
rmse_name1 = strcat(pwd,'\Enso_Paper_Data\','rmse_115m Anomalies.csv'); 
corr_mat1 = csvread(corr_name1);
rmse_mat1 = csvread(rmse_name1);

%gc3 = figure('WindowState','maximized');
gc3 = figure;
gc3.Position = [27.4, 34.18, 1451.2, 420];
scatter3(DD(:),MM(:),corr_mat1(:),mrk_sz,corr_mat1(:), 'filled');
colorbar;
grid on
xlabel('Depth Level (meters)','Interpreter','Latex');
ylabel('Month Lead (months)','Interpreter','Latex');
zlabel('Correlation','Interpreter','Latex');
title('Correlation for 115 m Region','Interpreter','Latex','FontSize',14);
hold on
for mm = 1:len_m
    plot3(depth_vec,[0*depth_vec]+month_vec(mm),corr_mat1(mm,:),'-k','LineWidth',1);
end
hold off
view(caz,cel)
set(gc3,'Color','w');
current_text = figure_title_Vec(3);
export_fig(string(current_text),'-eps');
export_fig(string(current_text),'-png');


%gc4 = figure('WindowState','maximized');
gc4 = figure;
gc4.Position = [27.4, 34.18, 1451.2, 420];
scatter3(DD(:),MM(:),rmse_mat1(:),mrk_sz,rmse_mat1(:), 'filled');
colorbar;
grid on
xlabel('Depth Level (meters)','Interpreter','Latex');
ylabel('Month Lead (months)','Interpreter','Latex');
zlabel('RMSE','Interpreter','Latex');
title('RMSE for 115 m Region','Interpreter','Latex','FontSize',14);
hold on
for mm = 1:len_m
    plot3(depth_vec,[0*depth_vec]+month_vec(mm),rmse_mat1(mm,:),'-k','LineWidth',1);
end
hold off
view(caz,cel)
set(gc4,'Color','w');
current_text = figure_title_Vec(4);
export_fig(string(current_text),'-eps');
export_fig(string(current_text),'-png');
hold off