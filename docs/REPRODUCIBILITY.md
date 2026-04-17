# Reproducibility Guide

This document explains how to reproduce **every number** reported in the paper.

---

## System Requirements

| Component | Specification |
|-----------|---------------|
| CPU | Intel Xeon Gold 6338 or equivalent |
| GPU | NVIDIA A100 80 GB (for full-dataset runs) |
| RAM | 64 GB minimum |
| MATLAB | R2023a or later |
| Image Processing Toolbox | Required |
| OS | Ubuntu 22.04 / Windows 11 |

---

## Reproducing Table 3 — PSNR/SSIM at 0.5 bpp

```matlab
addpath(genpath('src'));
run_benchmark   % sets bpp_list = [0.5], saves to results/
```

Expected output in `results/psnr_ssim_table.csv`.
ESVCP expected: PSNR = 48.73 ± 0.5 dB, SSIM = 0.9961 ± 0.002.

---

## Reproducing Table 6 — Steganalysis P_E

The steganalysis detectors (SRM, maxSRMd2, YeNet, SRNet) require:

1. **SRM / maxSRMd2:** Install the MATLAB SRM feature extractor from:
   http://dde.binghamton.edu/download/feature_extractors/

2. **YeNet / SRNet:** Pre-trained PyTorch weights available at:
   https://github.com/brijeshiitg/Pytorch-implementation-of-SRNet

3. Run the steganalysis evaluation:
```matlab
% Produces results/steganalysis_pe.csv
run_steganalysis_eval   % (requires steganalysis tools installed)
```

Pre-computed results are provided in `results/steganalysis_pe.csv`.

---

## Reproducing Figure 3

```matlab
run(fullfile('figures','Figure3_results_comparison.m'));
% Outputs: Figure3_results.tif, Figure3_results.pdf
```

---

## Reproducing Figure 4 (Visual Quality)

```matlab
% Requires USC-SIPI images in data/test_images/
run(fullfile('figures','Figure4_visual_quality.m'));
```

---

## Reproducing Figure 5 (Security Analysis)

```matlab
run(fullfile('figures','Figure5_security_analysis.m'));
```

---

## Numerical Tolerances

Due to floating-point arithmetic differences between platforms,
results may differ from paper values by:

| Metric | Tolerance |
|--------|-----------|
| PSNR | ± 0.05 dB |
| SSIM | ± 0.0005 |
| BER | ± 0.01% |
| Runtime | ± 15% (hardware dependent) |

These differences do not affect the conclusions of the paper.

---

## Random Seeds

All experiments use fixed random seeds:
- MATLAB `rng(42)` for payload generation
- Logistic map seed: `x0 = 0.5472`
- HUGO/WOW baselines: use their official implementations with default seeds

---

## Contact

If you cannot reproduce a result, please open an issue at:
https://github.com/\<your-username\>/ESVCP-framework/issues
