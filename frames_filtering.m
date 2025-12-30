clc; clear; close all;

prevSinglePixelMask = [];
prevFrameSize = [];
noisyPixelCounts = []; % array to store number of noisy pixels per frame

numBatches = 6; % adjust to your number of files

for batch = 1:numBatches
    batch_start = (batch - 1) * 2000 + 1;
    batch_end = batch_start + 1999;
    file_path = sprintf('basic_data_process/totMaps_%d_%d.mat', batch_start, batch_end);
    fprintf('Loading batch %d (%s)...\n', batch, file_path);
    data = load(file_path);

    filtered_totMap = struct();
    fprintf('Filtering batch %d (%s)...\n', batch, file_path);

    for j = batch_start:batch_end
        frame_name = sprintf('totMap_%d', j);
        A = data.(frame_name);

        % take log10 and handle -Inf/NaN
        A_log = log10(A);
        A_log(~isfinite(A_log)) = 0;

        % initialize persistence mask for first frame
        if isempty(prevSinglePixelMask)
            prevSinglePixelMask = false(size(A_log));
            prevFrameSize = size(A_log);
        end

        % check frame size consistency
        if ~isequal(size(A_log), prevFrameSize)
            prevSinglePixelMask = false(size(A_log));
            prevFrameSize = size(A_log);
        end

        %% --- find connected components ---
        mask = A_log > 0;
        L = bwlabel(mask, 8);
        stats = regionprops(L, 'Area');
        areaArray = [stats.Area];

        % single-pixel components only
        singleLabels = find(areaArray == 1);
        singlePixelMask = ismember(L, singleLabels);

        % --- persistent noise: pixels that appear in same spot as previous frame ---
        noisyPixelMask = singlePixelMask & prevSinglePixelMask;

        % --- count noisy pixels ---
        noisyPixelCounts(end+1) = nnz(noisyPixelMask);

        % --- filter only noisy pixels, preserve everything else ---
        filteredA = A;
        filteredA(noisyPixelMask) = 0;

        % --- save filtered frame ---
        filtered_frame_name = sprintf('filtered_totMap_%d', j);
        filtered_totMap.(filtered_frame_name) = filteredA;

        % --- update persistence mask for next frame ---
        prevSinglePixelMask = singlePixelMask;
    end

    % save filtered struct as .mat
    save_name = sprintf('matlab_processed_files/filtered_totMaps_%d_%d.mat', batch_start, batch_end);
    save(save_name, '-struct', 'filtered_totMap');

    clear data filtered_totMap
    fprintf('Finished batch %d.\n', batch);
end

% save noisy pixel counts for all frames
save('matlab_processed_files/noisyPixelCounts.mat', 'noisyPixelCounts');
plot(noisyPixelCounts, 'gp')
fprintf('All batches processed.\n');
