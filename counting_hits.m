% code that turns image matrixes into summed hits

clc; clear; close all;

hits_filtered = zeros(1, 12000); 

for batch = 1:6
    batch_start = (batch - 1) * 2000 + 1;
    batch_end = batch_start + 1999;
    variable_name = sprintf('test%d', batch);
    file_path = sprintf('basic_data_process/totMaps_%d_%d.mat', batch_start, batch_end);
    fprintf('Loading batch %d (%s)...\n', batch, file_path);
    data = load(file_path);

    for j = batch_start:batch_end
        frame_name = sprintf('totMap_%d', j);
        A = log10(data.(frame_name));
        mask = A > 0;
        L = bwlabel(mask, 8);
        stats = regionprops(L, 'Area');
        areaArray = [stats.Area];
        keepLabels = find(areaArray > 1);
        filteredMask = ismember(L, keepLabels);
        filteredA = A .* filteredMask;

        L2 = bwlabel(filteredA > 0, 8);
        stats2 = regionprops(L2, 'Area');
        areaArray2 = [stats2.Area];
        hits_filtered(j) = sum(areaArray2);
    end
    clear data % Release memory
    fprintf('Finished batch %d.\n', batch);
end
fprintf('All batches processed.\n');
hits = load("basic_data_process\hits_in_frames.mat");
fprintf('Plotting plots...\n');

plot(hits.hits_in_time, 'm');
hold on
plot(hits_filtered, 'g');
hold on
hits_difference = double(hits.hits_in_time(1:12000)) - hits_filtered;
plot(hits_difference, 'c');
fprintf('done\n');

legend('hits unfiltered', 'one-pixel events filtered', 'pixels yeeted')

hits_original = double(hits.hits_in_time(1:12000));
save('matlab_processed_files\hits_matrix.mat', 'hits_original', 'hits_filtered', 'hits_difference');