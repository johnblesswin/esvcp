%% ESVCP — Single Image Demo
%   Embeds a binary secret into the Lena test image and recovers it.
%
%   Paper reference: Scientific Reports 2026, Sec. 5-6.

clear; clc; close all;

% ── Setup ───────────────────────────────────────────────────
addpath(genpath('src'));

% ── Load cover ──────────────────────────────────────────────
try
    cover = imread('data/test_images/lena.png');
catch
    cover = imread('https://upload.wikimedia.org/wikipedia/en/7/7d/Lenna_%28test_image%29.png');
end
if size(cover, 3) == 3
    cover = rgb2gray(cover);
end
cover = imresize(cover, [256 256]);

% ── Generate secret payload (random binary) ─────────────────
rng(42);
bpp = 0.5;
L   = round(bpp * numel(cover));
secret_bits = uint8(randi([0 1], L, 1));

% ── Key setup ───────────────────────────────────────────────
key = struct(...
    'mlci', 0.5472, ...         % logistic map seed
    'aedq', [10 0.5 5]);        % [beta theta lambda]

% ── Embed ───────────────────────────────────────────────────
[stego, shares, meta] = esvcp_main(cover, secret_bits, key, 'bpp', bpp);

% ── Extract ─────────────────────────────────────────────────
recovered_bits = esvcp_extract(stego, shares, key, 'n_bits', L);

% ── Compute recovery metrics ────────────────────────────────
bit_errors = sum(recovered_bits ~= secret_bits);
ber        = bit_errors / L;
ncc        = (double(recovered_bits') * double(secret_bits)) / ...
             (norm(double(recovered_bits)) * norm(double(secret_bits)) + eps);

% ── Display results ─────────────────────────────────────────
fprintf('\n===================================================\n');
fprintf('  ESVCP — Single Image Demo Results\n');
fprintf('===================================================\n');
fprintf('  Cover:          256 x 256 grayscale\n');
fprintf('  Payload:        %d bits  (%.2f bpp)\n', L, bpp);
fprintf('  PSNR:           %.2f dB\n',          meta.psnr);
fprintf('  SSIM:           %.4f\n',             meta.ssim);
fprintf('  Mean entropy:   %.3f\n',             meta.entropy_mean);
fprintf('  Saliency area:  %.1f %%\n',          meta.saliency_pct);
fprintf('  Recovery NCC:   %.4f\n',             ncc);
fprintf('  Recovery BER:   %.4f %%\n',          ber * 100);
fprintf('  Runtime:        %.2f s  (SASG: %.2f, AEDQ: %.2f, MLCI: %.2f)\n', ...
    meta.time_total, meta.time_sasg, meta.time_entropy, meta.time_mlci);
fprintf('===================================================\n\n');

% ── Visualise ───────────────────────────────────────────────
figure('Position',[100 100 900 300],'Color','white');
subplot(1,3,1); imshow(cover);  title('Cover I_c',        'FontSize', 11);
subplot(1,3,2); imshow(stego);  title('Stego I_s (ESVCP)','FontSize', 11);
subplot(1,3,3); imshow(10 * uint8(abs(double(stego)-double(cover))));
title('Residual |I_c - I_s| x 10','FontSize', 11);
