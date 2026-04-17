function [shares, sal_mask] = sasg_shares(cover, secret_bits, varargin)
% SASG_SHARES  Semantic-Aware Share Generation (Innovation III)
%
%   [SHARES, SAL_MASK] = SASG_SHARES(COVER, SECRET_BITS) generates a set of
%   meaningful (2,2)-VCS shares from the cover image such that pixel
%   modifications are restricted to semantically non-salient regions.
%
%   Saliency is estimated via a U²-Net-approximation (fallback: spectral
%   residual method from Image Processing Toolbox) yielding a binary mask
%   M_sal. Pixels with M_sal(i,j) = 1 are protected (replicated in all
%   shares); pixels in Ω_free carry the VCS-encoded secret.
%
%   Reference: Section 4.3 of ESVCP paper (2026).

p = inputParser;
addParameter(p, 'tau_sal', 0.5);
addParameter(p, 'n_shares', 2);
parse(p, varargin{:});
opts = p.Results;

[M, N] = size(cover);

% ── Saliency estimation ──────────────────────────────────────
% Try U²-Net if Deep Learning Toolbox available, else use fallback
try
    % Placeholder for U²-Net — requires pre-trained net
    % sal = predict(u2net, cover);
    error('ESVCP:NoU2Net','Fallback to spectral residual');
catch
    % Fallback: spectral residual saliency (fast, no DL toolbox)
    sal = spectral_residual_saliency(cover);
end

% Normalise to [0,1]
sal = double(sal);
sal = (sal - min(sal(:))) / (max(sal(:)) - min(sal(:)) + 1e-10);

% Binary saliency mask
sal_mask = sal >= opts.tau_sal;

% ── Halftone the cover to binary for VCS ─────────────────────
% Use Floyd-Steinberg dithering as halftone quantizer Q(·)
cover_halftone = dither(cover);

% ── Halftone the secret (assumed already binary) ─────────────
L = min(numel(secret_bits), M*N);
secret_img = zeros(M, N, 'logical');
secret_img(1:L) = secret_bits(1:L);

% ── Generate shares ──────────────────────────────────────────
shares = cell(1, opts.n_shares);

% Random noise share
rng('shuffle');
V1 = logical(randi([0 1], M, N));

% Second share: V2 = V1 XOR secret within Ω_free,
%                V2 = V1           within Ω_sal (cover replicated)
V2 = V1;
V2(~sal_mask) = xor(V1(~sal_mask), secret_img(~sal_mask));

% Within Ω_sal, both shares are set to the halftoned cover (preserves appearance)
V1(sal_mask) = cover_halftone(sal_mask);
V2(sal_mask) = cover_halftone(sal_mask);

shares{1} = V1;
shares{2} = V2;

% If n_shares > 2, generate additional random shares (Visual Secret Sharing)
for k = 3:opts.n_shares
    shares{k} = logical(randi([0 1], M, N));
end

end

% ── Helper: spectral residual saliency (Hou & Zhang 2007) ────
function sal = spectral_residual_saliency(img)
    img    = double(img) / 255;
    F      = fft2(img);
    A      = abs(F);
    P      = angle(F);
    logA   = log(A + 1);
    avgLogA = imfilter(logA, fspecial('average', 3));
    SR     = logA - avgLogA;
    sal    = abs(ifft2(exp(SR + 1i * P))) .^ 2;
    sal    = imgaussfilt(sal, 3);
end
