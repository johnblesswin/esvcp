function stego = mlci_embed(cover, secret_bits, H_map, key)
% MLCI_EMBED  Multi-Layer LSB Embedding with Chaotic Permutation (Innovation II)
%
%   STEGO = MLCI_EMBED(COVER, SECRET_BITS, H_MAP, KEY) embeds the secret
%   bit-stream into the three least-significant bit-planes {B0, B1, B2} of
%   the cover image using a logistic-map chaotic permutation.
%
%   Plane load:  B0 (LSB) : 60%
%                B1       : 30%
%                B2       : 10%
%
%   The logistic map is defined by:
%       x_{n+1} = μ · x_n · (1 - x_n),  μ = 3.9999,  x_0 = key.mlci
%
%   Reference: Section 4.2 of ESVCP paper (2026).

mu = 3.9999;
x0 = key.mlci;           % logistic map seed (scalar in (0,1))

[M, N] = size(cover);
L_total = numel(secret_bits);

% ── Asymmetric plane allocation ──────────────────────────────
n_B0 = round(0.60 * L_total);
n_B1 = round(0.30 * L_total);
n_B2 = L_total - n_B0 - n_B1;

% ── Skip very low entropy pixels (protect flat regions) ──────
% AEDQ constraint: bypass embedding where H̃ < 0.2
H_thresh = 0.2;
H_norm   = H_map;
if max(H_norm(:)) > 1
    H_norm = H_norm / log2(256);
end
valid_mask = H_norm >= H_thresh;

% ── Generate chaotic permutation ─────────────────────────────
n_pixels = M * N;
perm     = logistic_map_perm(x0, mu, n_pixels);

% Filter permutation to valid pixels only (entropy ≥ threshold)
flat_valid = valid_mask(:);
perm_valid = perm(flat_valid(perm));   % preserve chaotic order among valid
perm_valid = perm_valid(1:min(L_total, numel(perm_valid)));

if numel(perm_valid) < L_total
    warning('ESVCP:capacity', ...
        'Not enough valid pixels — truncating payload from %d to %d bits.', ...
        L_total, numel(perm_valid));
    L_total     = numel(perm_valid);
    secret_bits = secret_bits(1:L_total);
    n_B0 = round(0.60 * L_total);
    n_B1 = round(0.30 * L_total);
    n_B2 = L_total - n_B0 - n_B1;
end

% ── Embed bits into each plane ───────────────────────────────
stego_flat = cover(:);

% Plane B0 (LSB)
idx_B0 = perm_valid(1 : n_B0);
for i = 1:n_B0
    stego_flat(idx_B0(i)) = bitset(stego_flat(idx_B0(i)), 1, secret_bits(i));
end

% Plane B1
idx_B1 = perm_valid(n_B0 + 1 : n_B0 + n_B1);
for i = 1:n_B1
    stego_flat(idx_B1(i)) = bitset(stego_flat(idx_B1(i)), 2, secret_bits(n_B0 + i));
end

% Plane B2
idx_B2 = perm_valid(n_B0 + n_B1 + 1 : L_total);
for i = 1:n_B2
    stego_flat(idx_B2(i)) = bitset(stego_flat(idx_B2(i)), 3, secret_bits(n_B0 + n_B1 + i));
end

stego = reshape(stego_flat, [M, N]);

end
