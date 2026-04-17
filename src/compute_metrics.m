function [psnr_val, ssim_val, ncc_val, ber_val] = compute_metrics(original, reconstructed)
% COMPUTE_METRICS  Compute PSNR, SSIM, NCC, and BER between two images
%
%   [PSNR, SSIM, NCC, BER] = COMPUTE_METRICS(ORIGINAL, RECONSTRUCTED)
%
%   PSNR in dB, SSIM in [0,1], NCC in [-1,1], BER in [0,1].
%
%   Reference: Section 5.4 of ESVCP paper (2026).

if size(original, 3) > 1
    original = rgb2gray(original);
end
if size(reconstructed, 3) > 1
    reconstructed = rgb2gray(reconstructed);
end

original      = im2uint8(original);
reconstructed = im2uint8(reconstructed);

% PSNR
mse = mean((double(original(:)) - double(reconstructed(:))).^2);
if mse == 0
    psnr_val = Inf;
else
    psnr_val = 10 * log10(255^2 / mse);
end

% SSIM
ssim_val = ssim(reconstructed, original);

% NCC (normalized cross-correlation)
a = double(original(:));
b = double(reconstructed(:));
ncc_val = (a' * b) / (sqrt((a' * a) * (b' * b)) + eps);

% BER (bit error rate)
bits_a = de2bi(original(:),      8, 'left-msb');
bits_b = de2bi(reconstructed(:), 8, 'left-msb');
ber_val = mean(bits_a(:) ~= bits_b(:));

end
