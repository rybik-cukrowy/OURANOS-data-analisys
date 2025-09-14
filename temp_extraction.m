% extracting the temperature of the timepix sensor and saving as .mat array

clc; clear all; close all;

% File path
logFile = 'meas/log/test_0.log';

% Open the file
fid = fopen(logFile, 'r');
if fid == -1
    error('Could not open log file.');
end

% Initialize storage
frames = [];
times = [];
hwTemps = [];
chipTemps = [];

% Read line by line
while ~feof(fid)
    line = fgetl(fid);
    if ischar(line)
        % Look for frame number and UNIX time
        frameMatch = regexp(line, 'New frame marker received for frame (\d+)\. UNIX time: (\d+)', 'tokens');
        if ~isempty(frameMatch)
            frameNum = str2double(frameMatch{1}{1});
            unixTime = str2double(frameMatch{1}{2});
            
            % Read ahead until we find the temperature line
            tempLine = fgetl(fid);
            while ischar(tempLine) && isempty(regexp(tempLine, 'TEMP\.: HW', 'once'))
                tempLine = fgetl(fid);
            end
            
            % Extract temperatures if found
            tempMatch = regexp(tempLine, 'TEMP\.\: HW :([\d\.]+)\. Chip: ([\d\.]+)', 'tokens');
            if ~isempty(tempMatch)
                hwTemp = str2double(tempMatch{1}{1});
                chipTemp = str2double(tempMatch{1}{2});
                
                % Store data
                frames(end+1) = frameNum; %#ok<SAGROW>
                times(end+1) = unixTime; %#ok<SAGROW>
                hwTemps(end+1) = hwTemp; %#ok<SAGROW>
                chipTemps(end+1) = chipTemp; %#ok<SAGROW>
            end
        end
    end
end
fclose(fid);

% Convert to UTC datetime
utcTimes = datetime(times, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');

% Combine into matrix [Frame, UNIX Time, HW Temp, Chip Temp]
dataMatrix = [frames(:), times(:), hwTemps(:), chipTemps(:)];

% Plot
figure;
plot(utcTimes, hwTemps, 'm');
hold on;
plot(utcTimes, chipTemps, 'g');
hold off;
xlabel('time [UTC]');
ylabel('temperature [°C]');
title('temps in time');
legend('HW', 'CHIP');
grid on;

% Display first few rows of data
disp('Extracted Data (Frame | UNIX Time | HW Temp | Chip Temp):');
disp(dataMatrix(1:min(5,end), :));

save('matlab_processed_files/frame_unix_temp_matrix.mat', 'dataMatrix');
% frame num | unix time | HW temp | chip temp