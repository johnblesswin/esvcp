function H = compute_entropy_map(img, win_size)
% COMPUTE_ENTROPY_MAP  Local entropy map over a sliding window
%
%   H = COMPUTE_ENTROPY_MAP(IMG, WIN_SIZE) computes the local Shannon
%   entropy H(i,j) over a WIN_SIZE x WIN_SIZE neighbourhood for each pixel.
%   The returned map is normalised to [0, 1] using H_max = 8 bits.
%
%   Default WIN_SIZE = 7 (matches the paper).
%
%   Reference: Equation (4.1.2) of ESVCP paper (2026).

if nargin < 2
    win_size = 7;
end

if size(img, 3) > 1
    img = rgb2gray(img);
end

img = im2double(img);

% Use Image Processing Toolbox's optimised sliding-window entropy
H = entropyfilt(img, true(win_size));

% Normalise by H_max = 8 bits for 8-bit images
H = H / 8;
H = min(max(H, 0), 1);

end
