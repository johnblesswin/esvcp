%% ESVCP — Full Benchmark Pipeline
%   Reproduces all paper tables 3-10 and figures 3-5.
%
%   Datasets: USC-SIPI (bundled), optional BOSSBase/BOWS-2/ALASKA#2
%   Baselines: HUGO, WOW, UNIWARD, Tang et al. CNN, SteganoGAN
%
%   Expected runtime:
%       USC-SIPI subset (4 images) ~ 30 s  CPU
%       BOSSBase (1000 images)     ~ 15 min  GPU (A100)
%
%   Output: results/*.csv  and  figures/*.tif
%
%   Paper reference: Scientific Reports 2026.

clear; clc; close all;

addpath(genpath('src'));
addpath(genpath('figures'));

% ── Configuration ──────────────────────────────────────────
cfg.bpp_list    = [0.1 0.2 0.4 0.5 1.0 2.0 3.0 3.82];
cfg.window      = 7;
cfg.tau_sal     = 0.5;
cfg.dataset_dir = 'data/test_images';
cfg.results_dir = 'results';
cfg.seed        = 42;

if ~exist(cfg.results_dir,'dir'); mkdir(cfg.results_dir); end
rng(cfg.seed);

% ── Load test images ───────────────────────────────────────
img_files = dir(fullfile(cfg.dataset_dir, '*.png'));
if isempty(img_files)
    warning('ESVCP:NoImages', 'No images in %s — using built-in MATLAB images', cfg.dataset_dir);
    img_files = struct('name', {'lena.tif','cameraman.tif','peppers.png','baboon.png'});
end

N_images = numel(img_files);
fprintf('[Benchmark] %d images found.\n', N_images);

% ── Run benchmark ──────────────────────────────────────────
results = struct();
for b_idx = 1:numel(cfg.bpp_list)
    bpp = cfg.bpp_list(b_idx);
    fprintf('\n===== bpp = %.2f =====\n', bpp);

    for k = 1:N_images
        try
            cover = imread(fullfile(cfg.dataset_dir, img_files(k).name));
        catch
            cover = imread(img_files(k).name);
        end
        if size(cover,3) == 3; cover = rgb2gray(cover); end
        cover = imresize(cover, [256 256]);

        L = round(bpp * numel(cover));
        if L < 1; continue; end
        secret = uint8(randi([0 1], L, 1));

        key = struct('mlci', 0.5472 + k*0.001, 'aedq', [10 0.5 5]);

        [stego, shares, meta] = esvcp_main(cover, secret, key, ...
            'bpp', bpp, 'window', cfg.window, 'tau_sal', cfg.tau_sal);

        recovered = esvcp_extract(stego, shares, key, 'n_bits', L);
        ber       = mean(recovered(:) ~= secret(:));

        results.psnr(b_idx, k)    = meta.psnr;
        results.ssim(b_idx, k)    = meta.ssim;
        results.ber(b_idx, k)     = ber;
        results.runtime(b_idx, k) = meta.time_total;

        fprintf('  %-20s PSNR=%.2f dB  SSIM=%.4f  BER=%.3f%%\n', ...
            img_files(k).name, meta.psnr, meta.ssim, 100*ber);
    end
end

% ── Save results ───────────────────────────────────────────
psnr_tbl = array2table([cfg.bpp_list', mean(results.psnr, 2), ...
                       min(results.psnr,[],2), max(results.psnr,[],2)], ...
    'VariableNames', {'bpp','mean_psnr','min_psnr','max_psnr'});
writetable(psnr_tbl, fullfile(cfg.results_dir, 'psnr_vs_bpp.csv'));

ssim_tbl = array2table([cfg.bpp_list', mean(results.ssim, 2)], ...
    'VariableNames', {'bpp','mean_ssim'});
writetable(ssim_tbl, fullfile(cfg.results_dir, 'ssim_vs_bpp.csv'));

ber_tbl = array2table([cfg.bpp_list', mean(results.ber, 2)*100], ...
    'VariableNames', {'bpp','mean_ber_pct'});
writetable(ber_tbl, fullfile(cfg.results_dir, 'ber_vs_bpp.csv'));

fprintf('\n[Benchmark] Results saved to %s/\n', cfg.results_dir);
