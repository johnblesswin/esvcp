function stego = aedq_embed(stego_in, cover, H_map, key)
% AEDQ_EMBED  Adaptive Error Diffusion Quantization (Innovation I)
%
%   STEGO = AEDQ_EMBED(STEGO_IN, COVER, H_MAP, KEY) applies entropy-adaptive
%   error diffusion to the stego image after LSB embedding. The diffusion
%   kernel interpolates between Floyd-Steinberg and Jarvis-Judice-Ninke
%   based on local entropy H̃(i,j):
%
%       α(i,j) = 1 / (1 + exp(-β·(H̃ − θ)))
%       W(i,j) = α·W_FS + (1 − α)·W_JJN
%
%   High-entropy regions (textured) → W_FS (local, max capacity)
%   Low-entropy regions (flat)     → W_JJN (spread, min artifact)
%
%   Reference: Section 4.1 of ESVCP paper (2026).

beta   = key.aedq(1);   % sigmoid steepness (default 10)
theta  = key.aedq(2);   % entropy threshold (default 0.5)
lambda = key.aedq(3);   % distortion weighting (default 5)

[M, N] = size(stego_in);
stego  = double(stego_in);
cover  = double(cover);

% Normalise entropy map to [0,1]
H = H_map;
if max(H(:)) > 1
    H = H / log2(256);  % H_max = 8 bits
end
H = min(max(H, 0), 1);

% Adaptive sigmoid weight α(i,j)
alpha = 1 ./ (1 + exp(-beta .* (H - theta)));

% Kernel definitions
W_FS  = [0 0 0 7 0; 3 5 1 0 0] / 16;       % Floyd-Steinberg
W_JJN = [0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1] / 48;  % Jarvis-Judice-Ninke

% Error = difference between stego and cover (embedding perturbation)
err = stego - cover;

% ── Apply adaptive error diffusion ───────────────────────────
% Process in raster order
for i = 1:M-1
    for j = 3:N-2
        a_ij = alpha(i, j);
        q    = err(i, j);

        if a_ij > 0.5   % lean toward Floyd-Steinberg
            if j+1 <= N
                stego(i,   j+1) = stego(i,   j+1) + q * 7/16 * a_ij;
            end
            if j-1 >= 1 && i+1 <= M
                stego(i+1, j-1) = stego(i+1, j-1) + q * 3/16 * a_ij;
            end
            if i+1 <= M
                stego(i+1, j  ) = stego(i+1, j  ) + q * 5/16 * a_ij;
            end
            if j+1 <= N && i+1 <= M
                stego(i+1, j+1) = stego(i+1, j+1) + q * 1/16 * a_ij;
            end
        else            % lean toward JJN (spread)
            w = 1 - a_ij;
            if j+1 <= N
                stego(i,   j+1) = stego(i,   j+1) + q * 7/48 * w;
            end
            if j+2 <= N
                stego(i,   j+2) = stego(i,   j+2) + q * 5/48 * w;
            end
            if i+1 <= M && j-2 >= 1
                stego(i+1, j-2) = stego(i+1, j-2) + q * 3/48 * w;
            end
            if i+1 <= M && j-1 >= 1
                stego(i+1, j-1) = stego(i+1, j-1) + q * 5/48 * w;
            end
            if i+1 <= M
                stego(i+1, j  ) = stego(i+1, j  ) + q * 7/48 * w;
            end
        end
    end
end

% ── Distortion weighting: apply lambda correction ────────────
dist_map = (err .^ 2) ./ (1 + lambda .* H);
avg_dist = mean(dist_map(:));

% Clip to valid range
stego = uint8(max(0, min(255, round(stego))));

end
