% example code for data visualisation

clc; clear; close all;

test = load('matlab_processed_files/filtered_totMaps_6001_8000.mat');

figure
count = 0;
A_10 = zeros(256,256);
for i = 6400:10000
    count = count+1;
    ttl = sprintf('Frame: %d', i-1);
    frame_name = sprintf('filtered_totMap_%d', i);
    A = log10(test.(frame_name));
    A(~isfinite(A)) = 0;

    A_10 = A_10+A;
    if count == 10

        clim = [0, 3];

        imagesc(A_10, clim);
        axis image;             % avoid distortion
        axis xy;                % y increases upward
        colorbar;
        colormap("hot")
        ttl = sprintf('Frame from %d to %d', i-count, i);
        title(ttl)

        drawnow()
        count = 0;
        A_10 =zeros(size(A));

    end
end

% filename = 'output_animation.gif';
% 
% figure
% count = 0;
% A_10 = zeros(256,256);
% 
% for i = 6400:10000
%     count = count+1;
%     frame_name = sprintf('filtered_totMap_%d', i);
%     A = log10(test.(frame_name));
%     A(~isfinite(A)) = 0;
% 
%     A_10 = A_10+A;
%     if count == 10
%         clim = [0, 3];
% 
%         imagesc(A_10, clim);
%         axis image;
%         axis xy;
%         colorbar;
%         colormap("jet")
%         ttl = sprintf('Frame from %d to %d', i-count, i);
%         title(ttl)
% 
%         drawnow()
% 
%         % Capture frame
%         frame = getframe(gcf);
%         im = frame2im(frame);
%         [imind, cm] = rgb2ind(im, 256);
% 
%         if i == 6400+9
%             imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
%         else
%             imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
%         end
% 
%         count = 0;
%         A_10 = zeros(size(A));
%     end
% end
% disp('Animation saved as output_animation.gif')
