function [stego, shares, meta] = esvcp_main(cover, secret, key, varargin)
% ESVCP_MAIN  Enhanced Semantic Visual Cryptographic Protocol — main pipeline
%
%   [STEGO, SHARES, META] = ESVCP_MAIN(COVER, SECRET, KEY) embeds a binary
%   SECRET into a COVER image using the three-innovation ESVCP pipeline:
%       1. SASG  — Semantic-Aware Share Generation (Innovation III)
%       2. AEDQ  — Adaptive Error Diffusion Quantization (Innovation I)
%       3. MLCI  — Multi-Layer LSB + Chaotic Permutation (Innovation II)
%
%   Inputs:
%       COVER   — uint8 image, [M N] or [M N 3]
%       SECRET  — binary array (0/1) or uint8 image
%       KEY     — struct with fields: mlci (logistic seed), aedq [beta theta lambda]
%
%   Optional name-value pairs:
%       'bpp'       — embedding rate (default 0.5)
%       'window'    — entropy window size (default 7)
%       'tau_sal'   — saliency threshold (default 0.5)
%
%   Outputs:
%       STEGO   — stego-image (same size/dtype as COVER)
%       SHARES  — cell array of VCS shares {V1, V2, ...}
%       META    — struct with embedding metadata (PSNR, SSIM, capacity, etc.)
%
%   Reference:
%       [Your et al., 2026] ESVCP, Scientific Reports.
%
%   See also: aedq_embed, mlci_embed, sasg_shares, esvcp_extract

% ── Parse inputs ────────────────────────────────────────────
p = inputParser;
addParameter(p, 'bpp',     0.5);
addParameter(p, 'window',  7);
addParameter(p, 'tau_sal', 0.5);
parse(p, varargin{:});
opts = p.Results;

% ── Validate inputs ──────────────────────────────────────────
if ~isa(cover, 'uint8')
    cover = im2uint8(cover);
end
if islogical(secret)
    secret_bits = secret(:);
else
    secret_bits = reshape(de2bi(secret(:), 8, 'left-msb')', [], 1);
end

% If RGB, convert to grayscale for baseline pipeline
% (colour extension processes each channel independently)
if size(cover, 3) == 3
    cover_gray = rgb2gray(cover);
else
    cover_gray = cover;
end

fprintf('[ESVCP] Cover size: %d x %d  |  Secret: %d bits  |  Target bpp: %.2f\n', ...
    size(cover,1), size(cover,2), numel(secret_bits), opts.bpp);

% ── Stage 1: SASG (shares generation) ────────────────────────
fprintf('[ESVCP] Stage 1/3  — SASG share generation...\n');
tic;
[shares, sal_mask] = sasg_shares(cover_gray, secret_bits, ...
    'tau_sal', opts.tau_sal);
t_sasg = toc;

% ── Stage 2: Entropy map for AEDQ ────────────────────────────
fprintf('[ESVCP] Stage 2/3  — AEDQ entropy-adaptive embedding...\n');
tic;
H_map = compute_entropy_map(cover_gray, opts.window);
t_entropy = toc;

% ── Stage 3: Chaotic permutation + MLCI embedding ────────────
fprintf('[ESVCP] Stage 3/3  — MLCI chaotic permutation + embedding...\n');
tic;
stego = mlci_embed(cover_gray, secret_bits, H_map, key);
t_mlci = toc;

% ── Post-embedding AEDQ error diffusion ──────────────────────
stego = aedq_embed(stego, cover_gray, H_map, key);

% ── Compute embedding metadata ───────────────────────────────
[psnr_val, ssim_val] = compute_metrics(cover_gray, stego);
meta = struct(...
    'psnr',        psnr_val, ...
    'ssim',        ssim_val, ...
    'bpp',         opts.bpp, ...
    'n_bits',      numel(secret_bits), ...
    'entropy_mean', mean(H_map(:)), ...
    'saliency_pct', 100 * mean(sal_mask(:) >= opts.tau_sal), ...
    'time_sasg',   t_sasg, ...
    'time_entropy',t_entropy, ...
    'time_mlci',   t_mlci, ...
    'time_total',  t_sasg + t_entropy + t_mlci);

% ── If cover was RGB, restore colour ─────────────────────────
if size(cover, 3) == 3
    stego_color        = cover;
    stego_color(:,:,1) = stego;    % embed in R channel
    stego              = stego_color;
end

fprintf('[ESVCP] Done. PSNR=%.2f dB  SSIM=%.4f  Runtime=%.2f s\n', ...
    psnr_val, ssim_val, meta.time_total);

end
