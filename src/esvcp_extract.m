function [recovered_bits, recovered_img] = esvcp_extract(stego, shares, key, varargin)
% ESVCP_EXTRACT  Recover the hidden secret from the stego-image
%
%   [BITS, IMG] = ESVCP_EXTRACT(STEGO, SHARES, KEY) extracts the embedded
%   secret via inverse MLCI permutation and VCS share superposition.
%
%   Algorithm:
%       1. Reconstruct chaotic permutation using KEY.mlci
%       2. Extract bits from planes B0, B1, B2 of STEGO in permuted order
%       3. XOR superposition of all SHARES to recover binary secret image
%       4. Reassemble into bit-stream / image
%
%   Reference: Section 3.4 of ESVCP paper (2026).

p = inputParser;
addParameter(p, 'n_bits', []);
parse(p, varargin{:});
opts = p.Results;

if size(stego, 3) == 3
    stego = rgb2gray(stego);
end

[M, N] = size(stego);
stego_flat = stego(:);

% ── Regenerate chaotic permutation ───────────────────────────
mu = 3.9999;
n_pixels = M * N;
perm = logistic_map_perm(key.mlci, mu, n_pixels);

% ── Determine payload length ─────────────────────────────────
if isempty(opts.n_bits)
    % Default: extract max 3 bpp
    L_total = 3 * n_pixels;
else
    L_total = opts.n_bits;
end

n_B0 = round(0.60 * L_total);
n_B1 = round(0.30 * L_total);
n_B2 = L_total - n_B0 - n_B1;

% ── Extract bits from each plane ─────────────────────────────
recovered_bits = zeros(L_total, 1, 'uint8');

idx_B0 = perm(1 : n_B0);
idx_B1 = perm(n_B0 + 1 : n_B0 + n_B1);
idx_B2 = perm(n_B0 + n_B1 + 1 : L_total);

for i = 1:n_B0
    recovered_bits(i) = bitget(stego_flat(idx_B0(i)), 1);
end
for i = 1:n_B1
    recovered_bits(n_B0 + i) = bitget(stego_flat(idx_B1(i)), 2);
end
for i = 1:n_B2
    recovered_bits(n_B0 + n_B1 + i) = bitget(stego_flat(idx_B2(i)), 3);
end

% ── VCS share superposition ──────────────────────────────────
if nargin >= 2 && ~isempty(shares)
    S_recon = shares{1};
    for k = 2:numel(shares)
        S_recon = xor(S_recon, shares{k});
    end
    recovered_img = uint8(S_recon) * 255;
else
    % Reshape bit-stream to image approximation
    L_show = min(L_total, M * N);
    img_flat = zeros(M*N, 1, 'uint8');
    img_flat(1:L_show) = recovered_bits(1:L_show) * 255;
    recovered_img = reshape(img_flat, M, N);
end

end
