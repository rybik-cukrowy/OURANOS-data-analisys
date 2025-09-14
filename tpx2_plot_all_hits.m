% creating plot for the number of hits
clc; clear all; close all;

% read altitude data
M = readmatrix('altitude_in_time.xlsx');
excelTime = M(:,1);
altitude = M(:,2);

time_excel = datetime(excelTime, 'ConvertFrom','excel'); % excel serial to datetime

% remove zesrane rows (for some fucking reason matlab is cursed)
valid_id = time_excel > datetime(2000,1,1);
time_excel = time_excel(valid_id);
altitude = altitude(valid_id);

% load frame timing unix
frame_timing = load('matlab_processed_files/frame_unix_matrix.mat'); % file processed by time_extraction.m
frame_unix_matrix = frame_timing.output_matrix;
frame_num = frame_unix_matrix(:,1);
unix_time = frame_unix_matrix(:,2);
frame_time_unix = datetime(unix_time, 'ConvertFrom','posixtime');

% load hits - file processed by timepix_fixed.m
hits = load("matlab_processed_files/hits_matrix.mat"); % hits_original, hits_filtered, hits_difference

% plot original altitude and hits
figure;
yyaxis right
plot(frame_time_unix(1:length(hits.hits_original)), hits.hits_original, '-m'); hold on 
plot(frame_time_unix(1:length(hits.hits_filtered)), hits.hits_filtered, '-g'); hold on
plot(frame_time_unix(1:length(hits.hits_difference)), hits.hits_difference, '-c');
ylabel('hits');
ax = gca;
ax.YColor = 'white';

yyaxis left
plot(time_excel, altitude, 'r', 'LineWidth',2);
ylabel('altitude');
ax.YColor = 'white';

xlabel('time [UTC]');
grid on;
title('Altitude and hits');
legend('altitude','all hits', 'filtered hits','one pixel hits');

% compressing hits to match altitude sampling 10s vs 1s for frames (not every frame tho)

% Preallocate compressed hits
hits_compressed = zeros(length(altitude),3);

% Convert altitude timestamps to numeric for easier comparison
time_excel_num = posixtime(time_excel);      % seconds since 1970
frame_time_num = posixtime(frame_time_unix); % seconds since 1970

for i = 1:length(altitude)
    if i == 1
        t_start = frame_time_num(1);  % start at first frame time
    else
        t_start = time_excel_num(i-1);
    end
    t_end = time_excel_num(i);
    
    % frames in time interval
    idx = frame_time_num > t_start & frame_time_num <= t_end;
    
    hits_compressed(i,1) = sum(hits.hits_original(idx));
    hits_compressed(i,2) = sum(hits.hits_filtered(idx));
    hits_compressed(i,3) = sum(hits.hits_difference(idx));
end

figure;
plot(altitude, hits_compressed(:,1), '.m'); hold on
plot(altitude, hits_compressed(:,2), '.g'); hold on
plot(altitude, hits_compressed(:,3), '.c');
xlabel('altitude [m]');
ylabel('number of hits (10-second bins)');
grid on;
title('hits in altitude');
legend('hits unfiltered', 'filtered hits', 'one-pixel hits');

% temp and one pixel events

temp = load("matlab_processed_files\frame_unix_temp_matrix.mat")

figure

yyaxis right
plot(frame_time_unix(1:length(hits.hits_difference)), hits.hits_difference, '-c');
hold on
plot(time_excel, altitude/200, '-r', 'LineWidth',2);
ax = gca;
ax.YColor = 'white';
ylabel('one-pixel hits')
hold on

yyaxis left
plot(datetime(temp.dataMatrix(:,2), 'ConvertFrom','posixtime'),temp.dataMatrix(:,3), 'y', 'LineWidth',2);
hold on
ax = gca;
ax.YColor = 'white';
title('one-pixel events and HW temp')
ylabel('temperature [°C]')

xlabel('time [UTC]')
legend('HW temp','one pixel event number','altitude')
grid on