% code that turns image matrixes into filtered image matrixes
clc; clear; close all;
clc; clear; close all;

for batch = 1:6 % going through files
    batch_start = (batch - 1) * 2000 + 1;
    batch_end = batch_start + 1999;
    file_path = sprintf('basic_data_process/totMaps_%d_%d.mat', batch_start, batch_end); % files from running .py code
    fprintf('Loading batch %d (%s)...\n', batch, file_path);
    data = load(file_path);

    filtered_totMap = struct();
    fprintf('Filtering batch %d (%s)...\n', batch, file_path);
    for j = batch_start:batch_end % going through matrixes
        frame_name = sprintf('totMap_%d', j); 
        A = data.(frame_name);
        
        % filtering
        mask = A > 0;
        L = bwlabel(mask, 8);
        stats = regionprops(L, 'Area');
        areaArray = [stats.Area];
        keepLabels = find(areaArray > 1);
        filteredMask = ismember(L, keepLabels);
        filteredA = A .* filteredMask;
        
        frame_name = sprintf('filtered_totMap_%d', j);
        % save filtered frame into struct
        filtered_totMap.(frame_name) = filteredA;
    end

    % save filtered struct as .mat
    save_name = sprintf('matlab_processed_files/filtered_totMaps_%d_%d.mat', batch_start, batch_end);
    save(save_name, '-struct', 'filtered_totMap');
    
    clear data filtered_totMap % Release memory
    fprintf('Finished batch %d.\n', batch);
end

fprintf('All batches processed.\n');