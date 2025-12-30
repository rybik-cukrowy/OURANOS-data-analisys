% Convert frame ToT maps into summed energies (keV) using CTU calibration

clc; clear; close all;

A = readmatrix('basic_data_process/a.txt');
B = readmatrix('basic_data_process/b.txt');
C = readmatrix('basic_data_process/c.txt');
T = readmatrix('basic_data_process/t.txt');

% helper, i don't have 'nansum' built in
if ~exist('nansum','file')
    nansum = @(x) sum(x(~isnan(x)));
end

% if the TXT files are flattened vectors, reshape here:
if isvector(A)
    side = sqrt(numel(A));
    if abs(side - round(side)) > 0
        error('Coefficient vectors do not form a square image.');
    end
    side = round(side);
    A  = reshape(A,  side, side);
    B = reshape(B, side, side);
    C = reshape(C, side, side);
    T = reshape(T, side, side);
end

tot_keV_sum       = zeros(1, 12000);  % sum of energies per frame (no filtering)
tot_keV_filtered  = zeros(1, 12000);  % after removing 1-pixel events
tot_keV_diff      = zeros(1, 12000);

tot2keV = @(ToT) local_tot_to_keV(ToT, A, B, C, T);

for batch = 1:6
    batch_start = (batch - 1) * 2000 + 1;
    batch_end   = batch_start + 1999;

    file_path = sprintf('basic_data_process/totMaps_%d_%d.mat', batch_start, batch_end);
    fprintf('Loading batch %d (%s)...\n', batch, file_path);
    data = load(file_path);

    for j = batch_start:batch_end
        frame_name = sprintf('totMap_%d', j);
        if ~isfield(data, frame_name)
            warning('Missing %s in %s, skipping.', frame_name, file_path);
            continue;
        end

        A_toT = data.(frame_name);             % ToT map (same size as coeffs)
        if ~isequal(size(A_toT), size(A))
            error('Size mismatch: frame %s is %s, coeffs are %s.', ...
                frame_name, mat2str(size(A_toT)), mat2str(size(A)));
        end

        % raw ToT -> Energy (keV), vectorized
        E = tot2keV(A_toT);                    % NaNs for invalid / below threshold
        tot_keV_sum(j) = nansum(E(:));         % sum valid energies

        
        % --- store keV maps ---
        keVMaps.(sprintf('keVMap_%d', j)) = E;
        
    end
    save(sprintf('matlab_processed_files/keVMaps_%d_%d.mat', batch_start, batch_end), '-struct', 'keVMaps');
    clear data
    fprintf('Finished batch %d.\n', batch);
end
fprintf('All batches processed.\n');

hits = load("basic_data_process\hits_in_frames.mat");

%{
% plots
fprintf('Plotting plots...\n');
plot(tot_keV_sum, 'm'); hold on
plot(tot_keV_filtered, 'g'); hold on
plot(tot_keV_diff, 'c');
legend('energy sum (keV)', '1-pixel events removed (keV)', 'difference (keV)');
xlabel('Frame #'); ylabel('Energy [keV]');
fprintf('done\n');

% results
if ~exist('matlab_processed_files','dir'), mkdir('matlab_processed_files'); end
save('matlab_processed_files\energy_sums_keV.mat', ...
     'tot_keV_sum','tot_keV_filtered','tot_keV_diff');
%}
% closed-form ToT -> keV
function E = local_tot_to_keV(ToT, A, B0, C0, T0)
    % vectorized closed-form inversion of ToT(E) = aE + b - c/(E - t)
    % returns NaN where discriminant < 0 (below threshold / non-physical)

    B = (B0 - ToT) - A.*T0;
    C = -((B0 - ToT).*T0 + C0);

    disc = B.^2 - 4.*A.*C;

    E = nan(size(ToT), 'like', ToT);
    ok = (disc >= 0) & (abs(A) > 1e-12);
    E(ok) = (-B(ok) + sqrt(disc(ok))) ./ (2.*A(ok));
    E(E <= 0) = NaN;
end
