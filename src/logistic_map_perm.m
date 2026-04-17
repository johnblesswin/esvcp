function perm = logistic_map_perm(x0, mu, N)
% LOGISTIC_MAP_PERM  Generate a chaotic permutation of 1..N
%
%   PERM = LOGISTIC_MAP_PERM(X0, MU, N) generates N iterations of the
%   logistic map x_{n+1} = μ · x_n · (1 - x_n), then returns the
%   permutation index obtained by sorting the sequence.
%
%   The permutation is a cryptographic-grade pseudo-random reordering
%   of indices 1..N that is fully deterministic given (x0, mu).
%
%   Default: mu = 3.9999 (fully chaotic regime).
%
%   References:
%       [39] Baptista (1998) — Cryptography with chaos
%       [40] Hua et al. (2023) — 2D logistic-sine map for image encryption

if nargin < 2 || isempty(mu)
    mu = 3.9999;
end
if x0 <= 0 || x0 >= 1
    error('ESVCP:BadSeed', 'Logistic seed x0 must be in (0,1); got %g', x0);
end
if mu <= 3.57 || mu > 4
    warning('ESVCP:BadMu', 'μ = %g outside chaotic regime (3.57, 4]', mu);
end

% Generate sequence (warm-up 100 iterations to discard transient)
x = x0;
for i = 1:100
    x = mu * x * (1 - x);
end

seq = zeros(N, 1);
for i = 1:N
    x = mu * x * (1 - x);
    seq(i) = x;
end

% Permutation = argsort
[~, perm] = sort(seq);

end
