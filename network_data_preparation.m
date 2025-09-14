% code preparing the data for network training
clc; clear; close all;

% let's try everything for a random frame
data = load('matlab_processed_files/filtered_totMaps_4001_6000.mat');
i = 4424;
frame_name = sprintf('filtered_totMap_%d', i);
A = log10(data.(frame_name));
imagesc(A); 
axis image;             % avoid distortion
axis xy;                % y increases upward
colorbar; 
colormap("jet")
hold on

% extracting the regionprops (event's properties)
mask = A>0;
L = bwlabel(mask, 8);
stats = regionprops(L, 'All');

for k = 1:length(stats)
    rectangle('Position', stats(k).BoundingBox, 'EdgeColor', 'magenta', 'LineWidth', 1.5);
    hold on
end