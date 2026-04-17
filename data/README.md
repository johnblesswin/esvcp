# Data Availability Statement

## Standard Test Images (Bundled)

The following images from the **USC-SIPI Image Database** are included in this repository under `data/test_images/`. These images are in the **public domain**.

| File | Description | Size | Source |
|------|-------------|------|--------|
| `lena.png` | Lena (Léna Söderberg), colour portrait | 512×512 RGB | USC-SIPI vol. misc |
| `baboon.png` | Baboon (Mandrill), vivid colour | 512×512 RGB | USC-SIPI vol. misc |
| `cameraman.png` | Cameraman, grayscale | 256×256 Gray | MATLAB built-in |
| `peppers.png` | Peppers, colour | 512×512 RGB | USC-SIPI vol. misc |
| `boats.png` | Boats, grayscale | 512×512 Gray | USC-SIPI vol. misc |
| `barbara.png` | Barbara, grayscale | 512×512 Gray | USC-SIPI vol. misc |

USC-SIPI Image Database: https://sipi.usc.edu/database/

---

## Large-Scale Benchmark Datasets (Download Required)

The following large-scale datasets were used for full benchmarking but are **not bundled** due to size. Download links and instructions are provided below.

### BOSSBase v1.01
- **Description:** 10,000 grayscale images, 512×512, PGM format
- **URL:** http://agents.fel.cvut.cz/boss/
- **Reference:** Bas et al. [52]
- **Instructions:**
  1. Download `BOSSbase_1.01.zip` from the URL above
  2. Extract to `data/BOSSBase/`
  3. Run `src/prepare_dataset.m` to convert PGM to PNG

### BOWS-2
- **Description:** 10,000 grayscale images, 512×512
- **URL:** http://bows2.ec-lille.fr/
- **Instructions:**
  1. Download from the URL above
  2. Extract to `data/BOWS2/`

### ALASKA#2
- **Description:** 80,000 JPEG images, 512×512, in-camera processed
- **URL:** https://alaska.utt.fr/
- **Reference:** Cogranne et al. [45]
- **Instructions:**
  1. Register at the URL above to obtain download access
  2. Extract to `data/ALASKA2/`
  3. Run `src/prepare_alaska.m` to organize by quality factor

---

## Secret Images Used in Experiments

Sample secret images (MNIST handwritten digits, binary patterns) are available in `data/secret_images/`. These are a subset of:

- **MNIST dataset** (LeCun et al., 1998) — http://yann.lecun.com/exdb/mnist/
- **BSDS500** boundary detection images — https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/resources.html

---

## Pre-Computed Results

All benchmark results reported in the paper's Tables 3–10 are pre-computed and provided as CSV files in `results/`:

| File | Contents | Paper Table |
|------|----------|-------------|
| `psnr_ssim_table.csv` | PSNR/SSIM at 7 payload rates, 5 methods | Table 3, 4 |
| `steganalysis_pe.csv` | P_E per detector per method at 0.4 bpp | Table 6 |
| `capacity_comparison.csv` | Max EC per method | Table 5 |
| `ablation_study.csv` | PSNR and P_E under module removal | Table 9 |
| `ncc_ber_table.csv` | NCC and BER for recovery | Table 7 |
| `share_quality.csv` | VCS share PSNR and SSIM | Table 8 |
| `runtime_comparison.csv` | Embedding/extraction runtime | Table 10 |

---

## Data Availability Statement (for paper)

> The standard USC-SIPI test images used in this study are in the public domain and available from https://sipi.usc.edu/database/. The BOSSBase v1.01 [52], BOWS-2, and ALASKA#2 [45] benchmark datasets are freely available upon registration from their respective project websites. All pre-computed benchmark results and the complete MATLAB implementation are openly available on GitHub at https://github.com/\<your-username\>/ESVCP-framework under the MIT licence.
