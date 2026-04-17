# ESVCP API Reference

## Core Functions

---

### `esvcp_main`

**Signature:**
```matlab
[stego, shares, meta] = esvcp_main(cover, secret, key, varargin)
```

**Description:** Main ESVCP embedding pipeline (SASG → entropy → MLCI → AEDQ).

**Inputs:**

| Argument | Type | Description |
|----------|------|-------------|
| `cover` | `uint8 [M×N]` or `[M×N×3]` | Cover image |
| `secret` | `uint8 [L×1]` or `logical` | Secret bit-stream |
| `key` | `struct` | Keys: `key.mlci` (float), `key.aedq` (1×3) |
| `'bpp'` | float | Embedding rate (default 0.5) |
| `'window'` | int | Entropy window size (default 7) |
| `'tau_sal'` | float | Saliency threshold (default 0.5) |

**Outputs:**

| Argument | Type | Description |
|----------|------|-------------|
| `stego` | `uint8` | Stego-image |
| `shares` | `cell` | VCS shares `{V1, V2, ...}` |
| `meta` | `struct` | `psnr`, `ssim`, `bpp`, `time_total`, etc. |

---

### `esvcp_extract`

**Signature:**
```matlab
[bits, img] = esvcp_extract(stego, shares, key, varargin)
```

**Description:** Recovers the secret from a stego-image using inverse MLCI and VCS superposition.

**Inputs:**

| Argument | Type | Description |
|----------|------|-------------|
| `stego` | `uint8` | Received stego-image |
| `shares` | `cell` | VCS shares (from embedding) |
| `key` | `struct` | Same key used during embedding |
| `'n_bits'` | int | Number of bits to extract (default: 3×M×N) |

---

### `aedq_embed`

**Signature:**
```matlab
stego = aedq_embed(stego_in, cover, H_map, key)
```

**Description:** Applies entropy-adaptive error diffusion (Innovation I). Interpolates between Floyd-Steinberg and Jarvis-Judice-Ninke kernels based on α(i,j).

---

### `mlci_embed`

**Signature:**
```matlab
stego = mlci_embed(cover, secret_bits, H_map, key)
```

**Description:** Embeds secret bits into B0/B1/B2 using chaotic permutation (Innovation II). Load distribution: 60/30/10%.

---

### `sasg_shares`

**Signature:**
```matlab
[shares, sal_mask] = sasg_shares(cover, secret_bits, varargin)
```

**Description:** Generates meaningful VCS shares with saliency-guided protection (Innovation III).

**Optional parameters:** `'tau_sal'` (default 0.5), `'n_shares'` (default 2).

---

### `compute_entropy_map`

**Signature:**
```matlab
H = compute_entropy_map(img, win_size)
```

**Description:** Computes normalised local Shannon entropy H̃(i,j) ∈ [0,1] using a `win_size × win_size` sliding window (default: 7).

---

### `logistic_map_perm`

**Signature:**
```matlab
perm = logistic_map_perm(x0, mu, N)
```

**Description:** Generates a chaotic permutation of 1..N using the logistic map with seed `x0` and parameter `mu`. Default mu = 3.9999.

---

### `compute_metrics`

**Signature:**
```matlab
[psnr_val, ssim_val, ncc_val, ber_val] = compute_metrics(original, reconstructed)
```

**Description:** Computes all four evaluation metrics. Returns PSNR (dB), SSIM [0,1], NCC [-1,1], BER [0,1].

---

## Key Struct Fields

```matlab
key.mlci   % float in (0,1)  — logistic map seed
key.aedq   % [beta theta lambda] — AEDQ parameters
           % beta:   sigmoid steepness (default 10)
           % theta:  entropy threshold (default 0.5)
           % lambda: distortion weight (default 5)
```

## meta Struct Fields

```matlab
meta.psnr          % dB
meta.ssim          % [0,1]
meta.bpp           % embedding rate
meta.n_bits        % number of bits embedded
meta.entropy_mean  % mean H-tilde across image
meta.saliency_pct  % percentage of salient pixels
meta.time_sasg     % seconds
meta.time_entropy  % seconds
meta.time_mlci     % seconds
meta.time_total    % seconds
```
