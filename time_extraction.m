% code for extracting frame time into .mat file
% author: wojtek

% Read the log file
filename = 'meas/log/test_0.log';
fileID = fopen(filename, 'r');
if fileID == -1
    error('Cannot open file: %s', filename);
end

% Initialize arrays to store frame numbers, UNIX times, and mission times
frame_numbers = [];
unix_times = [];
mission_times = [];

% Regular expression to match "New frame marker received" lines
pattern = 'New frame marker received for frame (\d+). UNIX time: (\d+)';

% Read the file line by line
while ~feof(fileID)
    line = fgetl(fileID);
    if ischar(line)
        % Try to match the pattern
        tokens = regexp(line, pattern, 'tokens');
        if ~isempty(tokens)
            % Extract frame number and UNIX time
            frame_num = str2double(tokens{1}{1});
            unix_time = str2double(tokens{1}{2});
            
            % Append to arrays
            frame_numbers = [frame_numbers; frame_num];
            unix_times = [unix_times; unix_time];
        end
    end
end

% Close the input file
fclose(fileID);

% Calculate mission time (seconds since frame 0)
if ~isempty(unix_times)
    frame0_time = unix_times(1057); % UNIX time of frame 0
    mission_times = unix_times - frame0_time; % Difference in seconds
else
    error('No valid frame data found in the log file.');
end

% Create the output matrix with three columns
output_matrix = [frame_numbers, unix_times, mission_times];

% Display the first few rows of the output
disp('First few rows of the output (Frame Number, UNIX Time, Mission Time (s)):');
disp(output_matrix(1:min(5, size(output_matrix, 1)), :));

% Save the matrix to a .mat file
save('matlab_processed_files/frame_unix_matrix.mat', 'output_matrix');

% Save the matrix to a .txt file
%txt_filename = 'frame_unix_matrix.txt';
%txt_fileID = fopen(txt_filename, 'w');
%if txt_fileID == -1
    %error('Cannot create output text file: %s', txt_filename);
%end

% Write header
%fprintf(txt_fileID, 'Frame_Number\tUNIX_Time\tMission_Time_s\n');

% Write data
%for i = 1:size(output_matrix, 1)
    %fprintf(txt_fileID, '%d\t%d\t%.0f\n', output_matrix(i, 1), output_matrix(i, 2), output_matrix(i, 3));
%end

% Close the text file
%fclose(txt_fileID);

%disp(['Output matrix saved as ', txt_filename]);

% Note: The matrix is accessible as output_matrix
% Column 1: Frame Number
% Column 2: UNIX Time
% Column 3: Mission Time (seconds since frame 0)
% Output is saved as 'frame_unix_matrix.mat' and 'frame_unix_matrix.txt'