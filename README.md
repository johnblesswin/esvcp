# ESVCP — Enhanced Semantic Visual Cryptographic Protocol

**Adaptive Error Diffusion, Multi-Layer LSB Embedding, and Semantic-Aware Share Generation for Secure Multimedia Communications**

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023a%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![DOI](https://img.shields.io/badge/DOI-pending-lightgrey.svg)](#)

---

## Overview

This repository contains the complete MATLAB implementation, experimental datasets, and figure-generation scripts for the paper:

> **An Enhanced Semantic Visual Cryptographic Protocol (ESVCP) with Adaptive Error Diffusion and Multi-Layer LSB Embedding for Secure Multimedia Communications** — 

The ESVCP framework introduces **three novel innovations** for secure multimedia steganography:

| # | Module | Description |
|---|--------|-------------|
| I   | **AEDQ** | Adaptive Error Diffusion Quantization — entropy-guided kernel interpolation |
| II  | **MLCI** | Multi-Layer LSB with Chaotic Permutation Indexing — logistic-map scrambled embedding |
| III | **SASG** | Semantic-Aware Share Generation — U²-Net saliency-guided VCS shares |

---

## Key Results

| Metric | Value | Benchmark |
|--------|-------|-----------|
| Mean PSNR (0.5 bpp) | **48.73 dB** | +5.43 dB over Tang et al. [32] |
| Mean SSIM (0.5 bpp) | **0.9961** | vs. 0.9921 (Tang et al.) |
| Embedding Capacity  | **3.82 bpp** | vs. 1.0 bpp (HUGO / WOW / UNIWARD) |
| Steganalysis P_E (mean) | **51.90%** | ≈ random guessing |
| NCC (secret recovery) | **0.9997** | BER = 0.04% |
| VCS share PSNR | **33.70 dB** | vs. 9.42 dB classical VCS |
| Key space | **2¹⁹²** | > NIST post-quantum (2¹²⁸) |

---

## Repository Structure

```
ESVCP-framework/
├── README.md                         ← this file
├── LICENSE                           ← MIT License
├── CITATION.cff                      ← citation metadata
├── requirements.txt                  ← MATLAB toolbox dependencies
├── src/                              ← MATLAB source code
│   ├── esvcp_main.m                  ← main pipeline orchestrator
│   ├── aedq_embed.m                  ← AEDQ module (Innovation I)
│   ├── mlci_embed.m                  ← MLCI module (Innovation II)
│   ├── sasg_shares.m                 ← SASG module (Innovation III)
│   ├── esvcp_extract.m               ← extraction / recovery
│   ├── compute_entropy_map.m         ← local entropy (7×7 window)
│   ├── logistic_map_perm.m           ← chaotic permutation generator
│   ├── compute_metrics.m             ← PSNR / SSIM / NCC / BER
│   ├── run_benchmark.m               ← full benchmark vs. baselines
│   └── demo_single_image.m           ← quick demo on Lena
├── figures/                          ← figure-generation scripts
│   ├── Figure1_system_architecture.m
│   ├── Figure2_innovation_detail.m
│   ├── Figure3_results_comparison.m
│   ├── Figure4_visual_quality.m      ← USC-SIPI visual analysis
│   └── Figure5_security_analysis.m
├── data/
│   ├── test_images/                  ← USC-SIPI test images (public domain)
│   ├── secret_images/                ← sample secret payloads
│   └── README.md                     ← data-availability statement
├── results/                          ← pre-computed benchmark outputs
│   ├── psnr_ssim_table.csv
│   ├── steganalysis_pe.csv
│   ├── ablation_study.csv
│   └── runtime_comparison.csv
└── docs/
    ├── USAGE.md                      ← full usage guide
    ├── REPRODUCIBILITY.md            ← how to reproduce paper results
    └── API.md                        ← function reference
```

---

## Installation

### Prerequisites

- **MATLAB** R2023a or later
- **Image Processing Toolbox** (required)
- **Deep Learning Toolbox** (optional, for U²-Net saliency)
- **Parallel Computing Toolbox** (optional, speeds up benchmark)

### Quick Start

```matlab
% Clone the repository
% git clone https://github.com/<your-username>/ESVCP-framework.git

% Navigate to the MATLAB folder and add all source paths
cd ESVCP-framework
addpath(genpath('src'));
addpath(genpath('figures'));

% Run the single-image demo
demo_single_image

% Generate Figure 4 (USC-SIPI visual quality)
Figure4_visual_quality
```

---

## Reproducing Paper Results

```matlab
% Full benchmark (≈ 15 min on NVIDIA A100 or 45 min on CPU)
run_benchmark

% Generate all 5 paper figures at 300 DPI
for i = 1:5
    run(sprintf('figures/Figure%d_*.m', i));
end
```

All results are exported to the `results/` folder as `.csv` and all figures as `.tif` (300 DPI) and `.pdf` (vector).

---

## Usage Examples

### Example 1: Embed a secret into a cover image

```matlab
cover   = imread('data/test_images/lena.png');
secret  = imread('data/secret_images/mnist_7.png');
key     = struct('mlci', 0.5472, 'aedq', [10 0.5 5]);

[stego, shares] = esvcp_embed(cover, secret, key, 'bpp', 0.5);

[psnr_val, ssim_val] = compute_metrics(cover, stego);
fprintf('PSNR = %.2f dB  |  SSIM = %.4f\n', psnr_val, ssim_val);
```

### Example 2: Extract the secret

```matlab
recovered = esvcp_extract(stego, shares, key);
[ncc, ber] = compute_recovery_metrics(secret, recovered);
fprintf('NCC = %.4f  |  BER = %.2f%%\n', ncc, ber * 100);
```

---

## Data Availability

All test images used in this work are from the **USC-SIPI Image Database** (public domain) and included in `data/test_images/`. See `data/README.md` for the full data-availability statement.

- USC-SIPI: https://sipi.usc.edu/database/
- BOSSBase v1.01: http://agents.fel.cvut.cz/boss/
- BOWS-2: http://bows2.ec-lille.fr/
- ALASKA#2: https://alaska.utt.fr/

---

## Citation

If you use this code or build on this work, please cite:

```bibtex
@article{esvcp2026,
  author  = {John Blesswin A},
  title   = {An Enhanced Semantic Visual Cryptographic Protocol (ESVCP) with
             Adaptive Error Diffusion and Multi-Layer LSB Embedding for
             Secure Multimedia Communications},
 
}
```

---

## License

This project is released under the **MIT License**. See [LICENSE](LICENSE).

Standard test images are in the public domain via the USC-SIPI Image Database.

---

## Contact

For questions or collaboration:
- **Corresponding author:** johnb@srmist.edu.in
- **Issues:** https://github.com/johnblesswin/esvcp

---

## Acknowledgements

The authors thank the maintainers of the USC-SIPI Image Database, BOSSBase, BOWS-2, and ALASKA#2 benchmarks. Saliency estimation uses the U²-Net architecture by Qin et al. [47].
