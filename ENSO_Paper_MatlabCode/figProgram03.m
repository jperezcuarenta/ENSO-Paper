%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s):
% Name                                  | Type
% case_num                              | int (1 to 3)
%
% Output(s):
% Nino3.4 anomaly region                | eps
% Nino3.4 anomaly region                | png
%
% Requirements:
%  
%
% Code Description: 
% This script prints several images 
% of true ENSO versus ML predictions.
% Case Surface vs Surface
% Input: depth = 5m, lead time: 1 month, 3 month, 6 month, 9 month
% Target: 3.4 Region
% Case Deep Ocean -> Surface: 
% Input: depth = 115m, lead time: 1 month, 3 month, 6 month, 9 month
% Target: 3.4 Region
% Case Deep Ocean -> Deep Ocean
% Input: depth = 115m, lead time: 1 month, 3 month, 6 month, 9 month
% Target: Shifted 3.4 Region in Deep Ocean
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all

for mm=1:3
    predictionValidation(mm)
end

function predictionValidation(case_num)
    Cases = ["SurfaceWithSurface","SubsurfaceWithSurface",...
        "SubsurfaceWithSubsurface"];

      startDate_vec = [datenum('02-01-1997'), datenum('04-01-1997'), ...
          datenum('07-01-1997'), datenum('10-01-1997')];

      endDate_vec = [datenum('02-01-2007'), datenum('04-01-2007'), ...
          datenum('07-01-2007'), datenum('10-01-2007')];

    % this will control which case to consider
    option = Cases(case_num);

    % Global Values
    static_txt = strcat(pwd,"\ENSO_Paper_Data\");
    temp_txt1 = "Predictions_";
    temp_txt2 = "meters_";
    temp_txt3 = "month_";
    temp_txt4 = "SurfaceTarget.csv";
    temp_txt5 = "SubsurfaceTarget.csv";

    fetch_surface_name = @(meter,month) strcat(static_txt,temp_txt1,num2str(meter),...
        temp_txt2,num2str(month),temp_txt3,temp_txt4);
    fetch_subsurface_name = @(meter,month) strcat(static_txt,temp_txt1,num2str(meter),...
        temp_txt2,num2str(month),temp_txt3,temp_txt5);

    lead_vec = [1 3 6 9];

    %%%%%%%%%%%%%% Case 1 %%%%%%%%%%%%%%%
    if option == Cases(1)
        for jj = 1:length(lead_vec)
            % selected lead time 
            lead_time = lead_vec(jj);

            % selected file (change)
            file_name = fetch_surface_name(5,lead_time);

            % anomalies
            A = readmatrix(file_name);

            % y values (true vs prediction)
            y_val = A(1,:);
            y_predicted = A(2,:);

            % x-axis 
            startDate = startDate_vec(jj);
            endDate = endDate_vec(jj);
            xData = linspace(startDate,endDate,120);        

            % plot here
            fgh = figure; % extend horizontally
            fgh.Position = [488 342 2*560 420]
            grid on
            plot(xData,y_val,'b','LineWidth',1.5);
            datetick('x','yyyy','keeplimits');
            xlim([startDate endDate])
            hold on
            plot(xData,y_predicted,'r','LineWidth',1.5)
            hold off
            xlabel('Time','Interpreter','Latex');

            % change
            ylabel('Nino 3.4 Anomaly','Interpreter','Latex');

            legend('Validation','Prediction'); 

            % change
            title_text1 = 'Surface Data Predicting Nino 3.4 Anomaly at';

            title_text2= strcat(title_text1,'{ }',num2str(lead_time),'{ }','Month Lead Time');
            title(title_text2,'Interpreter','Latex');
            
            % save fig 
            fig_title = [];
            set(fgh,'Color','w');
            % title of image 
            img_title1 = 'Prediction_Case01_';
            img_title2 = strcat(img_title1,num2str(lead_time),'Lead');
            par_dir = strcat('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\ENSO_Paper_Figures\',img_title2);
            export_fig(par_dir,'-eps');
            export_fig(par_dir,'-png');
            
            close(fgh)
        end

        
        
%%%%%%%%%%%%%% Case 2 %%%%%%%%%%%%%%%
    elseif option == Cases(2)
        for jj = 1:length(lead_vec)
            % selected lead time 
            lead_time = lead_vec(jj);

            % selected file (change)
            file_name = fetch_surface_name(115,lead_time);

            % anomalies
            A = readmatrix(file_name);

            % y values (true vs prediction)
            y_val = A(1,:);
            y_predicted = A(2,:);

            % x-axis 
            startDate = startDate_vec(jj);
            endDate = endDate_vec(jj);
            xData = linspace(startDate,endDate,120);        

            % plot here
            fgh = figure;
            fgh.Position = [488 342 2*560 420]
            grid on
            plot(xData,y_val,'b','LineWidth',1.5);
            datetick('x','yyyy','keeplimits');
            xlim([startDate endDate])
            hold on
            plot(xData,y_predicted,'r','LineWidth',1.5)
            hold off
            xlabel('Time','Interpreter','Latex');

            % change
            ylabel('Nino 3.4 Anomaly','Interpreter','Latex');

            legend('Validation','Prediction'); 

            % change
            title_text1 = 'Deep Ocean Data Predicting Nino 3.4 Anomaly at';

            title_text2= strcat(title_text1,'{ }',num2str(lead_time),'{ }','Month Lead Time');
            title(title_text2,'Interpreter','Latex');
            
            % save fig 
            fig_title = [];
            set(fgh,'Color','w');
            % title of image 
            img_title1 = 'Prediction_Case02_';
            img_title2 = strcat(img_title1,num2str(lead_time),'Lead');
            par_dir = strcat('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\ENSO_Paper_Figures\',img_title2);
            export_fig(par_dir,'-eps');
            export_fig(par_dir,'-png');
            
            close(fgh)
        end
        
    %%%%%%%%%%%%%% Case 3 %%%%%%%%%%%%%%%
    elseif option == Cases(3)
        for jj = 1:length(lead_vec)
            % selected lead time 
            lead_time = lead_vec(jj);

            % selected file (change)
            file_name = fetch_subsurface_name(115,lead_time);

            % anomalies
            A = readmatrix(file_name);

            % y values (true vs prediction)
            y_val = A(1,:);
            y_predicted = A(2,:);

            % x-axis 
            startDate = startDate_vec(jj);
            endDate = endDate_vec(jj);
            xData = linspace(startDate,endDate,120);        

            % plot here
            fgh = figure;
            fgh.Position = [488 342 2*560 420]
            grid on
            plot(xData,y_val,'b','LineWidth',1.5);
            datetick('x','yyyy','keeplimits');
            xlim([startDate endDate])
            hold on
            plot(xData,y_predicted,'r','LineWidth',1.5)
            hold off
            xlabel('Time','Interpreter','Latex');

            % change
            ylabel('Deep Ocean Anomaly','Interpreter','Latex');

            legend('Validation','Prediction'); 

            % change
            title_text1 = 'Deep Ocean Data Predicting Deep Ocean Anomaly at';

            title_text2= strcat(title_text1,'{ }',num2str(lead_time),'{ }','Month Lead Time');
            title(title_text2,'Interpreter','Latex');
            
            % save fig 
            fig_title = [];
            set(fgh,'Color','w');
            % title of image 
            img_title1 = 'Prediction_Case03_';
            img_title2 = strcat(img_title1,num2str(lead_time),'Lead');
            par_dir = strcat('C:\Users\Jesus Perez Cuarenta\Documents\MATLAB\NOAA Fellowship\ENSO_Paper_Figures\',img_title2);
            export_fig(par_dir,'-eps');
            export_fig(par_dir,'-png');

            close(fgh)
        end
    end
end
