% example code for creating an image

clc; clear; close all;

test = load('basic_data_process/totMaps_8001_10000.mat');
hits = load("basic_data_process\hits_in_frames.mat")
figure
subplot(1,2,1)
i = 8527;
ttl = sprintf('Frame: %d', i-1);
frame_name = sprintf('totMap_%d', i);
A = log10(test.(frame_name));
A(~isfinite(A)) = 0; 
clim = [min(A(:)), max(A(:))]; 
imagesc(log10(test.(frame_name)), clim); 

axis image;             % avoid distortion
axis xy;                % y increases upward
colorbar; 
colormap("jet")
title(ttl)

% Step 1: Binary mask of events
mask = A > 0;

% Step 2: Label connected components (8-connected)
L = bwlabel(mask, 8);

% Step 3: Count how many pixels in each component
stats = regionprops(L, 'Area');

% Step 4: Keep only components with more than 1 pixel
areaArray = [stats.Area];
keepLabels = find(areaArray > 1);

% Step 5: Create a mask for only multi-pixel components
filteredMask = ismember(L, keepLabels);

% Step 6: Apply to original data
filteredA = A .* filteredMask;


subplot(1,2,2)

imagesc(filteredA, clim); 
axis image;             % avoid distortion
axis xy;                % y increases upward
colorbar; 
title('Frame filtered')
colormap("jet")
drawnow()
pause(0.1)

%plot(hits.hits_in_time)

