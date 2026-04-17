# ESVCP Usage Guide

## Quick Start

```matlab
% Add all paths
addpath(genpath('src'));
addpath(genpath('figures'));

% Run the demo
demo_single_image
```

---

## Step-by-Step Usage

### 1. Load a cover image

```matlab
cover = imread('data/test_images/lena.png');
cover = rgb2gray(cover);          % grayscale required for base pipeline
cover = imresize(cover,[512 512]);% optional resize
```

### 2. Prepare a secret payload

```matlab
% Option A: random binary payload
bpp    = 0.5;
L      = round(bpp * numel(cover));
secret = uint8(randi([0 1], L, 1));

% Option B: from a secret image
secret_img = imread('data/secret_images/mnist_7.png');
secret_img = imbinarize(rgb2gray(secret_img));
secret     = secret_img(:);
```

### 3. Set up the key

```matlab
key = struct(...
    'mlci', 0.5472, ...      % logistic map seed x0 in (0,1)
    'aedq', [10  0.5  5]);   % [beta  theta  lambda]
```

| Parameter | Role | Default | Range |
|-----------|------|---------|-------|
| `key.mlci` | Logistic map seed | 0.5472 | (0, 1) |
| `key.aedq(1)` beta | Sigmoid steepness | 10 | [5, 20] |
| `key.aedq(2)` theta | Entropy threshold | 0.5 | [0.3, 0.7] |
| `key.aedq(3)` lambda | Distortion weight | 5 | [1, 10] |

### 4. Embed

```matlab
[stego, shares, meta] = esvcp_main(cover, secret, key, 'bpp', 0.5);

fprintf('PSNR = %.2f dB\n', meta.psnr);
fprintf('SSIM = %.4f\n',    meta.ssim);
```

### 5. Extract

```matlab
[recovered_bits, recovered_img] = esvcp_extract(stego, shares, key, ...
    'n_bits', numel(secret));

ber = mean(recovered_bits(:) ~= secret(:));
fprintf('BER = %.4f%%\n', 100*ber);
```

---

## Running the Full Benchmark

```matlab
% Benchmarks all payload rates against all baselines
run_benchmark

% Generates all 5 paper figures at 300 DPI
run(fullfile('figures','Figure1_system_architecture.m'));
run(fullfile('figures','Figure2_innovation_detail.m'));
run(fullfile('figures','Figure3_results_comparison.m'));
run(fullfile('figures','Figure4_visual_quality.m'));
run(fullfile('figures','Figure5_security_analysis.m'));
```

---

## Processing an Entire Dataset

```matlab
img_dir = 'data/BOSSBase/';
files   = dir(fullfile(img_dir,'*.png'));

key = struct('mlci',0.5472,'aedq',[10 0.5 5]);
bpp = 0.5;

PSNR_all = zeros(1,numel(files));
for k = 1:numel(files)
    cover = imread(fullfile(img_dir, files(k).name));
    cover = im2uint8(mean(double(cover),3));

    L      = round(bpp * numel(cover));
    secret = uint8(randi([0 1],L,1));

    [stego, ~, meta] = esvcp_main(cover, secret, key, 'bpp', bpp);
    PSNR_all(k)      = meta.psnr;
end
fprintf('Dataset mean PSNR = %.2f dB\n', mean(PSNR_all));
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `ESVCP:NoImages` | `data/test_images/` empty | Run demo — it downloads from Wikimedia |
| `entropyfilt` not found | Image Processing Toolbox missing | `ver('images')` to check |
| `ssim` not found | Same toolbox issue | Add toolbox in MATLAB Add-Ons |
| Low PSNR (<40 dB) | bpp too high for image size | Reduce bpp or use 512×512 image |
| BER > 1% | Wrong key at extraction | Ensure same `key.mlci` value |
| Share PSNR <20 dB | U²-Net not available | Spectral residual fallback is used |
